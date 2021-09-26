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
    
    init(viewModel: NFTListViewModel = NFTListViewModel(user: User(wallet: Wallet(address: "0xD3e9D60e4E4De615124D5239219F32946d10151D")))) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppGradient()
                VStack {
                    ScrollView {
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
                    }
                    .navigationTitle("My NFTs")
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

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 20
    static let shadowYOffset: CGFloat = 15
    static let shadowXOffset: CGFloat = 0
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFTListView()
    }
}
