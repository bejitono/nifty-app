//
//  BottomCardView.swift
//  Nifty
//
//  Created by Stefano on 14.08.21.
//

import SwiftUI

struct BottomCardView<Content: View>: View {
    
    @Binding private var state: NFTListViewModel.BottomCardState
    @State private var showFull = false
    @State private var viewState = CGSize.zero
    @State private var bottomState = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let screen = UIScreen.main.bounds
    private let content: Content
    
    init(state: Binding<NFTListViewModel.BottomCardState>, @ViewBuilder content: () -> Content) {
        self._state = state
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Rectangle()
                .frame(width: 40, height: 5)
                .cornerRadius(3)
                .opacity(0.1)
            content
            Spacer()
        }
        .frame(maxWidth: 600)
        .padding(.top, 8)
        .padding(.horizontal, 20)
        .background(BlurView(style: .systemThinMaterial))
        .cornerRadius(30)
        .offset(y: state == .closed ? screen.height : screen.height / 2 - 50)
        .offset(y: bottomState.height)
        .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
        .gesture(
            DragGesture()
                .onChanged { value in
                    self.bottomState = value.translation
                    if self.showFull {
                        self.bottomState.height += -300
                    }
                    if self.bottomState.height < -300 {
                        self.bottomState.height = -300
                    }
                }
                .onEnded { value in
                    if self.bottomState.height > 50 {
                        self.state = .closed
                    }
                    if (self.bottomState.height < -100 && !self.showFull) || (self.bottomState.height < -250 && self.showFull) {
                        self.bottomState.height = -300
                        self.showFull = true
                    } else {
                        self.bottomState = .zero
                        self.showFull = false
                    }
                }
        )
    }
}
