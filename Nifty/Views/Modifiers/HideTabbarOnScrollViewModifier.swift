//
//  HideTabbarOnScrollViewModifier.swift
//  Nifty
//
//  Created by Stefano on 03.10.21.
//

import SwiftUI

struct HideTabbarOnScrollViewModifier: ViewModifier {
    
    @Binding var showTab: Bool
    @Binding var scrollPosition: CGFloat
    
    func body(content: Content) -> some View {
        content
            .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { newPosition in
                // TODO: Logic should probably be in view model
                defer { scrollPosition = newPosition }
                guard newPosition < -50 else {
                    showTab = true
                    return
                }
                if scrollPosition > newPosition {
                    showTab = false
                } else {
                    showTab = true
                }
            }
            .onAppear {
                showTab = true
            }
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

extension View {
    
    func hideTabbar(show: Binding<Bool>, scrollPosition: Binding<CGFloat>) -> some View {
        modifier(HideTabbarOnScrollViewModifier(showTab: show, scrollPosition: scrollPosition))
    }
}
