//
//  NFTView.swift
//  Nifty
//
//  Created by Stefano on 12.08.21.
//

import AVKit
import SwiftUI

struct NFTView: View {
    
    let nft: NFTViewModel
    
    var body: some View {
        VStack {
            VStack {
                if let media = nft.media {
                    switch media.type {
                    case .image:
                        if let image = UIImage(contentsOfFile: media.imageURL.path) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                    case .video:
                        let avPlayer = AVPlayer(url: media.imageURL)
                        VideoPlayer(player: avPlayer)
//                            .frame(height: 400)
                            .onAppear {
                                avPlayer.play()
                            }
                    default:
                        fatalError()
                    }
                }
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 350,
                maxHeight: 350,
                alignment: .center
            )
            Text(nft.tokenId)
            Text(nft.name)
            Text(nft.description)
        }
    }
}

struct NFTView_Previews: PreviewProvider {
    static var previews: some View {
        NFTView(nft: NFTViewModel(contractAddress: "0x0000"))
    }
}