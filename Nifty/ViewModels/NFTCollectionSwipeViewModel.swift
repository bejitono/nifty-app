//
//  NFTCollectionSwipeViewModel.swift
//  Nifty
//
//  Created by Stefano on 03.09.21.
//

import AVKit
import Combine
import Foundation
import MobileCoreServices

enum SwipeDirection {
    case left
    case right
    case none
}

final class NFTCollectionSwipeViewModel: ObservableObject {
    
    var index = 0
    let collectionName: String
    @Published var currentNFTs: [NFTViewModel] = []
    @Published private var nftViewModels: [NFTViewModel] = []
    @Published private var nfts: [NFT] = []
    
    private var likedNFTs: [NFTViewModel] = []
    private var dismissedNFTs: [NFTViewModel] = []
    private var currentOffset = 0
    private var isFetching = false
    private let nftRepository: NFTCollectionFetcheable & NFTPersistable
    private let mediaRepository: MediaFetcheable
    private let contractAddress: String
    private var cancellables = Set<AnyCancellable>()
    
    init(
        collectionName: String,
        contractAddress: String,
        nftRepository: NFTCollectionFetcheable & NFTPersistable = NFTRepository(),
        mediaRepository: MediaFetcheable = MediaRepository()
    ) {
        self.collectionName = collectionName
        self.contractAddress = contractAddress
        self.nftRepository = nftRepository
        self.mediaRepository = mediaRepository
        fetchNFTs(offset: currentOffset)
        // being called many times
        $nfts
            .map {
                $0.map(NFTViewModel.init)
            }
            .sink { [weak self] viewModels in
                guard let self = self else { return }
                self.nftViewModels = viewModels
            }
            .store(in: &cancellables)
        
        // Initially assign 4 nfts to current card swipe stack
        $nftViewModels
            .prefix(2)
            .sink { [weak self] viewModels in
                guard let self = self else { return }
                var initialNFTs: [NFTViewModel] = []
                for index in 0..<4 {
                    if let nft = viewModels[safe: index] {
                        initialNFTs.append(nft)
                        self.index = index
                    }
                }
                self.currentNFTs = initialNFTs.reversed()
            }
            .store(in: &cancellables)
    }
    
    func swiped(_ nft: NFTViewModel, at index: Int, to swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .left:
            dismissedNFTs.append(nft)
        case .right:
            try? nftRepository.save(
                id: nft.id,
                contractAddress: nft.contractAddress,
                tokenId: nft.tokenId,
                name: nft.name,
                description: nft.description,
                imageURL: nft.imageURL,
                animationURL: nft.animationURL,
                permalink: nft.permalink
            )
            likedNFTs.append(nft)
        case .none:
            break
        }
        
        currentNFTs.remove(at: index)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let nft = self.nftViewModels[safe: self.index + 1] else { return }
            // Appending would be more efficient (maybe cards should be reverted)
            self.currentNFTs.insert(nft, at: 0)
            self.index += 1
            self.fetchNFTsIfNeeded(for: nft)
        }
    }
    
    private func fetchNFTsIfNeeded(for currentNFT: NFTViewModel) {
        guard !isFetching, let index: Int = nftViewModels.firstIndex(of: currentNFT) else { return }
        let reachedThreshold = Double(index) / Double(nftViewModels.count) > 0.7
        if reachedThreshold {
            fetchNFTs(offset: currentOffset)
        }
    }
    
    private func fetchNFTs(offset: Int) {
        let limit = 20
        isFetching = true
        
        nftRepository.fetchNFTs(forContractAddress: contractAddress, offset: offset, limit: limit)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    // TODO: handle error
                    print("***\(error)")
                }
            } receiveValue: { [weak self] nfts in
                guard let self = self else { return }
                self.currentOffset += limit
                self.isFetching = false
                self.nfts.append(contentsOf: nfts)
            }
            .store(in: &cancellables)
    }
}
