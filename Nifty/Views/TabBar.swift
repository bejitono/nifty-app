//
//  TabBar.swift
//  Nifty
//
//  Created by Stefano on 04.09.21.
//

import SwiftUI

struct TabBar: View {
    
    @State var nftListActive = true
    @State var swipeCollectionsActive = false
    @State var savedNFTsActive = false
    
    var body: some View {
        VStack {
            HStack {
                TabBarImageView(name: "tray.full.fill", active: $nftListActive)
                Spacer()
                TabBarImageView(name: "rectangle.stack.fill", active: $swipeCollectionsActive)
                Spacer()
                TabBarImageView(name: "bag.fill", active: $savedNFTsActive)
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
        TabBar()
    }
}
