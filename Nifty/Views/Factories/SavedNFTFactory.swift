//
//  SavedNFTFactory.swift
//  Nifty
//
//  Created by Stefano on 25.09.21.
//

import SwiftUI

struct SavedNFTFactory {
    
    func buildSavedNFTList(showTab: Binding<Bool>) -> some View {
        let viewModel = SavedNFTListViewModel()
        let view = SavedNFTListView(showTab: showTab, viewModel: viewModel)
        return view
    }
}
