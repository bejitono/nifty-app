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
    @Published var metadata: ERC721Metadata?
    @Published var media: Media?

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
        let address = "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//"0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        
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
                print("****** received value: \(value)")
                self?.nfts = value
            }
            .store(in: &disposables)
        
        $nfts
            .flatMap {
                self.mediaPublisher(for: $0)
            }
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("***\(error)")
                    self?.media = nil
                }
            } receiveValue: { [weak self] value in
                guard let self = self else { return }
                print("****** received value: \(value)")
                self.media = value.media
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
        web3Repository.fetchTokenURI(contractAddress: nft.contractAddress, tokenId: nft.tokenID)
            .flatMap { [weak self] url -> AnyPublisher<ERC721Metadata, Error> in
                guard let self = self else {
                    return Fail(error: NFTError.couldNotParseTokenURI(url))
                        .eraseToAnyPublisher()
                }
                let tokenURI = self.tokenURIParser.parseTokenURI(url)
                print("**token uri: \(tokenURI)")
                return self.metadataRepository.fetchMetadata(url: tokenURI)
            }
            .flatMap { [weak self] metadata -> AnyPublisher<Media, Error> in
                guard let self = self, let mediaURL = self.mediaURLParser.parseMediaURLString(metadata.image) else {
                    return Fail(error: NFTError.couldNotParseMediaURLString(metadata.image))
                        .eraseToAnyPublisher()
                }
                print("**image url: \(mediaURL)")
                return self.mediaRepository.fetchImageData(from: mediaURL) //"https://gateway.ipfs.io/ipfs/QmVNNeGjsBsc8fJiKZwzs8KiQmAu6hVavJ49d3BSziNoKY/nft.mp4")!)
            }
            .flatMap { media in
                Just((nft, media)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

enum NFTError: Error {
    case viewModelDeallocated
    case couldNotParseMediaURLString(_ url: String)
    case couldNotParseTokenURI(_ url: URL)
}
