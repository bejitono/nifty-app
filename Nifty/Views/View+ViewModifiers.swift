//
//  View+ViewModifiers.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

extension View {
    
    func appBackground() -> some View {
        self.background(AppGradient())
        .ignoresSafeArea()
    }
}

struct AppGradient: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(
                colors: [
                    Colors.green,
                    Colors.blue,
                    Colors.purple
                ]
            ),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct Colors {
    static let green = Color(red: 3 / 255, green: 225 / 255, blue: 255 / 255)
    static let blue = Color(red: 0 / 255, green: 255 / 255, blue: 163 / 255)
    static let purple = Color(red: 220 / 255, green: 31 / 255, blue: 255 / 255)
}
