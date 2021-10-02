//
//  NFTView.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import AVKit
import SkeletonUI
import SwiftUI

struct NFTView: View, Equatable {
    
    let nft: NFTViewModel

    var body: some View {
        VStack {
            ZStack {
                VStack {
                    if let media = nft.media {
                        switch media.type {
                        case .image:
                            if let url = URL(string: media.url) {
                                switch media.fileType {
                                case .svg:
                                    ZoomableScrollView {
                                        GeometryReader { geo in
                                            SVGImageView(url: url, size: geo.size)
                                                .clipShape(RoundedRectangle(cornerRadius: 7))
                                        }
                                    }
                                default:
                                    if let image = UIImage(contentsOfFile: url.path) {
                                        ZoomableScrollView {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(5)
                                                .padding([.top, .leading, .trailing], 20)
                                        }
                                    }
                                }
                            }
                        case .staticImage:
                            if let image = UIImage(named: media.url) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 250, height: 250, alignment: .center)
                            }
                        case .video:
                            if let url = URL(string: media.url) {
                                PlayerLoopView(url: url)
                            }
                            // MP3?
                        default:
                            EmptyView() // TODO
                        }
                    }
                }
                .skeleton(with: nft.isLoading)
                .shape(type: .rectangle)
                .frame(
                    maxWidth: .infinity,
                    minHeight: 350,
                    maxHeight: 350,
                    alignment: .center
                )
            }
            VStack(alignment: .center, spacing: 10) {
                Title2(nft.name)
                PillView(text: "#\(nft.tokenId)")
            }
            .padding()
        }
    }
}

// MARK: - Constants

private extension CGFloat {
    static let cornerRadius: CGFloat = 5
    static let shadowYOffset: CGFloat = 5
    static let shadowXOffset: CGFloat = 0
}

struct NFTView_Previews: PreviewProvider {
    static var previews: some View {
        NFTView(nft: NFTViewModel(contractAddress: "0x0000", permalink: ""))
    }
}
