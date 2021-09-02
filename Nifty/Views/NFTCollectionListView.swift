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
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .center
                            )
                            .background(Color.white)
                            .cornerRadius(.cornerRadius)
                            .shadow(
                                color: .gray,
                                radius: .cornerRadius,
                                x: .shadowXOffset,
                                y: .shadowYOffset
                            )
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

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 20
    static let shadowYOffset: CGFloat = 15
    static let shadowXOffset: CGFloat = 0
}

struct NFTCollectionListView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionListView()
    }
}
