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
    @State var swipeDirection: SwipeDirection = .none
    
    @ObservedObject var viewModel: NFTCollectionSwipeViewModel
    
    init(viewModel: NFTCollectionSwipeViewModel = NFTCollectionSwipeViewModel(
            contractAddress: "0xc3f733ca98e0dad0386979eb96fb1722a1a05e69"//"0x3b1bb53b1a42ff61b7399fc196469a742cd3e98d"
    )) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            ZStack {
                // TODO: make data source generic
                ForEach(Array(viewModel.currentNFTs.enumerated()), id: \.element) { index, nft in
                    NFTImageView(nft: nft, swipeDirection: $swipeDirection)
                        .cardStyle()
                        .frame(maxHeight: UIScreen.main.bounds.size.height * 0.6)
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
                                    
                                    let swipedLeft = value.location.x < value.startLocation.x
                                    let swipedRight = value.location.x > value.startLocation.x
                                    
                                    if swipedLeft {
                                        self.swipeDirection = .left
                                    } else if swipedRight {
                                        self.swipeDirection = .right
                                    }
                                }
                                .onEnded { value in
                                    let swipedLeft = value.location.x < value.startLocation.x - 100
                                    let swipedRight = value.location.x > value.startLocation.x + 100
                                    
                                    if swipedLeft || swipedRight {
                                        self.swipeDirection = .none
                                        withAnimation(Animation.easeInOut(duration: 0.3)){
                                            self.side = CGSize(width: swipedRight ? 600 : -600, height: self.side.height)
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                            viewModel.swiped(nft, at: index, to: swipedLeft ? .left : .right)
                                            self.movingItem = nil
                                        }
                                    } else {
                                        self.side = .zero
                                        self.swipeDirection = .none
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
    @Binding var swipeDirection: SwipeDirection
    
    var body: some View {
        VStack {
            VStack {
                WebImage(url: URL(string: nft.imageURL ?? ""))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(5)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 350,
                maxHeight: 350,
                alignment: .center
            )
            VStack(spacing: 10) {
                VStack(alignment: .center, spacing: 10) {
                    Title2(nft.name)
                    PillView(text: "#\(nft.tokenId)")
                }
                HStack {
                    CardSwipeImageView(
                        name: "xmark.circle",
                        activatedDirection: .left,
                        activatedColor: .red,
                        swipeDirection: $swipeDirection
                    )
                    Spacer()
                    CardSwipeImageView(
                        name: "checkmark.circle",
                        activatedDirection: .right,
                        activatedColor: .green,
                        swipeDirection: $swipeDirection)
                }
                .padding([.leading, .trailing], 35)
            }
            .padding()
        }
    }
}

struct CardSwipeImageView: View {
    
    let name: String
    let activatedDirection: SwipeDirection
    let activatedColor: Color
    @Binding var swipeDirection: SwipeDirection
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: 40))
            .foregroundColor(swipeDirection == activatedDirection ? activatedColor : Color.gray.opacity(0.5))
            .background(Color.white)
            .clipShape(Circle())
            .shadow(
                color: .gray,
                radius: .cornerRadius,
                x: .shadowXOffset,
                y: .shadowYOffset
            )
            .scaleEffect(swipeDirection == activatedDirection ? 1.25 : 1)
            .animation(.interpolatingSpring(stiffness: 100, damping: 10, initialVelocity: 20), value: swipeDirection)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 6
    static let shadowYOffset: CGFloat = 0
    static let shadowXOffset: CGFloat = 0
}

struct NFTCollectionSwipeView_Previews: PreviewProvider {
    static var previews: some View {
        NFTCollectionSwipeView()
    }
}
