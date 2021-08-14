//
//  ContentView.swift
//  Nifty
//
//  Created by Stefano on 08.08.21.
//

import SwiftUI

struct NFTListView: View {
    
    @ObservedObject var viewModel: NFTListViewModel = NFTListViewModel()
    
    init() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().tableFooterView = UIView()
    }
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
                .listRowBackground(Color.clear)
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
