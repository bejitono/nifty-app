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
    @Published var currentNFTs: [NFTViewModel] = []
    @Published private var nftViewModels: [NFTViewModel] = []
    @Published private var nfts: [NFT] = []
    
    private var likedNFTs: [NFTViewModel] = []
    private var dismissedNFTs: [NFTViewModel] = []
    private var currentOffset = 0
    private var isFetching = false
    private let nftRepository: NFTCollectionFetcheable
    private let mediaRepository: MediaFetcheable
    private let contractAddress: String
    private var cancellables = Set<AnyCancellable>()
    
    init(
        contractAddress: String,
        nftRepository: NFTCollectionFetcheable = NFTRepository(),
        mediaRepository: MediaFetcheable = MediaRepository()
    ) {
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
                self.nftViewModels = viewModels.reversed()
            }
            .store(in: &cancellables)
        
        // Initially assign 4 nfts to current stack
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
                self.currentNFTs = initialNFTs
            }
            .store(in: &cancellables)
    }
    
    func swiped(_ nft: NFTViewModel, at index: Int, to swipeDirection: SwipeDirection) {
        switch swipeDirection {
        case .left:
            dismissedNFTs.append(nft)
        case .right:
            likedNFTs.append(nft)
        case .none:
            break
        }
        
        currentNFTs.remove(at: index)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let nft = self.nftViewModels[safe: self.index + 1] else { return }
            // Appending would be more efficient (maybe cards should be reverted
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
//            .map { nfts -> [NFT] in
//                self.currentOffset += limit
//                self.isFetching = false
//                self.nfts.append(contentsOf: nfts)
//                return nfts
//            }
//            .flatMap(mediaPublisher)
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
//                self.nfts = self.nfts.compactMap { nft in
//                    if nft.hash == fetchedNFT.hash {
//                        guard let media = fetchedNFT.media else { return nil }
//                        var nft = nft
//                        nft.media = media
//                        return nft
//                    }
//                    return nft
//                }
                
                // Change:
//                self.currentNFTs = self.currentNFTs.map { nft in
//                    var nft = nft
//                    let viewModel = NFTViewModel(fetchedNFT)
//                    if nft.media == nil {
//                        nft.media = viewModel.media
//                    }
//                    return nft
//                }
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
        .eraseToAnyPublisher()
    }

    private func mediaPublisher(for nft: NFT) -> AnyPublisher<NFT, Error> {
        guard let metadata = nft.metadata, let imageURL = URL(string: metadata.imageURL) else {
            return Fail(error: NFTError.couldNotGetImageURL).eraseToAnyPublisher()
        }
        
        var url: URL
        if let videoURLString = nft.metadata?.animationURL,
           let videoURL = URL(string: videoURLString),
           supportedVideoFileExtensions().contains(videoURL.pathExtension) {
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
    }
    
    private func supportedVideoFileExtensions() -> [String] {
        let avTypes = AVURLAsset.audiovisualTypes()
        var avExtensions = avTypes.map({ UTTypeCopyPreferredTagWithClass($0 as CFString, kUTTagClassFilenameExtension)?.takeRetainedValue() as String? ?? "" })
        avExtensions = avExtensions.filter { !$0.isEmpty }
        return avExtensions
    }
}
