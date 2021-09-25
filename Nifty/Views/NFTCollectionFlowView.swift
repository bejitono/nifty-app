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
    
    private let factory = NFTCollectionFactory()
    private let user: User
    
    init(user: User = User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D"))) {
        self.user = user
    }
    
    var body: some View {
        VStack {
            switch flow {
            case .list:
                factory.buildNFTCollectionList(user: user, flow: $flow)
            case .detail(let contractAddress):
                NFTCollectionSwipeView(flow: $flow, viewModel: NFTCollectionSwipeViewModel(contractAddress: contractAddress))
            }
        }
    }
}

struct NFTCollectionFlowView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionFlowView(user: User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D")))
    }
}
