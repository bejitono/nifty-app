//
//  BackButtonView.swift
//  Nifty
//
//  Created by Stefano on 15.09.21.
//

import SwiftUI

struct BackButtonView: View {
    
    var body: some View {
        HStack {
            Image(systemName: "arrow.left")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                //                    .foregroundColor(.white)
                .padding()
            Spacer()
        }
    }
}

struct BackButtonView_Previews: PreviewProvider {
    static var previews: some View {
        BackButtonView()
    }
}
