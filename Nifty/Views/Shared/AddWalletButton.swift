//
//  AddWalletButton.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

enum AddWalletButtonState {
    case loading
    case invalid
    case valid
}

struct AddWalletButton: View {
    
    @Binding var state: AddWalletButtonState
    var onPress: () -> Void
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.055) {
                onPress()
            }
        }) {
            
            switch state {
            case .loading:
                ProgressView()
                    .shadow(radius: 10)
            case .valid:
                Image(systemName: "checkmark.circle.fill")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.white)
                    .scaleEffect(1.5)
                    .shadow(radius: 10)
            case .invalid:
                Image(systemName: "xmark.circle.fill")
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.red)
                    .scaleEffect(1.5)
                    .shadow(radius: 10)
            }
        }
        .buttonStyle(ScaleEffectStyle())
    }
}

struct ScaleEffectStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.5 : 1.0)
            .animation(.linear(duration: 0.1))
    }
}

struct AddWalletButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddWalletButton(
                state: .constant(.valid)) {
                    print("hi")
                }
            AddWalletButton(
                state: .constant(.invalid)) {
                    print("hi")
                }
            AddWalletButton(
                state: .constant(.loading)) {
                    print("hi")
                }
        }
    }
}
