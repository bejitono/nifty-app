//
//  NFTFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct NFTFactory {
    
    func buildNFTList(user: User) -> some View {
        let viewModel = NFTListViewModel(user: user)
        let view = NFTListView(viewModel: viewModel)
        return view
    }
}
