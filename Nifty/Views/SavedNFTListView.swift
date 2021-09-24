//
//  SavedNFTListView.swift
//  Nifty
//
//  Created by Stefano on 15.09.21.
//

import SwiftUI

struct SavedNFTListView: View {
    
    @ObservedObject var viewModel: SavedNFTListViewModel
    
    init(viewModel: SavedNFTListViewModel = SavedNFTListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack {
                Title("My NFTs")
                Spacer()
                Image(systemName: "trash")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    //                    .foregroundColor(.white)
                    .padding()
                    .onTapGesture {
                        withAnimation(.easeOut) {
                            viewModel.deleteSavedNFTs()
                        }
                    }
            }
            .frame(height: 15)
            .padding()
            ScrollView {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.nftViewModels, id: \.id) { nft in
                        SavedNFTView(nft: nft)
                            .equatable()
                            .cardStyle()
                            .onTapGesture {
                                vibrate(.heavy)
                                //
                            }
                    }
                }
                .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
            }
            .onAppear {
                viewModel.fetchSavedNFTs()
            }
        }
    }
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct SavedNFTListView_Previews: PreviewProvider {
    static var previews: some View {
        SavedNFTListView()
    }
}

import SDWebImageSwiftUI

struct SavedNFTView: View, Equatable {
    
    let nft: SavedNFTViewModel
    
    var body: some View {
        VStack {
            VStack {
                WebImage(url: URL(string: nft.imageURL ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
                    .padding([.top, .leading, .trailing], 20)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 350,
                maxHeight: 350,
                alignment: .center
            )
            VStack(alignment: .center, spacing: 10) {
                Title2(nft.name)
            }
            .padding()
        }
    }
}
