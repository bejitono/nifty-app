//
//  PlayerView.swift
//  Nifty
//
//  Created by Stefano on 14.08.21.
//

import SwiftUI
import AVKit
import AVFoundation

struct PlayerLoopView: UIViewRepresentable {
    
    let url: URL
    
    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(url: url)
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerLoopView>) {
    }
}

final class LoopingPlayerUIView: UIView {
    
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    
    init(frame: CGRect = .zero, url: URL) {
        super.init(frame: frame)
        let asset = AVAsset(url: url)
        let item = AVPlayerItem(asset: asset)
        
        // Setup the player
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
         
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player, templateItem: item)

        // Start the movie
        player.play()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
