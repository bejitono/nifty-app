//
//  NavigationLinkStyle.swift
//  Nifty
//
//  Created by Stefano on 09.10.21.
//

import SwiftUI

struct CardButtonStyle: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}
