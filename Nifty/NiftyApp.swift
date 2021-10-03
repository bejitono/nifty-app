//
//  NiftyApp.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageVideoCoder // TODO: remove and use avkit instead, performance is very slow
import SDWebImageWebPCoder
import SwiftUI

enum Tab: String {
    case nfts
    case collections
    case savedNFTs
}

@main
struct NiftyApp: App {
    
    @State private var showTab = true
    @State private var selectedTab: Tab = .nfts
    // Should have a separate view model instead of using new wallet VM directly
    @ObservedObject var newWalletViewModel: NewWalletViewModel = NewWalletViewModel()
    
    private let nftFactory: NFTFactory = NFTFactory()
    private let nftCollectionFactory: NFTCollectionFactory = NFTCollectionFactory()
    private let savedNFTFactory: SavedNFTFactory = SavedNFTFactory()
    private let user: User?
    
    init() {
        self.user = UserCache().get()
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageVideoCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        UITabBar.appearance().isHidden = true
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                AppGradient()
                if let user = newWalletViewModel.user {
                    TabView(selection: $selectedTab) {
                        nftFactory.buildNFTList(user: user).tag(Tab.nfts)
                        nftCollectionFactory.buildNFTCollectionList(user: user, showTab: $showTab).tag(Tab.collections)
                        savedNFTFactory.buildSavedNFTList().tag(Tab.savedNFTs)
                    }
                    .ignoresSafeArea(.all, edges: .bottom)
                    
                    VStack {
                        Spacer()
                        TabBar(selectedTab: $selectedTab, show: $showTab)
                    }
                    .padding([.bottom], 20)
                } else {
                    NewWalletView(viewModel: newWalletViewModel)
                }
            }
        }
    }
}
