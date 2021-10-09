//
//  ContentView.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import SwiftUI
import SVGKit

struct NFTListView: View {
    
    @ObservedObject var viewModel: NFTListViewModel
    @Binding var showTab: Bool
    @State private var scrollPosition = CGFloat.zero
    
    init(
        showTab: Binding<Bool>,
        viewModel: NFTListViewModel = NFTListViewModel(user: User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D")))) {
        self.viewModel = viewModel
        self._showTab = showTab
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient()
                VStack {
                    ScrollView {
                        ZStack {
                            LazyVStack(spacing: 40) {
                                // TODO: view for empty and error state
                                ForEach(viewModel.nftsViewModel, id: \.id) { nft in
                                    NFTView(nft: nft)
                                        .equatable()
                                        .cardStyle()
                                        .onAppear {
                                            viewModel.fetchNFTsIfNeeded(for: nft)
                                        }
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
                    .navigationTitle("My NFTs")
                    .coordinateSpace(name: "scroll")
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
                                VStack {
                                    Image(uiImage: Images.share)
                                }
                                .frame(width: 40, height: 40)
                                .onTapGesture {
                                    viewModel.share(nft: nft)
                                }
                            }
                            Title(nft.name)
                            Text(nft.description ?? nft.name)
                                .multilineTextAlignment(.leading)
                            Text("Attributes")
                                .font(.title2)
                                .bold()
                                .multilineTextAlignment(.leading)
                            MultilineHStack(models: nft.attributes) { attribute in
                                AttributeView(
                                    trait: attribute.trait,
                                    value: attribute.value.isEmpty ? "n/a" : attribute.value
                                )
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
            }.sheet(isPresented: $viewModel.showShareMedia) {
                if let urlString = viewModel.sharedMedia?.url,
                   let url = URL(string: urlString),
                   let image = viewModel.sharedMedia?.fileType == .svg
                        ? svgImage(contentsOfFile: url.path)
                        : UIImage(contentsOfFile: url.path) {
                    ShareSheet(activityItems: ["", image]) { _,_,_,_ in
                        viewModel.showDetails = false
                    }
                }
            }
        }
        .onChange(of: viewModel.showDetails) { showDetails in
            showTab = !showDetails
        }
    }
    
    
    func svgImage(contentsOfFile: String) -> UIImage {
        guard let svgImage = SVGKImage(contentsOfFile: contentsOfFile) else {
            return SVGKImage().uiImage
        }
        return svgImage.uiImage
    }
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}

struct NFTScrollView: View {
    
    let nfts: [NFTViewModel]
    let onAppear: (NFTViewModel) -> Void
    let onTapGesture: (NFTViewModel) -> Void
    
    var body: some View {
        ScrollView {
            ZStack {
                LazyVStack(spacing: 40) {
                    // TODO: view for empty and error state
                    ForEach(nfts, id: \.id) { nft in
                        NFTView(nft: nft)
                            .equatable()
                            .cardStyle()
                            .onAppear {
                                onAppear(nft)
                            }
                            .onTapGesture {
                                vibrate(.heavy)
                                onTapGesture(nft)
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
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 20
    static let shadowYOffset: CGFloat = 15
    static let shadowXOffset: CGFloat = 0
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFTListView(showTab: .constant(true))
    }
}
