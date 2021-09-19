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
                    imageURL: nft.imageURL,
                    contractAddress: nft.contractAddress
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
}
