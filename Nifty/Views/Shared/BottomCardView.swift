//
//  BottomCardView.swift
//  Nifty
//
//  Created by Stefano on 14.08.21.
//

import SwiftUI

struct BottomCardView<Content: View, Model>: View {
    
    @Binding private var show: Bool
    @Binding private var model: Model
    @State private var showFull = false
    @State private var viewState = CGSize.zero
    @State private var bottomState = CGSize.zero
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    private let screen = UIScreen.main.bounds
    private let content: Content
    
    init(show: Binding<Bool>, model: Binding<Model>, @ViewBuilder content: (Model) -> Content) {
        self._show = show
        self._model = model
        self.content = content(model.wrappedValue)
    }
    
    // TODO: make content only as high as show in the screen, instead of simple spacer
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 20) {
                Rectangle()
                    .frame(width: 40, height: 5)
                    .cornerRadius(3)
                    .opacity(0.1)
                content
                    .padding([.bottom], 20)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 35)
            .padding(.bottom, 50)
            .padding(.horizontal, 20)
            .background(BlurView(style: .systemThinMaterial))
            .cornerRadius(30, corners: [.topLeft, .topRight])
            .offset(y: show ? screen.height - geometry.size.height - 50 : screen.height)
            .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0))
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // TODO: get rid of absolute values
                        guard value.translation.height > -50 else { return }
                        self.bottomState = value.translation
                    }
                    .onEnded { value in
                        if self.bottomState.height > 50 ||
                            value.predictedEndTranslation.height > 50 {
                            show = false
                        }
                        self.bottomState.height = 0
                    }
            )
        }
    }
}
