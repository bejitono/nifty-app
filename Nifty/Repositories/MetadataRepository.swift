//
//  MetadataRepository.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import Combine
import Foundation

protocol MetadataFetcheable {
    func fetchMetadata(url: URL) -> AnyPublisher<ERC721Metadata, Error>
}

final class MetadataRepository: MetadataFetcheable {
    
    private let networkClient: NetworkClient
    
    init(networkClient: NetworkClient = NetworkClientImpl()) {
        self.networkClient = networkClient
    }
    
    func fetchMetadata(url: URL) -> AnyPublisher<ERC721Metadata, Error> {
        return networkClient.request(with: url)
            .map(ERC721Metadata.init)
            .mapError { $0 }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
