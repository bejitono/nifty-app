//
//  SavedNFTFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct SavedNFTFactory {
    
    func buildSavedNFTList() -> some View {
        let viewModel = SavedNFTListViewModel()
        let view = SavedNFTListView(viewModel: viewModel)
        return view
    }
}
