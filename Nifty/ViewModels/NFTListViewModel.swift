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
    @Published private var nfts: [NFT] = []

    private let nftRepository: NFTFetcheable
    private let metadataRepository: MetadataFetcheable
    private let web3Repository: ERC721TokenURIFetcheable
    private let mediaRepository: MediaFetcheable
    private let tokenURIParser: TokenURIParseable
    private let mediaURLParser: MediaURLParseable
    private var disposables = Set<AnyCancellable>()
    
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
        let address = "0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//"0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        
        nftRepository.fetchNFTs(with: address)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("***\(error)")
                    self?.nfts = []
                }
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                print("****** received value: \(value)")
                
                self.nfts = value
            }
            .store(in: &disposables)
        
        $nfts
            .flatMap(mediaPublisher)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("***\(error)")
                    self?.nftsViewModel = []
                }
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                print("****** received value: \(value)")
                // TODO: Handle when new nfts have been added which need to be fetched
                self.nftsViewModel = self.nftsViewModel.map { nft in
                    if let media = value.media,
                       let metadata = value.metadata,
                       nft.tokenId == value.tokenID && nft.contractAddress == value.contractAddress {
                        var nft = nft
                        nft.name = metadata.name
                        nft.media = MediaViewModel(media)
                        nft.isLoading = false
                        return nft
                    }
                    return nft
                }
            }
            .store(in: &disposables)
        
        $nfts
            .sink { [weak self] nfts in
                guard let self = self else { return }
                self.nftsViewModel = nfts
                    .filter { $0.tokenSymbol != "ENS" }
                    .map(NFTViewModel.init)
            }
            .store(in: &disposables)
    }
    
    func mediaPublisher(for nfts: [NFT]) -> AnyPublisher<NFT, Error> {
        Publishers.Sequence(
            sequence: nfts.map {
                self.mediaPublisher(for: $0)
                    .replaceError(with: $0.appendFailureMedia())
                    .eraseToAnyPublisher()
            }
        ) // add failure image
            .flatMap(maxPublishers: .max(1)) { $0 }
            .eraseToAnyPublisher()
    }

    func mediaPublisher(for nft: NFT) -> AnyPublisher<NFT, Error> {
        if let savedNFT = nftRepository.fetchNFT(from: nft.hash) {
            return Just(savedNFT)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        var nft = nft
        // add time limit and retry
        return web3Repository.fetchTokenURI(contractAddress: nft.contractAddress, tokenId: nft.tokenID)
            .map(tokenURIParser.parseTokenURI)
            .flatMap(metadataRepository.fetchMetadata) // if same url as another tokenid, merge it with the other
            .flatMap { [mediaURLParser] metadata ->  AnyPublisher<URL, Error> in // directly capture parser to avoid retain cycle with self
                guard let mediaURL = mediaURLParser.parseMediaURLString(metadata.image) else {
                    return Fail(error: NFTError.couldNotParseMediaURLString(metadata.image))
                        .eraseToAnyPublisher()
                }
                
                nft.metadata = metadata
                return Just(mediaURL)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .flatMap(mediaRepository.fetchMedia)
            .flatMap { [nftRepository] media -> AnyPublisher<NFT, Error> in
                nft.media = media
                // TODO: Shouldn't have side effects
                nftRepository.save(nft: nft)
                return Just(nft).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum NFTError: Error {
    case couldNotParseMediaURLString(_ url: String)
    case couldNotParseTokenURI(_ url: URL)
}
