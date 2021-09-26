//
//  SavedNFTListView.swift
//  Nifty
//
//  Created by Stefano on 15.09.21.
//

import SwiftUI

struct SavedNFTListView: View {
    
    @ObservedObject var viewModel: SavedNFTListViewModel
    @State var show: Bool = false
    
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
                                    show.toggle()
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
            BottomCardView(show: $show, model: $viewModel.nftViewModels) { nft in
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                Text("sdfsdf")
                
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
