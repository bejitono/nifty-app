//
//  EtherscanRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol NFTPersistable {
    func save(
        id: UUID,
        contractAddress: String,
        tokenId: String,
        name: String,
        description: String?,
        imageURL: String?,
        animationURL: String?,
        permalink: String
    ) throws
    
    func fetchNFTs() throws -> [NFTViewModel] // TODO: change to nft
    
    func deleteNFTs() throws
}

protocol NFTFetcheable {
    func fetchNFTs(forAddress address: String, offset: Int, limit: Int) -> AnyPublisher<[NFT], Error>
}

protocol NFTCollectionFetcheable {
    func fetchCollections(forAddress address: String, offset: Int, limit: Int) -> AnyPublisher<[NFTCollection], Error>
    func fetchNFTs(forContractAddress contractAddress: String, offset: Int, limit: Int, sort: SortItem.SortType) -> AnyPublisher<[NFT], Error>
}

final class NFTRepository: NFTFetcheable,
                           NFTCollectionFetcheable,
                           NFTPersistable {
    
    private let persistenceStore: PersistenceStore
    private let networkClient: NetworkClient
    private let openSeaRepository: NFTFetcheable & NFTCollectionFetcheable
    
    init(persistenceStore: PersistenceStore = PersistenceStore.shared,
         networkClient: NetworkClient = NetworkClientImpl(),
         openSeaRepository: NFTFetcheable & NFTCollectionFetcheable = OpenSeaRepository()) {
        self.persistenceStore = persistenceStore
        self.networkClient = networkClient
        self.openSeaRepository = openSeaRepository
    }
    
    func save(
        id: UUID,
        contractAddress: String,
        tokenId: String,
        name: String,
        description: String?,
        imageURL: String?,
        animationURL: String?,
        permalink: String
    ) throws {
        let _ = NFTCache(
            id: id,
            contractAddress: contractAddress,
            tokenId: tokenId,
            name: name,
            description: description,
            imageURL: imageURL,
            animationURL: animationURL,
            permalink: permalink
        )
        try persistenceStore.save()
    }
    
    func fetchNFTs() throws -> [NFTViewModel] { // TODO: Change to NFTs
//        guard let nftDictionary: [NFTHash: NFTCacheDto] = cache.get(),
//              let nftDto = nftDictionary[hash] else {
//            return nil
//        }
//        let fileName = nftDictionary[hash]?.media?.mediaURL
//        let url = getSavedMediaURL(named: fileName ?? "")
//        return NFT(nftDto, url?.absoluteString)
        let persistedNFTs: [NFTCache] = try persistenceStore.fetch(recent: 100)
        return persistedNFTs.map { nft in
            NFTViewModel(
                id: UUID(),
                contractAddress: nft.contractAddress ?? "",
                tokenId: nft.tokenId ?? "",
                name: nft.name ?? "",
                description: nft.nftDescription,
                imageURL: nft.imageURL,
                animationURL: nft.animationURL,
                permalink: nft.permalink ?? "",
                media: nil,
                attributes: [],
                isLoading: false
            )
        }
    }
    
    func deleteNFTs() throws {
        try persistenceStore.deleteAll()
    }
    
    func fetchNFTs(forAddress address: String, offset: Int = 0, limit: Int = 20) -> AnyPublisher<[NFT], Error> {
//        let components = buildURLComponents(with: address)
//        let toNFTsWithAddress: ([NFT]) -> ([NFT], String) = { nfts in (nfts, address) }
        
//        return networkClient.request(with: components)
//            .map(toNFTs)
//            .map(toNFTsWithAddress)
//            .map(toOwnedNFTs)
//            .map(syncPersistentStore)
//            .mapError { $0 }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
        openSeaRepository.fetchNFTs(forAddress: address, offset: offset, limit: limit)
    }
    
    func fetchNFTs(
        forContractAddress contractAddress: String,
        offset: Int,
        limit: Int,
        sort: SortItem.SortType
    ) -> AnyPublisher<[NFT], Error> {
        openSeaRepository.fetchNFTs(forContractAddress: contractAddress, offset: offset, limit: limit, sort: sort)
    }
    
    func fetchCollections(forAddress address: String, offset: Int, limit: Int) -> AnyPublisher<[NFTCollection], Error> {
        openSeaRepository.fetchCollections(forAddress: address, offset: offset, limit: limit)
    }
    
    
    // If fetching from etherescan:
//    func fetchNFTs(with address: String, offset: Int = 0) -> AnyPublisher<[NFT], Error> {
//        let components = buildURLComponents(with: address)
//        let toNFTsWithAddress: ([NFT]) -> ([NFT], String) = { nfts in (nfts, address) }
        
//        return networkClient.request(with: components)
//            .map(toNFTs)
//            .map(toNFTsWithAddress)
//            .map(toOwnedNFTs)
//            .map(syncPersistentStore)
//            .mapError { $0 }
//            .receive(on: DispatchQueue.main)
//            .eraseToAnyPublisher()
//    }
    
//    private func toNFTs(_ response: EtherscanResponse<[NFTDto]>) -> [NFT] {
//        response.result.map(NFT.init)
//    }
//
//    private func toOwnedNFTs(_ nfts: [NFT], _ address: String) -> [NFT] {
//        var ownedNFTs = [NFT]()
//        var soldNFTs = [NFT]()
//
//        nfts.forEach { nft in
//            let nftWasSold = soldNFTs.contains(where: {
//                $0.contractAddress == nft.contractAddress && $0.tokenID == nft.tokenID
//            })
//
//            if nft.to.lowercased() == address.lowercased(), !nftWasSold {
//                ownedNFTs.append(nft)
//            } else {
//                soldNFTs.append(nft)
//            }
//        }
//
//        return ownedNFTs
//    }
    
//    private func syncPersistentStore(_ nfts: [NFT]) -> [NFT] {
//        var nftDictionary: [NFTHash: NFTCacheDto] = cache.get() ?? [:]
//        let nftHashes = nftDictionary.map { $0.key }
//        nftHashes.forEach { hash in
//            // If a saved nft is not found in newly fetched nfts, then remove it
//            if !nfts.contains(where: { hash == $0.hash }) {
//                guard let fileName = nftDictionary[hash]?.media?.mediaURL,
//                      let url = getSavedMediaURL(named: fileName) else {
//                    return
//                }
//                try? FileManager.default.removeItem(at: url)
//                nftDictionary.removeValue(forKey: hash)
//            }
//        }
//        cache.set(nftDictionary)
//        return nfts
//    }
    
    private func getSavedMediaURL(named name: String) -> URL? {
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name)
    }
    
//    // TODO: remove if etherscan not used anymore
//    private func buildURLComponents(with address: String) -> URLComponents {
//        //https://api.etherscan.io/api?module=account&action=tokennfttx&address=0x3a66a228f96889d09b8d854e57cced493e80a995&startblock=0&endblock=999999999&sort=asc&apikey=YourApiKeyToken
//        var components = URLComponents()
//        components.scheme = "https"
//        components.host = "api.etherscan.io"
//        components.path = "/api"
//        components.queryItems = [
//            URLQueryItem(name: "module", value: "account"),
//            URLQueryItem(name: "action", value: "tokennfttx"),
//            URLQueryItem(name: "address", value: address),
//            URLQueryItem(name: "startblock", value: "0"),
//            URLQueryItem(name: "endblock", value: "999999999"),
//            URLQueryItem(name: "sort", value: "desc"),
//            URLQueryItem(name: "apikey", value: AppConstants.etherScanAPIKey)
//        ]
//        return components
//    }
}
