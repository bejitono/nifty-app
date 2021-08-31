//
//  SVGImageView.swift
//  Nifty
//
//  Created by Stefano on 31.08.21.
//

import SwiftUI
import SVGKit

struct SVGImageView: UIViewRepresentable {
    
    var url: URL
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(contentsOf: url)
        return SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) { }
}
