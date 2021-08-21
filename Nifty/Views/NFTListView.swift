//
//  ContentView.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import SwiftUI

struct NFTListView: View {
    
    @ObservedObject var viewModel: NFTListViewModel
    
    init(viewModel: NFTListViewModel = NFTListViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 40) {
                    ForEach(viewModel.nftsViewModel, id: \.id) { nft in
                        NFTView(nft: nft)
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
                                viewModel.handleTapOn(nft: nft)
                            }
                    }
                }
                .padding(EdgeInsets(top: 30, leading: 10, bottom: 30, trailing: 10))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [
                            Color(red: 3 / 255, green: 225 / 255, blue: 255 / 255),
                            Color(red: 0 / 255, green: 255 / 255, blue: 163 / 255),
                            Color(red: 220 / 255, green: 31 / 255, blue: 255 / 255)
                        ]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
            )
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
                            AttributeView(trait: attribute.trait, value: attribute.value)
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
               let image = UIImage(contentsOfFile: url.path) {
                ShareSheet(activityItems: ["", image]) { _,_,_,_ in
                    viewModel.showDetails = false
                }
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NFTListView()
    }
}
