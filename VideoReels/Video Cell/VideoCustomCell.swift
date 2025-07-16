//
//  VideoCustomCell.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
//


import UIKit
import AVFoundation

class VideoCustomCell: UITableViewCell {
    @IBOutlet weak var lblChanelName: UILabel!
    @IBOutlet weak var lblDescription : UILabel!
    @IBOutlet weak var btnPlayPause : UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    var playerController: VideoPlayerController?
    var videoLayer: AVPlayerLayer = AVPlayerLayer()
    
    var videoURL: String? {
        didSet {
            if let videoURL = videoURL {
                VideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
            }
            videoLayer.isHidden = videoURL == nil
        }
    }
    
    override func awakeFromNib() {
        self.contentView.backgroundColor = .random
        videoLayer.backgroundColor = UIColor.clear.cgColor
        videoLayer.videoGravity = AVLayerVideoGravity.resize
        thumbnailImageView.layer.addSublayer(videoLayer)
        selectionStyle = .none
    }
    
    override func prepareForReuse() {
        thumbnailImageView.imageURL = nil
        super.prepareForReuse()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoLayer.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
    }
    
    func configureCell(data: VideoObject) {
        self.thumbnailImageView.imageURL = data.thumbnailURL
        self.videoURL = data.videoURL
        self.lblChanelName.text = data.chanelName
        self.lblDescription.text = data.videoDescription
    }
    
    @IBAction func btnPlayPauseTapped(_ sender: UIButton) {
        guard let player = VideoPlayerController.sharedVideoPlayer.currentVideoContainer()?.player else { return }

        if player.timeControlStatus == .playing {
            VideoPlayerController.sharedVideoPlayer.pauseCurrentVideo()
            self.showImageTemporarilyWithBounce(on: self.btnPlayPause, imageName: "play")
        } else {
            VideoPlayerController.sharedVideoPlayer.playCurrentVideo()
            self.showImageTemporarilyWithBounce(on: self.btnPlayPause, imageName: "pause")
        }
    }

    func showImageTemporarilyWithBounce(on button: UIButton, imageName: String) {
        // Step 1: Set image and make alpha 0
        button.setBackgroundImage(UIImage(named: imageName), for: .normal)
        button.alpha = 0.0
        button.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)

        // Step 2: Animate fade-in + bounce
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 1.0,
                       options: [],
                       animations: {
            button.alpha = 1.0
            button.transform = .identity
        }, completion: { _ in
            // Step 3: After 1 second, fade out and remove image
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                UIView.animate(withDuration: 0.3, animations: {
                    button.alpha = 0.0
                }) { _ in
                    button.setBackgroundImage(nil, for: .normal)
                    button.alpha = 1.0
                }
            }
        })
    }


}

extension VideoCustomCell: PlayVideoLayerContainer {
    func visibleVideoHeight() -> CGFloat {
        let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(
            thumbnailImageView.frame,
            from: thumbnailImageView)
        guard let videoFrame = videoFrameInParentSuperView,
              let superViewFrame = superview?.frame else {
                  return 0
              }
        let visibleVideoFrame = videoFrame.intersection(superViewFrame)
        return visibleVideoFrame.size.height
    }
}
