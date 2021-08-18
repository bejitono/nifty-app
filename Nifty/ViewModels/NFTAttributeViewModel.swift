//
//  NFTAttributeViewModel.swift
//  Nifty
//
//  Created by Stefano on 15.08.21.
//

import Foundation

struct NFTAttributeViewModel: Identifiable, Equatable {
    
    let id: UUID
    let trait: String
    let value: String
    
    init(id: UUID = UUID(),
         trait: String,
         value: String) {
        self.id = id
        self.trait = trait
        self.value = value
    }
}

extension NFTAttributeViewModel {
    
    init(_ model: ERC721MetadataAttribute) {
        self.init(
            trait: model.trait,
            value: model.value
        )
    }
}
 
