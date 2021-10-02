//
//  View+Vibration.swift
//  Nifty
//
//  Created by Stefano on 02.10.21.
//

import SwiftUI

extension View {
    
    func vibrate(_ type: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: type)
        generator.impactOccurred()
    }
}
