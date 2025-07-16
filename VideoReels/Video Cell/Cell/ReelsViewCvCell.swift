//
//  ReelsViewCvCell.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
// 

import UIKit
import AVFoundation

class ReelsViewCvCell: UICollectionViewCell {

    @IBOutlet weak var viewContent: UIView!
    @IBOutlet weak var BgMusicView: UIView!
    

    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        playerLayer?.frame = self.viewContent.bounds
        self.contentView.layoutIfNeeded()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)
        player = nil
        playerLayer = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = viewContent.bounds
        self.contentView.layoutIfNeeded()
        self.viewContent.layoutIfNeeded()
    }

    func configure(with playerItem: AVPlayerItem) {
        // Clean previous player
        playerItem.preferredForwardBufferDuration = 10
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        NotificationCenter.default.removeObserver(self)

        // Setup player
        player = AVPlayer(playerItem: playerItem)
        player?.actionAtItemEnd = .none

        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = viewContent.bounds

        if let layer = playerLayer {
            viewContent.layer.insertSublayer(layer, at: 0)
        }

        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: playerItem,
                                               queue: .main) { [weak self] _ in
            self?.player?.seek(to: .zero)
            self?.player?.play()
        }
        self.contentView.layoutIfNeeded()
        self.viewContent.layoutIfNeeded()
    }

    
    func playVideo() {
        guard let player = player, player.timeControlStatus != .playing else { return }
        player.play()
        print("▶️ Playing video")
    }

    func pauseVideo() {
        guard let player = player, player.timeControlStatus == .playing else { return }
        player.pause()
        print("⏸️ Pausing video")
    }

    @IBAction func btnFavouriteAction() {
        print("❤️ Favourite clicked")
    }

    @IBAction func btnPlayPauseAction(_ sender: UIButton) {
        if player?.timeControlStatus == .playing {
            pauseVideo()
        } else {
            playVideo()
        }
    }
}
