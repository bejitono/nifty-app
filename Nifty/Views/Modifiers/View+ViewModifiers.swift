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
        .ignoresSafeArea(.all)
    }
}
