//
//  EtherscanRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol NFTPersistable {
    func save(nft: NFT)
    func fetchNFT(from hash: NFTHash) -> NFT?
}

protocol NFTFetcheable {
    func fetchNFTs(with address: String, offset: Int) -> AnyPublisher<[NFT], Error>
}

final class NFTRepository: NFTFetcheable, NFTPersistable {
    
    private let cache: UserCache
    private let networkClient: NetworkClient
    
    init(cache: UserCache = UserCache(),
         networkClient: NetworkClient = NetworkClientImpl()) {
        self.cache = cache
        self.networkClient = networkClient
    }
    
    func save(nft: NFT) {
        var savedNFTs: [NFTHash: NFTCacheDto] = cache.get() ?? [:]
        savedNFTs[nft.hash] = NFTCacheDto(nft)
        cache.set(savedNFTs)
    }
    
    func fetchNFT(from hash: NFTHash) -> NFT? {
        guard let nftDictionary: [NFTHash: NFTCacheDto] = cache.get(),
              let nftDto = nftDictionary[hash] else {
            return nil
        }
        let fileName = nftDictionary[hash]?.media?.mediaURL
        let url = getSavedMediaURL(named: fileName ?? "")
        return NFT(nftDto, url?.absoluteString)
    }
    
    func fetchNFTs(with address: String, offset: Int = 0) -> AnyPublisher<[NFT], Error> {
        let components = buildURLComponents(with: address)
        let toNFTsWithAddress: ([NFT]) -> ([NFT], String) = { nfts in (nfts, address) }
        
        return networkClient.request(with: components)
            .map(toNFTs)
            .map(toNFTsWithAddress)
            .map(toOwnedNFTs)
            .map(syncPersistentStore)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func toNFTs(_ response: EtherscanResponse<[NFTDto]>) -> [NFT] {
        response.result.map(NFT.init)
    }
    
    private func toOwnedNFTs(_ nfts: [NFT], _ address: String) -> [NFT] {
        var ownedNFTs = [NFT]()
        var soldNFTs = [NFT]()
        
        nfts.forEach { nft in
            let nftWasSold = soldNFTs.contains(where: {
                $0.contractAddress == nft.contractAddress && $0.tokenID == nft.tokenID
            })
            
            if nft.to.lowercased() == address.lowercased(), !nftWasSold {
                ownedNFTs.append(nft)
            } else {
                soldNFTs.append(nft)
            }
        }
        
        return ownedNFTs
    }
    
    private func syncPersistentStore(_ nfts: [NFT]) -> [NFT] {
        var nftDictionary: [NFTHash: NFTCacheDto] = cache.get() ?? [:]
        let nftHashes = nftDictionary.map { $0.key }
        nftHashes.forEach { hash in
            // If a saved nft is not found in newly fetched nfts, then remove it
            if !nfts.contains(where: { hash == $0.hash }) {
                guard let fileName = nftDictionary[hash]?.media?.mediaURL,
                      let url = getSavedMediaURL(named: fileName) else {
                    return
                }
                try? FileManager.default.removeItem(at: url)
                nftDictionary.removeValue(forKey: hash)
            }
        }
        cache.set(nftDictionary)
        return nfts
    }
    
    private func getSavedMediaURL(named name: String) -> URL? {
        guard let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            return nil
        }
        return URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(name)
    }
    
    private func buildURLComponents(with address: String) -> URLComponents {
        //https://api.etherscan.io/api?module=account&action=tokennfttx&address=0x3a66a228f96889d09b8d854e57cced493e80a995&startblock=0&endblock=999999999&sort=asc&apikey=YourApiKeyToken
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.etherscan.io"
        components.path = "/api"
        components.queryItems = [
            URLQueryItem(name: "module", value: "account"),
            URLQueryItem(name: "action", value: "tokennfttx"),
            URLQueryItem(name: "address", value: address),
            URLQueryItem(name: "startblock", value: "0"),
            URLQueryItem(name: "endblock", value: "999999999"),
            URLQueryItem(name: "sort", value: "desc"),
            URLQueryItem(name: "apikey", value: AppConstants.etherScanAPIKey)
        ]
        return components
    }
}
