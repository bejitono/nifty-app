//
//  CardModifier.swift
//  Nifty
//
//  Created by Stefano on 02.09.21.
//

import SwiftUI

struct CardModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
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

extension View {
    
    func cardStyle() -> some View {
        self.modifier(CardModifier())
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 20
    static let shadowYOffset: CGFloat = 15
    static let shadowXOffset: CGFloat = 0
}
