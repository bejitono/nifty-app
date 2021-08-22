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
    let description: String?
    let attributes: [ERC721MetadataAttribute]
}

struct ERC721MetadataAttribute: Equatable {
    let trait: String
    let value: String
}

extension ERC721Metadata {
    
    init(_ dto: ERC721MetadataDto) {
        self.init(
            name: dto.name ?? "",
            image: dto.image,
            description: dto.description,
            attributes: dto.attributes?.compactMap(ERC721MetadataAttribute.init) ?? []
        )
    }
    
    init?(_ cacheDto: ERC721MetadataCacheDto?) {
        guard let cacheDto = cacheDto else {
            return nil
        }
        self.name = cacheDto.name
        self.image = cacheDto.image
        self.description = cacheDto.description
        self.attributes = cacheDto.attributes.compactMap(ERC721MetadataAttribute.init)
    }
    
    static var empty: ERC721Metadata {
        ERC721Metadata(name: "", image: "", description: "", attributes: [])
    }
}

extension ERC721MetadataAttribute {
    
    init(_ dto: ERC721MetadataAttributeDto) {
        self.trait = dto.trait
        self.value = dto.value
    }
    
    init(_ cacheDto: ERC721MetadataAttributeCacheDto) {
        self.trait = cacheDto.trait
        self.value = cacheDto.value
    }
    
    static var empty: ERC721MetadataAttribute {
        ERC721MetadataAttribute(trait: "", value: "")
    }
}

struct ERC721MetadataDto: Codable {
    let name: String?
    let image: String
    let description: String?
    let attributes: [ERC721MetadataAttributeDto]?
}

struct ERC721MetadataAttributeDto: Codable {
    let trait: String
    let value: String
    
    enum CodingKeys: String, CodingKey {
        case trait = "trait_type"
        case value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trait = try container.decode(String.self, forKey: .trait)
        if let intValue = try? container.decode(Int.self, forKey: .value) {
            value = String(intValue)
        } else if let doubleValue = try? container.decode(Double.self, forKey: .value) {
            value = String(doubleValue)
        } else {
            value = try container.decode(String.self, forKey: .value)
        }
    }
}

struct ERC721MetadataCacheDto: Codable {
    let name: String
    let image: String
    let description: String?
    let attributes: [ERC721MetadataAttributeCacheDto]
}

struct ERC721MetadataAttributeCacheDto: Codable {
    let trait: String
    let value: String
}

extension ERC721MetadataCacheDto {
    
    init?(_ model: ERC721Metadata?) {
        guard let model = model else {
            return nil
        }
        self.name = model.name
        self.image = model.image
        self.description = model.description
        self.attributes = model.attributes.compactMap(ERC721MetadataAttributeCacheDto.init)
    }
}

extension ERC721MetadataAttributeCacheDto {
    
    init(_ model: ERC721MetadataAttribute) {
        self.trait = model.trait
        self.value = model.value
    }
}
