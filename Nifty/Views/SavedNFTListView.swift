//
//  SavedNFTListView.swift
//  Nifty
//
//  Created by Stefano on 15.09.21.
//

import SwiftUI

struct SavedNFTListView: View {
    
    @ObservedObject var viewModel: SavedNFTListViewModel
    @Binding var showTab: Bool
    @Environment(\.openURL) var openURL
    
    @State private var scrollPosition = CGFloat.zero
    
    init(showTab: Binding<Bool>, viewModel: SavedNFTListViewModel = SavedNFTListViewModel()) {
        self.viewModel = viewModel
        self._showTab = showTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient()
                if $viewModel.nftViewModels.wrappedValue.isEmpty {
                    VStack(spacing: 10) {
                        Text("Looks empty 👻")
                        Text("When you swipe through collections your liked NFTs will appear here.")
                    }
                    .padding(20)
                    .multilineTextAlignment(.center)
                } else {
                    ScrollView {
                        ZStack {
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
                            GeometryReader { proxy in
                                let offset = proxy.frame(in: .named("scroll")).minY
                                Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                            }
                        }
                    }
                    .hideTabbar(show: $showTab, scrollPosition: $scrollPosition)
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
                            if let url = URL(string: nft.permalink
                                             + AppConstants.referralQueryItem) {
                                Button {
                                    openURL(url)
                                    viewModel.onLinkTap()
                                } label: {
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
            .navigationTitle("Favorites")
            .navigationBarItems(
                trailing: Button(action: {
                    withAnimation(.easeOut) {
                        viewModel.deleteSavedNFTs()
                    }
                }, label: {
                    Image(systemName: "trash")
                })
            )
            .onAppear {
                viewModel.fetchSavedNFTs()
            }
        }
        .onChange(of: viewModel.showDetails) { showDetails in
            showTab = !showDetails
        }
    }
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct SavedNFTListView_Previews: PreviewProvider {
    static var previews: some View {
        SavedNFTListView(showTab: .constant(true))
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
