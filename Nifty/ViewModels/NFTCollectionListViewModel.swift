//
//  NFTCollectionListViewModel.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import Combine
import Foundation

final class NFTCollectionListViewModel: ObservableObject {
    
    enum State {
        case loading
        case error(message: String)
        case loaded(collections: [NFTCollectionViewModel])
    }
    
    @Published var state: State = .loading
    @Published var searchText = ""
    
    @Published private var collections: [NFTCollection] = []
    private var collectionViewModels: [NFTCollectionViewModel] = []
    private var currentOffset = 0
    private var isFetching = false
    private var reachedEnd = false
    
    private let user: User
    private let nftRepository: NFTCollectionFetcheable
    private var cancellables = Set<AnyCancellable>()
    
    init(
        user: User,
        nftRepository: NFTCollectionFetcheable = NFTRepository()
    ) {
        self.user = user
        self.nftRepository = nftRepository
        fetchCollections(offset: currentOffset)
        $collections
            .map {
                $0.map(NFTCollectionViewModel.init)
            }
            .sink { [weak self] collections in
                guard let self = self else { return }
                self.collectionViewModels = collections
                self.state = .loaded(collections: self.collectionViewModels)
            }
            .store(in: &cancellables)
    }
    
    func fetchCollectionIfNeeded(for collection: NFTCollectionViewModel) {
        guard !isFetching, !reachedEnd, let index: Int = collectionViewModels.firstIndex(of: collection) else { return }
        let reachedThreshold = Double(index) / Double(collectionViewModels.count) > 0.7
        if reachedThreshold {
            fetchCollections(offset: currentOffset)
        }
    }
    
    func refetch() {
        fetchCollections(offset: currentOffset)
    }
    
    func fetchCollections(offset: Int) {
        let limit = 50
        isFetching = true
        
        nftRepository.fetchCollections(
            forAddress: user.wallet.address,
            offset: currentOffset,
            limit: limit
        )
        .sink { [weak self] completion in
            switch completion {
            case .finished:
                break
            case .failure:
                self?.state = .error(message: "Something went wrong. Please try again later.")
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
