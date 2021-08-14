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
    
    init?(_ cacheDto: ERC721MetadataCacheDto?) {
        guard let cacheDto = cacheDto else {
            assertionFailure("Expected dto")
            return nil
        }
        self.name = cacheDto.name
        self.image = cacheDto.image
    }
}

struct ERC721MetadataDto: Codable {
    let name: String?
    let image: String
    // attributes, etc.
}

struct ERC721MetadataCacheDto: Codable {
    let name: String
    let image: String
}

extension ERC721MetadataCacheDto {
    
    init?(_ model: ERC721Metadata?) {
        guard let model = model else {
            assertionFailure("Expected dto")
            return nil
        }
        self.name = model.name
        self.image = model.image
    }
}
