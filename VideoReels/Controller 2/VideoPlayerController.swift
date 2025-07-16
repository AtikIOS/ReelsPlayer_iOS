//
//  VideoPlayerController.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
//


import UIKit
import AVFoundation

protocol PlayVideoLayerContainer {
    var videoURL: String? { get set }
    var videoLayer: AVPlayerLayer { get set }
    func visibleVideoHeight() -> CGFloat
}

class VideoPlayerController: NSObject, NSCacheDelegate {
    
    static let sharedVideoPlayer = VideoPlayerController()

    var minimumLayerHeightToPlay: CGFloat = 60
    var mute = false
    var preferredPeakBitRate: Double = 1000000
    static private var playerViewControllerKVOContext = 0
    private var videoURL: String?
    private var observingURLs = [String: Bool]()
    private var videoCache = NSCache<NSString, VideoContainer>()
    private var videoLayers = VideoLayers()
    private var currentLayer: AVPlayerLayer?
    var shouldPlay: Bool = true {
        didSet {
            self.currentVideoContainer()?.shouldPlay = shouldPlay
        }
    }
    override init() {
        super.init()
        videoCache.delegate = self
    }
    /*
     Download of an asset of url if corresponding videocontainer
     is not present.
     Uses the asset to create new playeritem.
     */
    func setupVideoFor(url: String) {
        if self.videoCache.object(forKey: url as NSString) != nil {
            return
        }
        guard let URL = URL(string: url) else {
            return
        }
        let asset = AVURLAsset(url: URL)
        let requestedKeys = ["playable"]
        asset.loadValuesAsynchronously(forKeys: requestedKeys) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            /*
             Need to check whether asset loaded successfully, if not successful then don't create
             AVPlayer and AVPlayerItem and return without caching the videocontainer,
             so that, the assets can be tried to be downloaded again when need be.
             */
            var error: NSError?
            let status = asset.statusOfValue(forKey: "playable", error: &error)
            switch status {
            case .loaded:
                break
            case .failed, .cancelled:
                print("Failed to load asset successfully")
                return
            default:
                print("Unkown state of asset")
                return
            }
            let player = AVPlayer()
            let item = AVPlayerItem(asset: asset)
            DispatchQueue.main.async {
                let videoContainer = VideoContainer(player: player, item: item, url: url)
                strongSelf.videoCache.setObject(videoContainer, forKey: url as NSString)
                videoContainer.player.replaceCurrentItem(with: videoContainer.playerItem)
                if strongSelf.videoURL == url, let layer = strongSelf.currentLayer {
                    strongSelf.playVideo(withLayer: layer, url: url)
                }
            }
        }
    }
    
    // Play video with the AVPlayerLayer provided
    func playVideo(withLayer layer: AVPlayerLayer, url: String) {
        videoURL = url
        currentLayer = layer
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            layer.player = videoContainer.player
            videoContainer.playOn = true
            addObservers(url: url, videoContainer: videoContainer)
        }
        DispatchQueue.main.async {
            if let videoContainer = self.videoCache.object(forKey: url as NSString),
                videoContainer.player.currentItem?.status == .readyToPlay {
                videoContainer.playOn = true
            }
        }
        NotificationCenter.default.post(name: Notification.Name("STARTED_PLAYING"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    private func pauseVideo(forLayer layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            videoContainer.playOn = false
            removeObserverFor(url: url)
        }
    }
    func removeLayerFor(cell: PlayVideoLayerContainer) {
        if let url = cell.videoURL {
            removeFromSuperLayer(layer: cell.videoLayer, url: url)
        }
    }
    private func removeFromSuperLayer(layer: AVPlayerLayer, url: String) {
        videoURL = nil
        currentLayer = nil
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            videoContainer.playOn = false
            removeObserverFor(url: url)
        }
        layer.player = nil
    }
    private func pauseRemoveLayer(layer: AVPlayerLayer, url: String, layerHeight: CGFloat) {
        pauseVideo(forLayer: layer, url: url)
    }
    // Play video again in case the current player has finished playing
    @objc func playerDidFinishPlaying(note: NSNotification) {
        guard let playerItem = note.object as? AVPlayerItem,
            let currentPlayer = currentVideoContainer()?.player else {
                return
        }
        if let currentItem = currentPlayer.currentItem, currentItem == playerItem {
            currentPlayer.seek(to: CMTime.zero)
            currentPlayer.play()
        }
    }
    
     func currentVideoContainer() -> VideoContainer? {
        if let currentVideoUrl = videoURL {
            if let videoContainer = videoCache.object(forKey: currentVideoUrl as NSString) {
                return videoContainer
            }
        }
        return nil
    }
    
    private func addObservers(url: String, videoContainer: VideoContainer) {
        if self.observingURLs[url] == false || self.observingURLs[url] == nil {
            videoContainer.player.currentItem?.addObserver(
                self,
                forKeyPath: "status",
                options: [.new, .initial],
                context: &VideoPlayerController.playerViewControllerKVOContext)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(self.playerDidFinishPlaying(note:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: videoContainer.player.currentItem)
            self.observingURLs[url] = true
        }
    }
    private func removeObserverFor(url: String) {
        if let videoContainer = self.videoCache.object(forKey: url as NSString) {
            if let currentItem = videoContainer.player.currentItem, observingURLs[url] == true {
                currentItem.removeObserver(self,
                                           forKeyPath: "status",
                                           context: &VideoPlayerController.playerViewControllerKVOContext)
                NotificationCenter.default.removeObserver(self,
                                                          name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                          object: currentItem)
                observingURLs[url] = false
            }
        }
    }
    /*
     Play UITableViewCell's videoplayer that has max visible video layer height
     when the scroll stops.
     */
    func pausePlayeVideosFor(tableView: UITableView, appEnteredFromBackground: Bool = false) {
        let visisbleCells = tableView.visibleCells
        var videoCellContainer: PlayVideoLayerContainer?
        var maxHeight: CGFloat = 0.0
        for cellView in visisbleCells {
            guard let containerCell = cellView as? PlayVideoLayerContainer,
                let videoCellURL = containerCell.videoURL else {
                    continue
            }
            let height = containerCell.visibleVideoHeight()
            if maxHeight < height {
                maxHeight = height
                videoCellContainer = containerCell
            }
            pauseRemoveLayer(layer: containerCell.videoLayer, url: videoCellURL, layerHeight: height)
        }
        guard let videoCell = videoCellContainer,
            let videoCellURL = videoCell.videoURL else {
            return
        }
        let minCellLayerHeight = videoCell.videoLayer.bounds.size.height * 0.5
        /*
         Visible video layer height should be at least more than max of predefined minimum height and
         cell's videolayer's 50% height to play video.
         */
        let minimumVideoLayerVisibleHeight = max(minCellLayerHeight, minimumLayerHeightToPlay)
        if maxHeight > minimumVideoLayerVisibleHeight {
            if appEnteredFromBackground {
                setupVideoFor(url: videoCellURL)
            }
            playVideo(withLayer: videoCell.videoLayer, url: videoCellURL)
        }
    }
    // Set observing urls false when objects are removed from cache
    func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
        if let videoObject = obj as? VideoContainer {
            observingURLs[videoObject.url] = false
        }
    }
    // Play video only when current videourl's player is ready to play\
    // swiftlint:disable block_based_kvo
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey: Any]?,
                               context: UnsafeMutableRawPointer?) {
        // Make sure the this KVO callback was intended for this view controller.
        guard context == &VideoPlayerController.playerViewControllerKVOContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == "status" {
            /*
             Handle `NSNull` value for `NSKeyValueChangeNewKey`, i.e. when
             `player.currentItem` is nil.
             */
            let newStatus: AVPlayerItem.Status
            if let newStatusAsNumber = change?[NSKeyValueChangeKey.newKey] as? NSNumber {
                newStatus = AVPlayerItem.Status(rawValue: newStatusAsNumber.intValue)!
                if newStatus == .readyToPlay {
                    guard let item = object as? AVPlayerItem,
                        let currentItem = currentVideoContainer()?.player.currentItem else {
                            return
                    }
                    if item == currentItem && currentVideoContainer()?.playOn == true {
                        currentVideoContainer()?.playOn = true
                    }
                }
            } else {
                newStatus = .unknown
            }
        }
    }
    
    // MARK: - Manual Play/Pause by Button
    func playCurrentVideo() {
        guard let currentVideo = currentVideoContainer() else {
            return
        }
        let player = currentVideo.player
        if player.timeControlStatus != .playing {
            player.play()
            currentVideo.playOn = true
            print("▶️ Video manually played")
        }
    }

    func pauseCurrentVideo() {
        guard let currentVideo = currentVideoContainer() else {
            return
        }
        let player = currentVideo.player
        if player.timeControlStatus == .playing {
            player.pause()
            currentVideo.playOn = false
            print("⏸️ Video manually paused")
        }
    }

    deinit {
        print("Desiposed of Video layer - No retain Cycle/Memeory leaks")
    }
}

