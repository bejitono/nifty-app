//
//  Models.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

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
