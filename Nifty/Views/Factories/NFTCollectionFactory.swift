//
//  NFTCollectionFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct NFTCollectionFactory {
    
    func buildNFTCollectionList(user: User) -> some View {
        let viewModel = NFTCollectionListViewModel(user: user)
        let view = NFTCollectionListView(viewModel: viewModel)
        return view
    }
}
