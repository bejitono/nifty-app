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
    private var disposables = Set<AnyCancellable>()
    
    init(
        etherscanRepository: NFTFetcheable = EtherscanRepository(),
        metadataRepository: MetadataFetcheable = MetadataRepository(),
        web3Repository: ERC721TokenURIFetcheable = Web3Repository(),
        mediaRepository: MediaFetcheable = MediaRepository()
    ) {
        self.etherscanRepository = etherscanRepository
        self.metadataRepository = metadataRepository
        self.web3Repository = web3Repository
        self.mediaRepository = mediaRepository
        fetchNFTs()
    }
    
    func fetchNFTs() {
        // get user's nft's
        // call contract's tokenURI to get metadata
        // call metadata link and get metadata json
        // load the image (or other media) from metadata's image address
        
        // TODO: handle ipfs urls via cloudflare
        // - https://ipfs.io/ipfs/QmeLhTe2Cy24enUiHY3TNjqAoPTiuVpUA6CSo9c2iA7AWD/5
        // - ipfs://QmZANhgW1EaNz8CKN22uHrUpL62xcJEs3iawjYzACCmVsc/3

        let address = "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781" //"0xb8c2C29ee19D8307cb7255e1Cd9CbDE883A267d5" //paul "0xdfDf2D882D9ebce6c7EAc3DA9AB66cbfDa263781"//"0xECc953EFBd82D7Dea4aa0F7Bc3329Ea615e0CfF2" //"0x7CeA66d7bC4856F90b94A3C1ea0229B86aa3697a"
        
        etherscanRepository.fetchNFTs(with: address)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("finished")
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
            }.print("**nfts")
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    print("finished")
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
                        return nft
                    }
                    return nft
                }
            }
            .store(in: &disposables)
        
        $nfts
            .sink { [weak self] nfts in
                self?.nftsViewModel = nfts
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
                print("**token uri: \(url)")
                var url = url
                // Should probably route all urls to gateways
                // e.g. https://gateway.pinata.cloud/ipfs/QmZuKciW2Amabd8aZDKEXawTEJFDeNbtjtN5B4swMtcqTK
                // too many requests error
                
                // once received only QmWXENbdrQBcEXtyfAtZfWJDpn3e3Kzz4d4SpiBDQtS5Kp as url
                // --> need to check if valid ipfs hash https://github.com/ipfs-shipyard/is-ipfs/blob/master/src/index.js
                if url.host == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
                    url = cloudflareURL.appendingPathComponent(url.path)
                } else if url.scheme == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
                    // ipfs://QmZANhgW1EaNz8CKN22uHrUpL62xcJEs3iawjYzACCmVsc/3
                    url = cloudflareURL
                        .appendingPathComponent(url.host ?? "")
                        .appendingPathComponent(url.path)
                }
                return self!.metadataRepository.fetchMetadata(url: url)
            }.print()
            .flatMap { [weak self] metadata -> AnyPublisher<Media, Error> in
                var imageURL = URL(string: metadata.image)!
                if imageURL.host?.contains("ipfs") ?? false, let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
                    let path = imageURL.path.replacingOccurrences(of: "/ipfs", with: "")
                    imageURL = cloudflareURL.appendingPathComponent(path)
                } else if imageURL.scheme == "ipfs", let cloudflareURL = URL(string: "https://cloudflare-ipfs.com/ipfs") {
                    // ipfs://QmZANhgW1EaNz8CKN22uHrUpL62xcJEs3iawjYzACCmVsc/3
                    imageURL = cloudflareURL
                        .appendingPathComponent(imageURL.host ?? "")
                        .appendingPathComponent(imageURL.path)
                }
                print("**image url: \(imageURL)")
                return self!.mediaRepository.fetchImageData(from: imageURL) //"https://gateway.ipfs.io/ipfs/QmVNNeGjsBsc8fJiKZwzs8KiQmAu6hVavJ49d3BSziNoKY/nft.mp4")!)
            }.print()
            .flatMap { media in
                Just((nft, media)).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}


// on cloudfare sometimes get: video streaming is not allowed
//—> support different gateways

//export default helper(function hitUrls([hit]/*, hash*/) {
//  return [
//    `https://gateway.ipfs.io/ipfs/${hit.hash}`,
//    `https://clowdflare-ipfs.com/ipfs/${hit.hash}`
//  ];
//});
