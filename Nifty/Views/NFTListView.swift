//
//  ContentView.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import AVKit
import SwiftUI

struct NFTListView: View {
    
    @ObservedObject var viewModel: NFTListViewModel = NFTListViewModel()
    
    // do loop
    
    // https://schwiftyui.com/swiftui/playing-videos-on-a-loop-in-swiftui/
    // https://stackoverflow.com/questions/27808266/how-do-you-loop-avplayer-in-swift
    
    var body: some View {
        List {
            VStack(spacing: 40) {
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
        NFTListView()
    }
}
