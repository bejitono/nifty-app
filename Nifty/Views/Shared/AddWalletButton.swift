//
//  AddWalletButton.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

struct AddWalletButton: View {
    
    @Binding var address: String
    @Binding var loading: Bool
    var evaluate: (String) -> Bool
    var action: (String) -> Void
    
    var body: some View {
        Button(action: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
                action(address)
            }
        }) {
            if evaluate(address) {
                if loading {
                    ProgressView()
                        .shadow(radius: 10)
                } else {
                    Image(systemName: "checkmark.circle.fill")
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .scaleEffect(1.5)
                        .shadow(radius: 10)
                }
            } else {
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
                address: .constant("sdfsf"),
                loading: .constant(false),
                evaluate: { _ in return true },
                action: { _ in }
            )
            AddWalletButton(
                address: .constant("sdfsf"),
                loading: .constant(true),
                evaluate: { _ in return true },
                action: { _ in }
            )
            AddWalletButton(
                address: .constant("sdfsf"),
                loading: .constant(false),
                evaluate: { _ in return false },
                action: { _ in }
            )
        }
    }
}
