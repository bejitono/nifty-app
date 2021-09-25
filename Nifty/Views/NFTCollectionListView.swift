//
//  NFTCollectionListView.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SwiftUI

struct NFTCollectionListView: View {
    
    @ObservedObject var viewModel: NFTCollectionListViewModel
    @Binding var flow: NFTCollectionFlow
    
    init(flow: Binding<NFTCollectionFlow>, viewModel: NFTCollectionListViewModel = NFTCollectionListViewModel(user: User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D")))) {
        self._flow = flow
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            AppGradient()
            VStack {
                HStack {
                    Title("Explore Collections")
                    Spacer()
                }
                .frame(height: 15)
                .padding()
                ScrollView {
                    LazyVStack(spacing: 40) {
                        ForEach(viewModel.collectionViewModels, id: \.id) { collection in
                            NFTCollectionView(collection: collection)
                                .equatable()
                                .cardStyle()
                                .onTapGesture {
                                    vibrate(.heavy)
                                    self.flow = .detail(contractAddress: collection.contractAddress)
                                }
                                .onAppear {
                                    viewModel.fetchCollectionIfNeeded(for: collection)
                                }
                        }
                    }
                    .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
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
        NFTCollectionListView(flow: .constant(.list))
    }
}
