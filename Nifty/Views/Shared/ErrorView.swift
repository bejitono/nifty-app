//
//  ErrorView.swift
//  Nifty
//
//  Created by Stefano on 09.10.21.
//

import SwiftUI

struct ErrorView: View {
    
    let message: String
    let onTapTryAgain: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(message)
            Button {
                onTapTryAgain()
            } label: {
                Text("Try again")
                    .foregroundColor(.blue)
            }
        }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(message: "Something happened", onTapTryAgain: {})
    }
}
