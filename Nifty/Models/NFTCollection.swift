//
//  NFTCollection.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import Foundation

struct NFTCollection: Equatable {
    let name: String
    let imageURL: String?
    let contractAddress: String
}

extension NFTCollection {
    
    init?(_ dto: OpenSeaNFTCollectionDTO) {
        guard let contractAddress = dto.contractAddress else { return nil }
        self.name = dto.name
        self.imageURL = dto.imageURL
        self.contractAddress = contractAddress
    }
}

struct OpenSeaCollectionResponse: Codable {
    let collections: [OpenSeaNFTCollectionDTO]
}

struct OpenSeaNFTCollectionDTO: Codable {
    let name: String
    let imageURL: String?
    let contractAddress: String?
}
