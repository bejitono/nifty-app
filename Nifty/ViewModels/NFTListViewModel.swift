//
//  ViewModel.swift
//  Nifty
//
//  Created by Stefano on 09.08.21.
//

import Combine
import Foundation

final class NFTListViewModel: ObservableObject {
    
    @Published var nftsViewModel: [NFTViewModel] = []
    @Published var showDetails: Bool = false
    @Published var nftDetails: NFTViewModel = .empty
    @Published var showShareMedia: Bool = false
    @Published var sharedMedia: MediaViewModel?
    @Published private var nfts: [NFT] = []

    private let nftRepository: NFTFetcheable
    private let metadataRepository: MetadataFetcheable
    private let web3Repository: ERC721TokenURIFetcheable
    private let mediaRepository: MediaFetcheable
    private let tokenURIParser: TokenURIParseable
    private let mediaURLParser: MediaURLParseable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        etherscanRepository: NFTFetcheable = NFTRepository(),
        metadataRepository: MetadataFetcheable = MetadataRepository(),
        web3Repository: ERC721TokenURIFetcheable = Web3Repository(),
        mediaRepository: MediaFetcheable = MediaRepository(),
        tokenURIParser: TokenURIParseable = URLParser(),
        mediaURLParser: MediaURLParseable = URLParser()
    ) {
        self.nftRepository = etherscanRepository
        self.metadataRepository = metadataRepository
        self.web3Repository = web3Repository
        self.mediaRepository = mediaRepository
        self.tokenURIParser = tokenURIParser
        self.mediaURLParser = mediaURLParser
        fetchNFTs()
    }
    
    func fetchNFTs() {
        let address = "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781" //"0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//lots of nfts and lots with errors: "0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        
        nftRepository.fetchNFTs(with: address)
            .map { nfts -> [NFT] in
                self.nfts = nfts
                    .filter { $0.tokenSymbol != "ENS" }
                return nfts
            }
            .flatMap(mediaPublisher)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("***\(error)")
                }
            } receiveValue: { [weak self] fetchedNFT in
                guard let self = self else { return }
                print("****** received value: \(fetchedNFT)")
                self.nfts = self.nfts.compactMap { nft in
                    if nft.hash == fetchedNFT.hash {
                        // TODO: Save failed nfts and don't refetch
                        guard let metadata = fetchedNFT.metadata,
                              let media = fetchedNFT.media else { return nil }
                        var nft = nft
                        nft.metadata = metadata
                        nft.media = media
                        return nft
                    }
                    return nft
                }
            }
            .store(in: &cancellables)
        
        $nfts
            .sink { self.nftsViewModel = $0.map(NFTViewModel.init) }
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
    
    private func mediaPublisher(for nfts: [NFT]) -> AnyPublisher<NFT, Error> {
        Publishers.Sequence(
            sequence: nfts.map {
                self.mediaPublisher(for: $0)
                    .replaceError(with: $0.failed())
                    .eraseToAnyPublisher()
            }
        )
        .flatMap(maxPublishers: .max(1)) { $0 }
        .flatMap { nft -> AnyPublisher<NFT, Error> in
            self.nftRepository.save(nft: nft)
            return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }

    private func mediaPublisher(for nft: NFT) -> AnyPublisher<NFT, Error> {
        if let savedNFT = nftRepository.fetchNFT(from: nft.hash) {
            return Just(savedNFT)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        var nft = nft
        // add time limit and retry
        return web3Repository.fetchTokenURI(contractAddress: nft.contractAddress, tokenId: nft.tokenID).print("%%%%")
            .map(tokenURIParser.parseTokenURI)
            .flatMap(metadataRepository.fetchMetadata).print("%%%%") // if same url as another tokenid, merge it with the other
            .flatMap { [mediaURLParser] metadata -> AnyPublisher<URL, Error> in // directly capture parser to avoid retain cycle with self
                guard let mediaURL = mediaURLParser.parseMediaURLString(metadata.image) else {
                    return Fail(error: NFTError.couldNotParseMediaURLString(metadata.image))
                        .eraseToAnyPublisher()
                }
                
                nft.metadata = metadata
                return Just(mediaURL)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .flatMap(mediaRepository.fetchMedia).print("%%%%")
            .flatMap { [nftRepository] media -> AnyPublisher<NFT, Error> in
                nft.media = media
                return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum NFTError: Error {
    case couldNotParseMediaURLString(_ url: String)
    case couldNotParseTokenURI(_ url: URL)
}
