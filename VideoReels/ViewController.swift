//
//  ViewController.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
//



import UIKit
import AVFoundation

import UIKit

struct VideoModel{
    var videoURL: URL
    var videoText : String
    var chanelName : String
    var isHasMusic : Bool
}


class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let assetCache = NSCache<NSURL, AVURLAsset>()
    
    var videoURLs : [VideoModel] = [
        VideoModel(
            videoURL:  URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")!,
            videoText: "Silence is not always Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma",
            chanelName: "@Themotivation.69",
            isHasMusic: false)
        ,
        
        VideoModel(
            videoURL:  URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")!,
            videoText: "Silence is not always Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma",
            chanelName: "@Themottion.69",
            isHasMusic: true
        ),
        VideoModel(
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")!,
            videoText: "Silence is not #shorts #inspiration #motivation #quotes #status #sigma",
            chanelName: "@Thttion.69",
            isHasMusic: true
        ),
        VideoModel(
            videoURL: URL(string: "https://cdn.pixabay.com/video/2024/08/20/227567_small.mp4")!,
            videoText: "Silence is not #shorts #inspiration #motivation #quotes #status #sigma",
            chanelName: "@Thttion.69",
            isHasMusic: true
        ),
        VideoModel(
            videoURL:  URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4")!,
            videoText: "Silence is not #shorts #inspiration #motivation #quotes is not #shorts #inspiration #motivation #quotesis not #shorts #inspiration #motivation #quotes #status #sigma",
            chanelName: "@Thttion.69",
            isHasMusic: true
        ),
        VideoModel(
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4")!,
            videoText: "Silence is not ",
            chanelName: "@Thtfaftion.69",
            isHasMusic: false
        ),
        VideoModel(
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4")!,
            videoText: "Silence is not #status #sigma",
            chanelName: "@Thon.69",
            isHasMusic: true
        ),
        
        VideoModel(
            videoURL: URL(string: "https://cdn.pixabay.com/video/2025/06/03/283431_small.mp4")!,
            videoText: "Silence is notfts #inspiration #motivation #quotes #status #status #sigma",
            chanelName: "@Thttfafion.69",
            isHasMusic: false
        ),
        VideoModel(
            videoURL: URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!,
            videoText: "Silence is notfts #inspiration #motivation #quotes #status #status #sigma",
            chanelName: "@Thttfafion.69",
            isHasMusic: false
        ),
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assetCache.countLimit = 5
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(UINib(nibName: "ReelsViewCvCell", bundle: nil), forCellWithReuseIdentifier: "ReelsViewCvCell")
    }
    
    // Called on any scroll movement
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCurrentPlayingCell()
    }
    
    // Only one cell's video should play (center one)
    func updateCurrentPlayingCell() {
        guard let visibleCells = collectionView.visibleCells as? [ReelsViewCvCell] else { return }
        
        let centerY = collectionView.contentOffset.y + collectionView.frame.height / 2
        var closestCell: ReelsViewCvCell?
        var minDistance = CGFloat.greatestFiniteMagnitude
        
        for cell in visibleCells {
            let cellCenterY = cell.convert(cell.bounds, to: collectionView).midY
            let distance = abs(cellCenterY - centerY)
            if distance < minDistance {
                minDistance = distance
                closestCell = cell
            }
        }
        
        for cell in visibleCells {
            if cell == closestCell {
                cell.playVideo()
            } else {
                cell.pauseVideo()
            }
        }
    }
    
    func preloadAdjacentItems(for indexPath: IndexPath) {
        let range = (indexPath.item - 2)...(indexPath.item + 2)
        for i in range where i >= 0 && i < videoURLs.count {
            let url = videoURLs[i].videoURL
            let nsurl = url as NSURL
            if assetCache.object(forKey: nsurl) == nil {
                let asset = AVURLAsset(url: url)
                let keys = ["playable"]
                asset.loadValuesAsynchronously(forKeys: keys) {
                    var error: NSError? = nil
                    let status = asset.statusOfValue(forKey: "playable", error: &error)
                    if status == .loaded {
                        self.assetCache.setObject(asset, forKey: nsurl)
                    }
                }
            }
        }
    }
    
    
    func reloadCurrentAndNextCell() {
        let centerPoint = CGPoint(x: collectionView.frame.width / 2, y: collectionView.contentOffset.y + collectionView.frame.height / 2)
        if let indexPath = collectionView.indexPathForItem(at: centerPoint) {
            let nextIndex = IndexPath(item: indexPath.item + 1, section: 0)
            if nextIndex.item < videoURLs.count {
                collectionView.reloadItems(at: [nextIndex])
            }
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReelsViewCvCell", for: indexPath) as! ReelsViewCvCell
        let video = videoURLs[indexPath.item]
        let url = video.videoURL
        let nsurl = url as NSURL
        
        let asset = assetCache.object(forKey: nsurl) ?? AVURLAsset(url: url)
        if assetCache.object(forKey: nsurl) == nil {
            assetCache.setObject(asset, forKey: nsurl)
        }
        
        // BgMusicView
        if video.isHasMusic {
            cell.BgMusicView.isHidden = false
        }else{
            cell.BgMusicView.isHidden = true
        }
        
        let playerItem = AVPlayerItem(asset: asset)
        cell.configure(with: playerItem)
        
        preloadAdjacentItems(for: indexPath)
        
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentPlayingCell()
        reloadCurrentAndNextCell()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentPlayingCell()
            reloadCurrentAndNextCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
