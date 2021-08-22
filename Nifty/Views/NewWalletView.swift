//
//  NewWalletView.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

struct NewWalletView: View {
    
    @Binding var address: String
    @Binding var loading: Bool
    var evaluate: (String) -> Bool
    var action: (String) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Paste your Ethereum address to get started")
            HStack(spacing: 15) {
                AppTextField(placeholder: "Ethereum address", text: $address)
                AddWalletButton(
                    address: $address,
                    loading: $loading,
                    evaluate: evaluate,
                    action: action
                )
            }
            .padding()
            
            Spacer()
        }
    }
}

struct NewWalletView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ZStack {
                AppGradient()
                NewWalletView(address: .constant("sdfdsfds"), loading: .constant(true)) { text in
                    print(text)
                    return true
                } action: { text in
                    print(text)
                }
            }
            
            ZStack {
                AppGradient()
                NewWalletView(address: .constant("sdfdsfds"), loading: .constant(false)) { text in
                    print(text)
                    return false
                } action: { text in
                    print(text)
                }
            }
            
            ZStack {
                AppGradient()
                NewWalletView(address: .constant("sdfdsfds"), loading: .constant(false)) { text in
                    print(text)
                    return true
                } action: { text in
                    print(text)
                }
            }
        }
    }
}
