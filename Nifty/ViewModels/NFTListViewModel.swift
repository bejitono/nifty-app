//
//  ViewModel.swift
//  Nifty
//
//  Created by Stefano on 09.08.21.
//

import AVKit
import Combine
import Foundation
import MobileCoreServices

final class NFTListViewModel: ObservableObject {
    
    enum State {
        case loading
        case error(message: String)
        case loaded(nfts: [NFTViewModel])
    }
    
    @Published var state: State = .loading
    @Published var nftsViewModel: [NFTViewModel] = []
    @Published var showDetails: Bool = false
    @Published var nftDetails: NFTViewModel = .empty
    @Published var showShareMedia: Bool = false
    @Published var sharedMedia: MediaViewModel?
    
    @Published private var nfts: [NFT] = []
    
    private var currentOffset = 0
    private let limit = 20
    private var isFetching = false
    private var finished = false
    
    private let user: User
    private let nftRepository: NFTFetcheable & NFTPersistable
    private let metadataRepository: MetadataFetcheable
    private let web3Repository: ERC721TokenURIFetcheable
    private let mediaRepository: MediaFetcheable
    private let tokenURIParser: TokenURIParseable
    private let mediaURLParser: MediaURLParseable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        user: User,
        nftRepository: NFTFetcheable & NFTPersistable = NFTRepository(),
        metadataRepository: MetadataFetcheable = MetadataRepository(),
        web3Repository: ERC721TokenURIFetcheable = Web3Repository(),
        mediaRepository: MediaFetcheable = MediaRepository(),
        tokenURIParser: TokenURIParseable = URLParser(),
        mediaURLParser: MediaURLParseable = URLParser()
    ) {
        self.user = user
        self.nftRepository = nftRepository
        self.metadataRepository = metadataRepository
        self.web3Repository = web3Repository
        self.mediaRepository = mediaRepository
        self.tokenURIParser = tokenURIParser
        self.mediaURLParser = mediaURLParser
        fetchNFTs(offset: currentOffset)
        $nfts
            .map {
                $0.map(NFTViewModel.init)
            }
            .sink { [weak self] nfts in
                self?.state = .loaded(nfts: nfts)
            }
            .store(in: &cancellables)
    }
    
    func handleTapOn(nft: NFTViewModel) {
        nftDetails = nft
        if !nft.isLoading {
            showDetails = true
        }
    }
    
    func share(nft: NFTViewModel) {
        if let media = nft.media {
            sharedMedia = media
            showShareMedia = true
        }
    }
    
    func fetchNFTsIfNeeded(for currentNFT: NFTViewModel) {
        // TODO: check if all nfts are fetched when it reaches its end (less nfts available then limit 20)
        guard !isFetching, let index: Int = nftsViewModel.firstIndex(of: currentNFT) else { return }
        let reachedThreshold = Double(index) / Double(nftsViewModel.count) > 0.7
        if reachedThreshold && !finished {
            fetchNFTs(offset: currentOffset)
        }
    }
    
    func refetch() {
        fetchNFTs(offset: currentOffset)
    }
    
    private func fetchNFTs(offset: Int) {
//        let address = "0xD3e9D60e4E4De615124D5239219F32946d10151D" // alex masm"0xD3e9D60e4E4De615124D5239219F32946d10151D" //"0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//lots of nfts and lots with errors: "0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        isFetching = true
        
        nftRepository.fetchNFTs(forAddress: user.wallet.address, offset: currentOffset, limit: limit)
            .map { [weak self] nfts -> [NFT] in
                guard let self = self else { return [] }
                self.currentOffset += self.limit
                self.isFetching = false
                self.nfts.append(contentsOf: nfts)
                // If we get less nfts back then the one's specificed
                // in the limit, then we can stop fetching
                if nfts.count < self.limit {
                    self.finished = true
                }
                return nfts
            }
            .flatMap(mediaPublisher)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.state = .error(message: "Something went wrong. Please try again later.")
                }
            } receiveValue: { [weak self] fetchedNFT in
                guard let self = self else { return }
                self.nfts = self.nfts.compactMap { nft in
                    if nft.hash == fetchedNFT.hash {
                        guard let media = fetchedNFT.media else { return nil }
                        var nft = nft
                        nft.media = media
                        return nft
                    }
                    return nft
                }
            }
            .store(in: &cancellables)
    }
    
    private func mediaPublisher(for nfts: [NFT]) -> AnyPublisher<NFT, Error> {
        Publishers.Sequence(
            sequence: nfts.map {
                self.mediaPublisher(for: $0)
                    .replaceError(with: $0.failed())
                    .eraseToAnyPublisher()
            }
        )
        .flatMap(maxPublishers: .max(1)) { $0 }
        // Saving is causing issues when fetching more nfts (images not shown in previosly fetched nfts
        // Probably an issue with loading in repo
//        .flatMap { nft -> AnyPublisher<NFT, Error> in
//            self.nftRepository.save(nft: nft)
//            return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
//        }
        .eraseToAnyPublisher()
    }

    private func mediaPublisher(for nft: NFT) -> AnyPublisher<NFT, Error> {
//        if let savedNFT = nftRepository.fetchNFT(from: nft.hash) {
//            return Just(savedNFT)
//                .setFailureType(to: Error.self)
//                .eraseToAnyPublisher()
//        }
        
        guard let metadata = nft.metadata, let imageURL = URL(string: metadata.imageURL) else {
            return Fail(error: NFTError.couldNotGetImageURL).eraseToAnyPublisher()
        }
        
        var url: URL
        if let videoURLString = nft.metadata?.animationURL,
           let videoURL = URL(string: videoURLString),
           supportedVideoFileExtensions.contains(videoURL.pathExtension) {
            url = videoURL
        } else {
            url = imageURL
        }
        
        var nft = nft
        // add time limit and retry
        
        return mediaRepository.fetchMedia(url: url)
            .flatMap { media -> AnyPublisher<NFT, Error> in
                nft.media = media
                return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
        
        // if using web3 nft fetch:
//        return web3Repository.fetchTokenURI(contractAddress: nft.contractAddress, tokenId: nft.tokenID).print("+++")
//            .map(tokenURIParser.parseTokenURI)
//            .flatMap(metadataRepository.fetchMetadata).print("%%%%") // if same url as another tokenid, merge it with the other
//            .flatMap { [mediaURLParser] metadata -> AnyPublisher<URL, Error> in // directly capture parser to avoid retain cycle with self
//                guard let mediaURL = mediaURLParser.parseMediaURLString(metadata.image) else {
//                    return Fail(error: NFTError.couldNotParseMediaURLString(metadata.image))
//                        .eraseToAnyPublisher()
//                }
//
//                nft.metadata = metadata
//                return Just(mediaURL)
//                    .setFailureType(to: Error.self)
//                    .eraseToAnyPublisher()
//            }
//            .flatMap(mediaRepository.fetchMedia).print("&&&")
//            .flatMap { media -> AnyPublisher<NFT, Error> in
//                nft.media = media
//                return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
    }
    
    private var supportedVideoFileExtensions: [String] {
        let avTypes = AVURLAsset.audiovisualTypes()
        var avExtensions = avTypes.map({ UTTypeCopyPreferredTagWithClass($0 as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? ?? "" })
        avExtensions = avExtensions.filter { !$0.isEmpty }
        return avExtensions
    }
}

enum NFTError: Error {
    case couldNotParseMediaURLString(_ url: String)
    case couldNotParseTokenURI(_ url: URL)
    case couldNotGetImageURL
}
