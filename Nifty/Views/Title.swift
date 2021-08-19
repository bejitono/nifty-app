//
//  Title.swift
//  Nifty
//
//  Created by Stefano on 19.08.21.
//

import SwiftUI

struct Title: View {
    
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.title)
            .bold()
            .multilineTextAlignment(.leading)
    }
}


struct Title2: View {
    
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.title2)
            .bold()
            .multilineTextAlignment(.leading)
    }
}
