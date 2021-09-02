//
//  NFTCollectionViewModel.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

struct NFTCollectionViewModel: Equatable {
    let name: String
    let imageURL: String?
    let contractAddress: String
}

extension NFTCollectionViewModel {
    
    init(_ model: NFTCollection) {
        self.name = model.name
        self.imageURL = model.imageURL
        self.contractAddress = model.contractAddress
    }
}
