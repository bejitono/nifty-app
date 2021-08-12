//
//  EtherscanRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol NFTFetcheable {
    func fetchNFTs(with address: String) -> AnyPublisher<[NFT], Error>
}

final class EtherscanRepository: NFTFetcheable {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClientImpl()) {
        self.networkClient = networkClient
    }
    
    func fetchNFTs(with address: String) -> AnyPublisher<[NFT], Error> {
        let components = buildURLComponents(with: address)
        let toNFTsWithAddress: ([NFT]) -> ([NFT], String) = { nfts in (nfts, address) }
        
        return networkClient.request(with: components)
            .map(toNFTs)
            .map(toNFTsWithAddress)
            .map(toOwnedNFTs)
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
