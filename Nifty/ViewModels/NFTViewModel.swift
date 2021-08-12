//
//  NFTViewModel.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import Foundation

struct NFTViewModel: Identifiable, Equatable {
    let id: UUID
    let contractAddress: String
    let tokenId: String
    var name: String
    var description: String
    var media: MediaViewModel?
    var isLoading: Bool
    
    init(id: UUID = UUID(),
         contractAddress: String,
         tokenId: String = "",
         name: String = "",
         description: String = "",
         media: MediaViewModel? = nil,
         isLoading: Bool = true) {
        self.id = id
        self.contractAddress = contractAddress
        self.tokenId = tokenId
        self.name = name
        self.description = description
        self.media = media
        self.isLoading = isLoading
    }
}

extension NFTViewModel {
    
    init(_ model: NFT) {
        self.init(
            contractAddress: model.contractAddress,
            tokenId: model.tokenID
        )
    }
}
