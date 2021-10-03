//
//  NFTFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct NFTFactory {
    
    func buildNFTList(user: User, showTab: Binding<Bool>) -> some View {
        let viewModel = NFTListViewModel(user: user)
        let view = NFTListView(showTab: showTab, viewModel: viewModel)
        return view
    }
}
