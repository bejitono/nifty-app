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
        guard let contractAddress = dto.contracts.first?.address else { return nil }
        self.name = dto.name
        self.imageURL = dto.imageURL
        self.contractAddress = contractAddress
    }
}

struct OpenSeaNFTCollectionDTO: Codable {
    let name: String
    let imageURL: String?
    let contracts: [Contract]
    
    struct Contract: Codable {
        let address: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "image_url"
        case contracts = "primary_asset_contracts"
    }
}
