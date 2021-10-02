//
//  PrimaryButtonStyle.swift
//  Nifty
//
//  Created by Stefano on 02.10.21.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    let wide: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(6)
            .frame(
                maxWidth: wide ? .infinity : nil,
                minHeight: 38
            )
            .background(Color.black)
            .clipShape(Capsule())
            .shadow(
                color: .gray,
                radius: .cornerRadius,
                x: .shadowXOffset,
                y: .shadowYOffset
            )
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 10
    static let shadowYOffset: CGFloat = 5
    static let shadowXOffset: CGFloat = 0
}

