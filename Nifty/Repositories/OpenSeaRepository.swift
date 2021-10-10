//
//  OpenSeaRepository.swift
//  Nifty
//
//  Created by Stefano on 30.08.21.
//

import Combine
import Foundation

final class OpenSeaRepository: NFTFetcheable, NFTCollectionFetcheable {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClientImpl()) {
        self.networkClient = networkClient
    }
    
    func fetchNFTs(forAddress address: String, offset: Int = 0, limit: Int = 20) -> AnyPublisher<[NFT], Error> {
        let components = buildNFTFetchURLComponents(withAddress: address, offset: offset, limit: limit)
        return networkClient
            .request(with: components)
            .map(toNFTs)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchNFTs(
        forContractAddress contractAddress: String,
        offset: Int,
        limit: Int,
        sort: SortItem.SortType
    ) -> AnyPublisher<[NFT], Error> {
        let components = buildNFTFetchURLComponents(withContractAddress: contractAddress, offset: offset, limit: limit, sort: sort)
        return networkClient
            .request(with: components)
            .map(toNFTs)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetchCollections(forAddress address: String, offset: Int, limit: Int) -> AnyPublisher<[NFTCollection], Error> {
        let components = buildNFTCollectionsFetchURLComponents(withAddress: address, offset: offset, limit: limit)
        return networkClient
            .request(with: components)
            .map(toNFTCollections)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    private func toNFTs(_ response: OpenSeaNFTResponse) -> [NFT] {
        response.assets.map(NFT.init)
    }
    
    private func toNFTCollections(_ response: [OpenSeaNFTCollectionDTO]) -> [NFTCollection] {
        response.compactMap(NFTCollection.init)
    }
    
    // TODO: add opensea api key
    private func buildNFTFetchURLComponents(withAddress address: String, offset: Int, limit: Int) -> URLComponents {
//        curl --request GET \
//             --url 'https://api.opensea.io/api/v1/assets?owner=0xD3e9D60e4E4De615124D5239219F32946d10151D&order_direction=desc&offset=0&limit=20'
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.opensea.io"
        components.path = "/api/v1/assets"
        components.queryItems = [
            URLQueryItem(name: "owner", value: address),
            URLQueryItem(name: "order_direction", value: "desc"),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        return components
    }
    
    // TODO: add opensea api key
    private func buildNFTFetchURLComponents(
        withContractAddress address: String,
        offset: Int,
        limit: Int,
        sort: SortItem.SortType
    ) -> URLComponents {
//        curl --request GET \
//             --url 'https://api.opensea.io/api/v1/assets?owner=0xD3e9D60e4E4De615124D5239219F32946d10151D&order_direction=desc&offset=0&limit=20'
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.opensea.io"
        components.path = "/api/v1/assets"
        components.queryItems = [
            URLQueryItem(name: "asset_contract_address", value: address),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit)),
            buildSortOderDirectionQueryItem(sort: sort),
        ]
        if let orderByItem = buildSortOderByQueryItem(sort: sort) {
            components.queryItems?.append(orderByItem)
        }
        return components
    }
    
    // TODO: add opensea api key
    private func buildNFTCollectionsFetchURLComponents(withAddress address: String, offset: Int, limit: Int) -> URLComponents {
//        curl --request GET \
//        --url 'https://api.opensea.io/api/v1/collections?asset_owner=0xD3e9D60e4E4De615124D5239219F32946d10151D&offset=0&limit=10'
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.opensea.io"
        components.path = "/api/v1/collections"
        components.queryItems = [
            URLQueryItem(name: "asset_owner", value: address),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "limit", value: String(limit))
        ]
        return components
    }
    
    func buildSortOderByQueryItem(sort: SortItem.SortType) -> URLQueryItem? {
        switch sort {
        case .priceDesc:
            return URLQueryItem(name: "order_by", value: "sale_price")
        case .priceAsc:
            return URLQueryItem(name: "order_by", value: "sale_price")
        case .salesDesc:
            return URLQueryItem(name: "order_by", value: "sale_count")
        case .salesAsc:
            return URLQueryItem(name: "order_by", value: "sale_count")
        case .salesDateDesc:
            return URLQueryItem(name: "order_by", value: "sale_date")
        case .salesDateAsc:
            return URLQueryItem(name: "order_by", value: "sale_date")
        case .tokenIdDesc:
            return nil
        case .tokenIdAsc:
            return nil
            
        }
    }
    
    func buildSortOderDirectionQueryItem(sort: SortItem.SortType) -> URLQueryItem {
        switch sort {
        case .priceDesc:
            return URLQueryItem(name: "order_direction", value: "desc")
        case .priceAsc:
            return URLQueryItem(name: "order_direction", value: "asc")
        case .salesDesc:
            return URLQueryItem(name: "order_direction", value: "desc")
        case .salesAsc:
            return URLQueryItem(name: "order_direction", value: "asc")
        case .salesDateDesc:
            return URLQueryItem(name: "order_direction", value: "desc")
        case .salesDateAsc:
            return URLQueryItem(name: "order_direction", value: "asc")
        case .tokenIdDesc:
            return URLQueryItem(name: "order_direction", value: "desc")
        case .tokenIdAsc:
            return URLQueryItem(name: "order_direction", value: "asc")
            
        }
    }
}
