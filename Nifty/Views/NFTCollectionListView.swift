//
//  NFTCollectionListView.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SwiftUI

struct NFTCollectionListView: View {
    
    @ObservedObject var viewModel: NFTCollectionListViewModel
    
    init(viewModel: NFTCollectionListViewModel = NFTCollectionListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            AppGradient()
            ScrollView {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.collectionViewModels, id: \.id) { collection in
                        NFTCollectionView(collection: collection)
                            .cardStyle()
                            .onTapGesture {
                                vibrate(.success)
                                // viewmodel
                            }
                    }
                }
                .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
            }
        }
    }
    
    func vibrate(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

struct NFTCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionListView()
    }
}
