//
//  OpenSeaRepository.swift
//  Nifty
//
//  Created by Stefano on 30.08.21.
//

import Combine
import Foundation

final class OpenSeaRepository: NFTFetcheable {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClientImpl()) {
        self.networkClient = networkClient
    }
    
    func fetchNFTs(with address: String, offset: Int = 50) -> AnyPublisher<[NFT], Error> {
        let components = buildURLComponents(with: address, offset: offset)
        return networkClient
            .request(with: components)
            .map(toNFTs)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func toNFTs(_ response: OpenSeaResponse) -> [NFT] {
        response.assets.map(NFT.init)
    }
    
    // TODO: add opensea api key
    private func buildURLComponents(with address: String, offset: Int) -> URLComponents {
//        curl --request GET \
//             --url 'https://api.opensea.io/api/v1/assets?owner=0xD3e9D60e4E4De615124D5239219F32946d10151D&order_direction=desc&offset=0&limit=20'
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.opensea.io"
        components.path = "/api/v1/assets"
        components.queryItems = [
            URLQueryItem(name: "owner", value: address),
            URLQueryItem(name: "order_direction", value: "desc"),
            URLQueryItem(name: "limit", value: String(offset))
        ]
        return components
    }
}
