//
//  NiftyApp.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import SDWebImage
import SDWebImageSVGCoder
import SwiftUI

enum Tab: String {
    case nfts
    case collections
    case savedNFTs
}

@main
struct NiftyApp: App {
    
    @State var selectedTab: Tab = .nfts
    
    init() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppGradient()
                
                TabView(selection: $selectedTab) {
                    NFTListView().tag(Tab.nfts)
                    NFTCollectionFlowView().tag(Tab.collections)
                    NFTCollectionSwipeView(flow: .constant(.list)).tag(Tab.savedNFTs)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .ignoresSafeArea(.all, edges: .bottom)
                
                VStack {
                    Spacer()
                    TabBar(selectedTab: $selectedTab)
                }
                .padding([.bottom], 20)
            }
        }
    }
}
