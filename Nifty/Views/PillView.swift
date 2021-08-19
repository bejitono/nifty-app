//
//  PillView.swift
//  Nifty
//
//  Created by Stefano on 16.08.21.
//

import SwiftUI

struct PillView: View {
    
    let text: String
    
    var body: some View {
        Text(text)
            .font(.callout)
            .padding(EdgeInsets(top: 3, leading: 10, bottom: 3, trailing: 10))
            .background(Color.gray.opacity(0.4))
            .clipShape(Capsule())
            .shadow(radius: 5)
    }
}

struct PillView_Previews: PreviewProvider {
    static var previews: some View {
        PillView(text: "#21341256")
    }
}
