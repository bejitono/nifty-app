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
    @Published var nfts: [NFT] = []

    private let etherscanRepository: NFTFetcheable
    private let metadataRepository: MetadataFetcheable
    private let web3Repository: ERC721TokenURIFetcheable
    private let mediaRepository: MediaFetcheable
    private let tokenURIParser: TokenURIParseable
    private let mediaURLParser: MediaURLParseable
    private var disposables = Set<AnyCancellable>()
    
    init(
        etherscanRepository: NFTFetcheable = EtherscanRepository(),
        metadataRepository: MetadataFetcheable = MetadataRepository(),
        web3Repository: ERC721TokenURIFetcheable = Web3Repository(),
        mediaRepository: MediaFetcheable = MediaRepository(),
        tokenURIParser: TokenURIParseable = URLParser(),
        mediaURLParser: MediaURLParseable = URLParser()
    ) {
        self.etherscanRepository = etherscanRepository
        self.metadataRepository = metadataRepository
        self.web3Repository = web3Repository
        self.mediaRepository = mediaRepository
        self.tokenURIParser = tokenURIParser
        self.mediaURLParser = mediaURLParser
        fetchNFTs()
    }
    
    func fetchNFTs() {
        let address = "0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0x57C2955C0d0fC319dDF6110eEdFCC81AF3caDD72" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//"0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        
        etherscanRepository.fetchNFTs(with: address)
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
                self.nftsViewModel = self.nftsViewModel.map { nft in
                    if nft.tokenId == value.nft.tokenID && nft.contractAddress == nft.contractAddress {
                        var nft = nft
                        nft.media = MediaViewModel(value.media)
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
    
    func mediaPublisher(for nfts: [NFT]) -> AnyPublisher<(nft: NFT, media: Media), Error> {
        Publishers.Sequence(sequence: nfts.map { (nft: $0, media: self.mediaPublisher(for: $0)) })
            .flatMap(maxPublishers: .max(1)) {
                // continue upon failure
                $0.media
                .replaceError(with:
                    ($0.nft, Media(
                        url: URL(
                            string: "https://publish.one37pm.net/wp-content/uploads/2021/02/punks.png")!,
                        type: .image,
                        fileType: .jpg
                    ))
                ) // add failure image
            }
            .eraseToAnyPublisher()
    }

    func mediaPublisher(for nft: NFT) -> AnyPublisher<(nft: NFT, media: Media), Error> {
        if let media = mediaRepository.fetchMediaFromPersistenceStore(from: nft.hash) {
            return Just((nft, media))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        // add time limit and retry
        return web3Repository.fetchTokenURI(contractAddress: nft.contractAddress, tokenId: nft.tokenID)
            .map(tokenURIParser.parseTokenURI)
            .flatMap(metadataRepository.fetchMetadata) // if same url as another tokenid, merge it with the other
            .flatMap { [mediaURLParser] metadata ->  AnyPublisher<(URL, NFTHash), Error> in // directly capture parser to avoid retain cycle with self
                guard let mediaURL = mediaURLParser.parseMediaURLString(metadata.image) else {
                    return Fail(error: NFTError.couldNotParseMediaURLString(metadata.image))
                        .eraseToAnyPublisher()
                }
                return Just((mediaURL, nft.hash))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .flatMap(mediaRepository.fetchMedia)
            .flatMap { media in
                Just((nft, media)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum NFTError: Error {
    case couldNotParseMediaURLString(_ url: String)
    case couldNotParseTokenURI(_ url: URL)
}
