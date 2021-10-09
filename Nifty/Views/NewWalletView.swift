//
//  NewWalletView.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

struct NewWalletView: View {
    
    @ObservedObject private var viewModel: NewWalletViewModel
    
    init(viewModel: NewWalletViewModel = NewWalletViewModel()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Paste your ENS or Ethereum address to get started")
            HStack(spacing: 15) {
                AppTextField(placeholder: "Ethereum/ENS address", text: $viewModel.address)
                AddWalletButton(
                    state: $viewModel.buttonState,
                    onPress: viewModel.onAddNewWallet
                )
            }
            Button("Paste") {
                viewModel.handlePaste(address: UIPasteboard.general.string)
            }
            Spacer()
        }
        .padding()
        .padding(.top, 30)
    }
}

struct NewWalletView_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            ZStack {
                AppGradient()
                NewWalletView()
            }
        }
    }
}
