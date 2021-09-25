//
//  NFTCollectionFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct NFTCollectionFactory {
    
    func buildNFTCollectionFlow(user: User) -> some View {
        let view = NFTCollectionFlowView(user: user)
        return view
    }
    
    func buildNFTCollectionList(user: User, flow: Binding<NFTCollectionFlow>) -> some View {
        let viewModel = NFTCollectionListViewModel(user: user)
        let view = NFTCollectionListView(flow: flow, viewModel: viewModel)
        return view
    }
}
