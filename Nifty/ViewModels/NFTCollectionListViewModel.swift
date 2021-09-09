//
//  NFTCollectionListViewModel.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import Combine
import Foundation

final class NFTCollectionListViewModel: ObservableObject {
    
    @Published var collectionViewModels: [NFTCollectionViewModel] = []
    @Published private var collections: [NFTCollection] = []
    private var currentOffset = 0
    private var isFetching = false
    private var reachedEnd = false
    
    private let nftRepository: NFTCollectionFetcheable
    private var cancellables = Set<AnyCancellable>()
    
    init(nftRepository: NFTCollectionFetcheable = NFTRepository()) {
        self.nftRepository = nftRepository
        fetchCollections(offset: currentOffset)
        $collections
            .map {
                $0.map(NFTCollectionViewModel.init)
            }
            .assign(to: &$collectionViewModels)
    }
    
    func fetchCollectionIfNeeded(for collection: NFTCollectionViewModel) {
        guard !isFetching, !reachedEnd, let index: Int = collectionViewModels.firstIndex(of: collection) else { return }
        let reachedThreshold = Double(index) / Double(collectionViewModels.count) > 0.7
        if reachedThreshold {
            fetchCollections(offset: currentOffset)
        }
    }
    
    func fetchCollections(offset: Int) {
        let limit = 50
        isFetching = true
        
        nftRepository.fetchCollection(
            forAddress: "0xD3e9D60e4E4De615124D5239219F32946d10151D",
            offset: currentOffset,
            limit: limit
        )
        .sink { completion in
            switch completion {
            case .finished:
                break
            case .failure(let error):
                // TODO: handle error
                print("***\(error)")
            }
        } receiveValue: { [weak self] fetchedCollections in
            guard let self = self else { return }
            self.currentOffset += limit
            self.isFetching = false
            self.collections.append(contentsOf: fetchedCollections)
            if fetchedCollections.isEmpty {
                self.reachedEnd = true
            }
        }
        .store(in: &cancellables)
    }
}
