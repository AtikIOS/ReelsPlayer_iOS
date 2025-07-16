//
//  VideoContainer.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
//


import Foundation
import UIKit
import AVFoundation

class VideoContainer {
    
    var url: String
    var shouldPlay: Bool = false {
        didSet {
            if shouldPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    var playOn: Bool {
        didSet {
            player.isMuted = VideoPlayerController.sharedVideoPlayer.mute
            playerItem.preferredPeakBitRate = VideoPlayerController.sharedVideoPlayer.preferredPeakBitRate
            if playOn && playerItem.status == .readyToPlay {
                player.play()
            } else {
                player.pause()
            }
        }
    }
    let player: AVPlayer
    let playerItem: AVPlayerItem
    init(player: AVPlayer, item: AVPlayerItem, url: String) {
        self.player = player
        self.playerItem = item
        self.url = url
        playOn = false
    }
}

