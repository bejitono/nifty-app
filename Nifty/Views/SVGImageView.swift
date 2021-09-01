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
    var size: CGSize
    
    func makeUIView(context: Context) -> SVGKFastImageView {
        let svgImage = SVGKImage(contentsOfFile: url.path)
        svgImage?.size = size
        let imageView = SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
        imageView?.tintColor = .black
        imageView?.backgroundColor = .black
        return imageView ?? SVGKFastImageView(svgkImage: svgImage ?? SVGKImage())
    }
    
    func updateUIView(_ uiView: SVGKFastImageView, context: Context) { }
}
