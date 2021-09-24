//
//  NFTCollectionFlowView.swift
//  Nifty
//
//  Created by Stefano on 06.09.21.
//

import SwiftUI

enum NFTCollectionFlow {
    case list
    case detail(contractAddress: String)
}

struct NFTCollectionFlowView: View {
    
    @State var flow: NFTCollectionFlow = .list
    
    var body: some View {
        VStack {
            switch flow {
            case .list:
                NFTCollectionListView(flow: $flow)
            case .detail(let contractAddress):
                NFTCollectionSwipeView(flow: $flow, viewModel: NFTCollectionSwipeViewModel(contractAddress: contractAddress))
            }
        }
    }
}

struct NFTCollectionFlowView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionFlowView(flow: .list)
    }
}
