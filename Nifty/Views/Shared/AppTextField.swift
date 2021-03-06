//
//  AppTextField.swift
//  Nifty
//
//  Created by Stefano on 22.08.21.
//

import SwiftUI

struct AppTextField: View {
    
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .autocapitalization(.none)
            .frame(height: 30)
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .accentColor(.blue)
            .background(BlurView(style: .systemThinMaterial))
            .clipShape(Capsule())
            .overlay(
                Capsule(style: .continuous)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 3)
                    )
            )
            .font(.headline)
            .foregroundColor(.primary)
    }
}


struct AppTextField_Previews: PreviewProvider {
    static var previews: some View {
        AppTextField(placeholder: "address", text: .constant(""))
    }
}
