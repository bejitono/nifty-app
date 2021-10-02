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
        NavigationView {
            ZStack {
                AppGradient()
                ScrollView {
                    LazyVStack(spacing: 40) {
                        ForEach(viewModel.nftViewModels, id: \.id) { nft in
                            SavedNFTView(nft: nft)
                                .equatable()
                                .cardStyle()
                                .onTapGesture {
                                    vibrate(.heavy)
                                    viewModel.handleTapOn(nft: nft)
                                }
                        }
                    }
                    .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
                }
                .onAppear {
                    viewModel.fetchSavedNFTs()
                }
                BottomCardView(
                    show: $viewModel.showDetails,
                    model: $viewModel.nftDetails
                ) { nft in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                PillView(text: "#\(nft.tokenId)")
                                Spacer()
                            }
                            Title(nft.name)
                            Text(nft.description)
                            if let url = URL(string: nft.permalink) {
                                Link(destination: url) {
                                    Text("View on Opensea")
                                        .foregroundColor(.white)
                                        .bold()
                                }
                                .buttonStyle(PrimaryButtonStyle(wide: true))
                                .padding(.top, 20)
                            }

                        }
                        .frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                    }
                    
                }
            }
            .navigationTitle("Saved NFTs")
            .navigationBarItems(
                trailing: Button(action: {
                    withAnimation(.easeOut) {
                        viewModel.deleteSavedNFTs()
                    }
                }, label: {
                    Image(systemName: "trash")
                })
            )
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
