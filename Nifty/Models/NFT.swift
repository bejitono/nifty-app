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
}

extension NFT: Hashable { // todo: remove hashable
    
    var hash: String {
        SHA256.hash(data: Data((contractAddress + tokenID).utf8))
            .compactMap { String(format: "%02x", $0) }
            .joined()
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
    let mediaURL: String
    let type: MediaType
    let fileType: FileType
}

extension NFTCacheDto {
    init(_ model: Media) {
        self.mediaURL = model.url.lastPathComponent
        self.type = model.type
        self.fileType = model.fileType
    }
}

extension MediaType: Codable { }
extension FileType: Codable { }

// Key is hash value of contractAdress and tokenID
extension Dictionary: UserCacheKeyConvertible where Key == NFTHash, Value == NFTCacheDto {
    static var key: String = "Nifty.NFTCacheDto.Dictionary"
}
