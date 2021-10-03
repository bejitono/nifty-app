//
//  NFTCollectionListView.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SwiftUI

struct NFTCollectionListView: View {
    
    @Binding var showTab: Bool // Should ideally not be aware of the tab view
    @ObservedObject var viewModel: NFTCollectionListViewModel
    
    init(showTab: Binding<Bool>, viewModel: NFTCollectionListViewModel = NFTCollectionListViewModel(user: User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D")))) {
        self.viewModel = viewModel
        self._showTab = showTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
            AppGradient()
                let list = ScrollView {
                    LazyVStack(spacing: 40) {
                        ForEach(viewModel.collectionViewModels, id: \.id) { collection in
                            NavigationLink(
                                destination: NFTCollectionSwipeView(
                                    viewModel: NFTCollectionSwipeViewModel(collectionName: collection.name, contractAddress: collection.contractAddress)
                                )
                            ) {
                                NFTCollectionView(collection: collection)
                                    .equatable()
                                    .cardStyle()
                                    .onAppear {
                                        showTab = true
                                        viewModel.fetchCollectionIfNeeded(for: collection)
                                    }
                            }
                            .simultaneousGesture(
                                TapGesture().onEnded {
                                    showTab = false
                                    vibrate(.heavy)
                                }
                            )
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
                }
                .navigationTitle("Explore Collections")
                if #available(iOS 15.0, *) {
                    list
//                    .searchable(
//                        text: $viewModel.searchText,
//                        placement: .navigationBarDrawer(displayMode: .always)
//                    )
                } else {
                    list
                }
            }
        }
    }
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct NFTCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionListView(showTab: .constant(true))
    }
}
