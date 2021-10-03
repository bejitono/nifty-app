//
//  TabBar.swift
//  Nifty
//
//  Created by Stefano on 04.09.21.
//

import SwiftUI

struct TabBar: View {
    
    @Binding var selectedTab: Tab
    @Binding var show: Bool
    
    @State private var nftListActive = true
    @State private var swipeCollectionsActive = false
    @State private var savedNFTsActive = false
    
    var body: some View {
        VStack {
            HStack {
                TabBarImageView(name: "rectangle.stack.fill", active: $nftListActive)
                    .onTapGesture {
                        nftListActive = true
                        swipeCollectionsActive = false
                        savedNFTsActive = false
                        selectedTab = .nfts
                    }
                Spacer()
                TabBarImageView(name: "magnifyingglass", active: $swipeCollectionsActive)
                    .onTapGesture {
                        nftListActive = false
                        swipeCollectionsActive = true
                        savedNFTsActive = false
                        selectedTab = .collections
                    }
                Spacer()
                TabBarImageView(name: "heart.fill", active: $savedNFTsActive)
                    .onTapGesture {
                        nftListActive = false
                        swipeCollectionsActive = false
                        savedNFTsActive = true
                        selectedTab = .savedNFTs
                    }
            }
            .padding([.leading, .trailing], 40)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: 65,
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
        .padding([.leading, .trailing], 30)
        .offset(y: show ? 0 : 120)
        .animation(.easeInOut, value: show)
    }
}

struct TabBarImageView: View {
    
    let name: String
    @Binding var active: Bool
    
    var body: some View {
        Image(systemName: name)
            .font(.system(size: 27))
            .foregroundColor(active ? .accentColor : Color.gray.opacity(0.5))
            .background(Color.white)
            .scaleEffect(active ? 1.25 : 1)
            .animation(.interpolatingSpring(stiffness: 100, damping: 10, initialVelocity: 20), value: active)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 20
    static let shadowYOffset: CGFloat = 15
    static let shadowXOffset: CGFloat = 0
}

struct TabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBar(selectedTab: .constant(.nfts), show: .constant(true))
    }
}
