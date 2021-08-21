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
    let from: String
    let contractAddress: String
    let to: String
    let tokenID: String
    let tokenName: String
    let tokenSymbol: String
    let tokenDecimal: String
    let transactionIndex: String
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
            from: self.from,
            contractAddress: self.contractAddress,
            to: self.to,
            tokenID: self.tokenID,
            tokenName: self.tokenName,
            tokenSymbol: self.tokenSymbol,
            tokenDecimal: self.tokenDecimal,
            transactionIndex: self.transactionIndex,
            metadata: ERC721Metadata.empty,
            media: failureMedia
        )
        return nft
    }
}

typealias NFTHash = String

extension NFT {
    
    init(_ dto: NFTDto) {
        self.timeStamp = dto.timeStamp
        self.from = dto.from
        self.contractAddress = dto.contractAddress
        self.to = dto.to
        self.tokenID = dto.tokenID
        self.tokenName = dto.tokenName
        self.tokenSymbol = dto.tokenSymbol
        self.tokenDecimal = dto.tokenDecimal
        self.transactionIndex = dto.transactionIndex
    }
    
    init(_ dto: NFTCacheDto,
         _ mediaURL: String) {
        self.timeStamp = dto.timeStamp
        self.from = dto.from
        self.contractAddress = dto.contractAddress
        self.to = dto.to
        self.tokenID = dto.tokenID
        self.tokenName = dto.tokenName
        self.tokenSymbol = dto.tokenSymbol
        self.tokenDecimal = dto.tokenDecimal
        self.transactionIndex = dto.transactionIndex
        self.media = Media(dto.media, mediaURL)
        self.metadata = ERC721Metadata(dto.metadata)
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
    let from: String
    let contractAddress: String
    let to: String
    let tokenID: String
    let tokenName: String
    let tokenSymbol: String
    let tokenDecimal: String
    let transactionIndex: String
    var metadata: ERC721MetadataCacheDto?
    var media: MediaCacheDto?
}

extension NFTCacheDto {
    
    init(_ model: NFT) {
        self.timeStamp = model.timeStamp
        self.from = model.from
        self.contractAddress = model.contractAddress
        self.to = model.to
        self.tokenID = model.tokenID
        self.tokenName = model.tokenName
        self.tokenSymbol = model.tokenSymbol
        self.tokenDecimal = model.tokenDecimal
        self.transactionIndex = model.transactionIndex
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
