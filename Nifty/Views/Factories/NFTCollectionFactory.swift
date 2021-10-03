//
//  NFTCollectionFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct NFTCollectionFactory {
    
    func buildNFTCollectionList(user: User, showTab: Binding<Bool>) -> some View {
        let viewModel = NFTCollectionListViewModel(user: user)
        let view = NFTCollectionListView(showTab: showTab, viewModel: viewModel)
        return view
    }
}
