//
//  NFTCollectionSwipeView.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SDWebImageSwiftUI
import SwiftUI

struct NFTCollectionSwipeView: View {
    
    @State var side = CGSize.zero
    @State var movingItem: Int?
    
    @ObservedObject var viewModel: NFTCollectionSwipeViewModel
    
    init(viewModel: NFTCollectionSwipeViewModel = NFTCollectionSwipeViewModel(contractAddress: "0xc3f733ca98e0dad0386979eb96fb1722a1a05e69")) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                // TODO: make data source generic
                ForEach(Array(viewModel.currentNFTs.enumerated()), id: \.element) { index, nft in
                    NFTImageView(nft: nft)
                        .cardStyle()
                        .frame(maxHeight: 550)
                        .padding()
                        .offset(x: 0, y: 25 * CGFloat(index))
                        .scaleEffect(scale(index: index, total: viewModel.currentNFTs.count))
                        .rotation3DEffect(
                            .degrees(index == movingItem ? Double(side.width) * 0.1 : 0),
                            axis: (x: 0, y: 0, z: 1)
                        )
                        .offset(x: index == movingItem ? side.width : 0)
                        .animation(.easeInOut(duration: 0.3))
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    self.side = value.translation
                                    self.movingItem = index
                                }
                                .onEnded { value in
                                    let swipedLeft = value.location.x < value.startLocation.x - 100
                                    let swipedRight = value.location.x > value.startLocation.x + 100
                                    
                                    if swipedLeft || swipedRight {
                                        withAnimation(Animation.easeInOut(duration: 0.3)){
                                            self.side = CGSize(width: swipedRight ? 600 : -600, height: self.side.height)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            viewModel.swiped(nft, at: index, to: swipedLeft ? .left : .right)
                                            self.movingItem = nil
                                        }
                                    } else {
                                        self.side = .zero
                                    }
                                }
                        )
                }
            }
            .offset(x: 0, y: 25 * CGFloat(viewModel.currentNFTs.count) * -1)
        }
    }
    
    private func scale(index: Int, total: Int) -> CGFloat {
        (1 + (CGFloat(index + 1) / CGFloat(total)) * 0.2) - 0.2
    }
}

struct NFTImageView: View {
    
    let nft: NFTViewModel
    
    var body: some View {
        VStack {
            VStack {
                WebImage(url: URL(string: nft.imageURL ?? ""))
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 350,
                maxHeight: 350,
                alignment: .center
            )
            VStack(alignment: .center, spacing: 10) {
                Title2(nft.name)
                PillView(text: "#\(nft.tokenId)")
            }
            .padding()
        }
    }
}

struct NFTCollectionSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionSwipeView()
    }
}
