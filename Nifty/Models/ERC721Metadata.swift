//
//  ERC721Metadata.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

struct ERC721Metadata: Equatable {
    let name: String
    let image: String
    // attributes, etc.
}

extension ERC721Metadata {
    
    init(_ dto: ERC721MetadataDto) {
        self.init(
            name: dto.name ?? "",
            image: dto.image
        )
    }
}

struct ERC721MetadataDto: Codable {
    let name: String?
    let image: String
    // attributes, etc.
}
