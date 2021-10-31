//
//  SavedNFTListViewModel.swift
//  Nifty
//
//  Created by Stefano on 17.09.21.
//

import Combine
import Foundation

final class SavedNFTListViewModel: ObservableObject {
    
    @Published var nftViewModels: [SavedNFTViewModel] = []
    @Published var showDetails: Bool = false
    @Published var showShareMedia: Bool = false
    @Published var nftDetails: SavedNFTViewModel = .empty
//    @Published private var nfts: [NFT] = []
    
    private let nftRepository: NFTPersistable
    private var cancellables = Set<AnyCancellable>()
    
    init(nftRepository: NFTPersistable = NFTRepository()) {
        self.nftRepository = nftRepository
        fetchSavedNFTs()
    }
    
    func fetchSavedNFTs() {
        do {
            let nfts = try nftRepository.fetchNFTs()
            nftViewModels = nfts.map { nft in
                SavedNFTViewModel(
                    name: nft.name,
                    description: nft.description ?? "",
                    tokenId: nft.tokenId,
                    imageURL: nft.imageURL,
                    contractAddress: nft.contractAddress,
                    permalink: nft.permalink
                )
            }
        } catch {
            nftViewModels = []
        }
    }
    
    func deleteSavedNFTs() {
        do {
            try nftRepository.deleteNFTs()
            nftViewModels = []
        } catch {
            // handle error
        }
    }
    
    func handleTapOn(nft: SavedNFTViewModel) {
        nftDetails = nft
        showDetails = true
    }
    
    func onLinkTap() {
        // Slight delay to not close bototm card while url is opened
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.showDetails = false
//        }
        showShareMedia = true
    }
    
    func onShareFinished() {
        showDetails = false
    }
}
