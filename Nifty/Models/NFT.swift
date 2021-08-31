//
//  Models.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import CryptoKit
import Foundation

struct NFT: Equatable {
    let timeStamp: String
    let contractAddress: String
    let to: String
    let tokenID: String
    let tokenName: String
    let tokenSymbol: String
    var metadata: ERC721Metadata?
    var media: Media?
}

extension NFT {
    
    var hash: String {
        SHA256.hash(data: Data((contractAddress + tokenID).utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
    }
    
    func failed() -> Self {
        let failureMedia = Media(
            url: "failure_ape",
            type: .staticImage,
            fileType: .jpg
        )
        let nft = NFT(
            timeStamp: self.timeStamp,
            contractAddress: self.contractAddress,
            to: self.to,
            tokenID: self.tokenID,
            tokenName: self.tokenName,
            tokenSymbol: self.tokenSymbol,
            metadata: nil,
            media: nil
        )
        return nft
    }
}

typealias NFTHash = String

extension NFT {
    
    init(_ dto: NFTDto) {
        self.timeStamp = dto.timeStamp
        self.contractAddress = dto.contractAddress
        self.to = dto.to
        self.tokenID = dto.tokenID
        self.tokenName = dto.tokenName
        self.tokenSymbol = dto.tokenSymbol
    }
    
    init(_ dto: NFTCacheDto,
         _ mediaURL: String?) {
        self.timeStamp = dto.timeStamp
        self.contractAddress = dto.contractAddress
        self.to = dto.to
        self.tokenID = dto.tokenID
        self.tokenName = dto.tokenName
        self.tokenSymbol = dto.tokenSymbol
        self.media = Media(dto.media, mediaURL)
        self.metadata = ERC721Metadata(dto.metadata)
    }
    
    init(_ dto: OpenSeaNFTDto) {
        self.timeStamp = dto.contract.createdDate
        self.contractAddress = dto.contract.address
        self.to = dto.owner.address
        self.tokenID = dto.tokenId
        self.tokenName = dto.contract.name
        self.tokenSymbol = dto.contract.symbol
        self.metadata = ERC721Metadata(
            name: dto.name,
            image: dto.image ?? dto.animationURL ?? "",
            description: dto.description,
            attributes: dto.traits.map {
                ERC721MetadataAttribute(trait: $0.trait, value: $0.value)
            }
        )
    }
}

struct NFTDto: Codable {
    let timeStamp: String
    let hash: String
    let blockHash: String
    let from: String
    let contractAddress: String
    let to: String
    let tokenID: String
    let tokenName: String
    let tokenSymbol: String
    let tokenDecimal: String
    let transactionIndex: String
}

struct EtherscanResponse<T: Codable>: Codable {
    let result: T
}

struct NFTCacheDto: Codable {
    let timeStamp: String
    let contractAddress: String
    let to: String
    let tokenID: String
    let tokenName: String
    let tokenSymbol: String
    var metadata: ERC721MetadataCacheDto?
    var media: MediaCacheDto?
}

extension NFTCacheDto {
    
    init(_ model: NFT) {
        self.timeStamp = model.timeStamp
        self.contractAddress = model.contractAddress
        self.to = model.to
        self.tokenID = model.tokenID
        self.tokenName = model.tokenName
        self.tokenSymbol = model.tokenSymbol
        self.media = MediaCacheDto(model.media)
        self.metadata = ERC721MetadataCacheDto(model.metadata)
    }
}

extension MediaType: Codable { }
extension FileType: Codable { }

// Key is hash value of contractAdress and tokenID
extension Dictionary: UserCacheKeyConvertible where Key == NFTHash, Value == NFTCacheDto {
    static var key: String = "Nifty.NFTCacheDto.Dictionary"
}

struct OpenSeaResponse: Codable {
    let assets: [OpenSeaNFTDto]
}

struct OpenSeaNFTDto: Codable {
    let tokenId: String
    let name: String
    let description: String?
    let animationURL: String?
    let image: String?
    let imagePreview: String?
    let contract: Contract
    let owner: Owner
    let traits: [Trait]
    
    struct Contract: Codable {
        let address: String
        let name: String
        let symbol: String
        let createdDate: String
        
        enum CodingKeys: String, CodingKey {
            case address
            case name
            case symbol
            case createdDate = "created_date"
        }
    }
    
    struct Owner: Codable {
        let user: User
        let address: String
        let profileImage: String?

        struct User: Codable {
            let username: String?
        }
        
        enum CodingKeys: String, CodingKey {
            case user
            case address
            case profileImage = "profile_img_url"
        }
     }

    struct Trait: Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case tokenId = "token_id"
        case name
        case description
        case image = "image_url"
        case imagePreview = "image_preview_url"
        case animationURL = "animation_url"
        case contract = "asset_contract"
        case owner
        case traits
    }
}
