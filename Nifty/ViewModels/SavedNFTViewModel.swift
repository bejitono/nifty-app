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
    let imageURL: String?
    let contractAddress: String
}

extension SavedNFTViewModel {
    
    init(_ model: NFTCache) {
        self.name = model.name ?? ""
        self.imageURL = model.imageURL
        self.contractAddress = model.contractAddress ?? ""
    }
}
