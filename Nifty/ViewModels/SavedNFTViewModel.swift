//
//  SavedNFTViewModel.swift
//  Nifty
//
//  Created by Stefano on 17.09.21.
//

import Foundation

struct SavedNFTViewModel: Equatable, Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let tokenId: String
    let imageURL: String?
    let contractAddress: String
    let permalink: String
}

extension SavedNFTViewModel {
    
    init(_ model: NFTCache) {
        self.name = model.name ?? ""
        self.description = model.description
        self.tokenId = model.tokenId ?? ""
        self.imageURL = model.imageURL
        self.contractAddress = model.contractAddress ?? ""
        self.permalink = model.permalink ?? ""
    }
    
    static var empty: SavedNFTViewModel {
        SavedNFTViewModel(
            name: "",
            description: "",
            tokenId: "",
            imageURL: nil,
            contractAddress: "",
            permalink: ""
        )
    }
}
