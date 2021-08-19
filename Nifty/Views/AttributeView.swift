//
//  AttributeView.swift
//  Nifty
//
//  Created by Stefano on 18.08.21.
//

import SwiftUI

struct AttributeView: View {
    
    let trait: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(trait.uppercased())
                .font(.caption)
            Text(value)
        }
        .padding(5)
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 7)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}

struct AttributeView_Previews: PreviewProvider {
    static var previews: some View {
        AttributeView(trait: "score", value: "100")
    }
}
