//
//  Presenter.swift
//  VideoReels
//
//  Created by Atik Hasan on 7/11/25.
//


import Foundation

protocol PresenterProtocol: AnyObject {
    func refresh()
}

struct VideoObject {
    var videoURL: String
    var thumbnailURL: String
    var chanelName: String
    var videoDescription: String
    init(videoURL: String, thumbnailURL: String, chanelName: String, videoDescription: String) {
        self.videoURL = videoURL
        self.thumbnailURL = thumbnailURL
        self.chanelName = chanelName
        self.videoDescription = videoDescription
    }
}

class Presenter: NSObject {
    var videos: [VideoObject] = [
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            thumbnailURL: "https://picsum.photos/id/0/5616/3744",
            chanelName: "Video 01",
            videoDescription: "This is a description for video 01"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            thumbnailURL: "https://picsum.photos/id/1/5616/3744",
            chanelName: "Video 02",
            videoDescription: ""),
        VideoObject.init(
            videoURL: "https://cdn.pixabay.com/video/2025/06/03/283431_small.mp4",
            thumbnailURL: "https://picsum.photos/id/1/5616/3744",
            chanelName: "Video 03",
            videoDescription: ""),
        VideoObject.init(
            videoURL: "https://cdn.pixabay.com/video/2024/08/20/227567_small.mp4",
            thumbnailURL: "https://picsum.photos/id/1/5616/3744",
            chanelName: "Video 04",
            videoDescription: "Silence is not always Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            thumbnailURL: "https://picsum.photos/id/10/2500/1667",
            chanelName: "Video 05",
            videoDescription: "This is a description for video 05"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            thumbnailURL: "https://picsum.photos/id/100/2500/1656",
            chanelName: "Video 06",
            videoDescription: "Silence is not always Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma Ego | Thomas Shelby | #shorts #inspiration #motivation #quotes #status #sigma"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            thumbnailURL: "https://picsum.photos/id/1000/5626/3635",
            chanelName: "Video 07",
            videoDescription: "This is a description for video 07"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            thumbnailURL: "https://picsum.photos/id/1001/5616/3744",
            chanelName: "Video 08",
            videoDescription: "This is a description for video 08"),
        VideoObject.init(
            videoURL: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            thumbnailURL: "https://picsum.photos/id/1002/4312/2868",
            chanelName: "Video 09",
            videoDescription: "This is a description for video 09")
    ]
    weak var delegate: PresenterProtocol?
    init(delegate: PresenterProtocol) {
        self.delegate = delegate
    }
}
