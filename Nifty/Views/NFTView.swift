//
//  NFTView.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import AVKit
import SkeletonUI
import SwiftUI

struct NFTView: View {
    
    let nft: NFTViewModel
    
    var body: some View {
        VStack {
            ZStack {
                VStack {
                    if let media = nft.media {
                        switch media.type {
                        case .image:
                            if let url = URL(string: media.url), let image = UIImage(contentsOfFile: url.path) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        case .staticImage:
                            if let image = UIImage(named: media.url) {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            }
                        case .video:
                            if let url = URL(string: media.url) {
                                let avPlayer = AVPlayer(url: url)
                                VideoPlayer(player: avPlayer)
                                    //                            .frame(height: 400)
                                    .onAppear {
                                        avPlayer.play()
                                    }
                            }
                        default:
                            fatalError()
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
            HStack(alignment: .center, spacing: 10) {
                Text(nft.name)
                Text("#\(nft.tokenId)")
            }
            Text(nft.description)
        }
    }
}

struct NFTView_Previews: PreviewProvider {
    static var previews: some View {
        NFTView(nft: NFTViewModel(contractAddress: "0x0000"))
    }
}
