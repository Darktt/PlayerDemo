//
//  ViewController.swift
//  PlayerDemo
//
//  Created by Eden on 2022/12/28.
//

import UIKit
import AVFoundation
import SwiftExtensions

func createPlayer(fromUrl url: URL) -> AVPlayer
{
    let asset = AVAsset(url: url)
    let playerItem = AVPlayerItem(asset: asset)
    let player = AVPlayer(playerItem: playerItem)
    
    return player
}

class ViewController: UIViewController
{
    @IBOutlet private weak var urlField: UITextField!
    
    @IBOutlet private weak var sendButton: UIButton!
    
    @IBOutlet private weak var playerView: DTVideoPlayerView!
    
    @IBOutlet private weak var playButton: UIButton!
    
    @IBOutlet private weak var pauseButton: UIButton!
    
    @IBOutlet private weak var trackBar: UISlider!
    
    @IBOutlet private weak var durationLabel: UILabel!
    
    @IBOutlet private weak var bufferProgressView: UIProgressView!
    
    private lazy var formatter: DateFormatter = {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        
        return formatter
    }()
    
    private var totalDutation: String?
    
    private var observations: Array<NSKeyValueObservation> = []
    
    private var observance: Any?
    
    private var isSeeking: Bool = false
    
    override class func awakeFromNib()
    {
        super.awakeFromNib()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = "Player Demo"
        
        self.urlField.text = "https://assets.cod1cov.com/doudou/video/preview/74ad04bfdaba4fa88c31678ec59bc676/video.m3u8"
        
        self.bufferProgressView.progress = 0.0
        
        self.sendButton.addTarget(self, action: #selector(sendUrlAction(_:)), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(playAction(_:)), for: .touchUpInside)
        self.pauseButton.addTarget(self, action: #selector(pauseAction(_:)), for: .touchUpInside)
        self.trackBar.addTarget(self, action: #selector(startSeekAction(_:)), for: .touchDown)
        self.trackBar.addTarget(self, action: #selector(finishSeekingAction(_:)), for: .touchUpInside)
        
        self.registerNotification()
    }
    
    deinit
    {
        self.observations.forEach({ $0.invalidate() })
        self.observations = []
        
        self.playerView.player.zip(self.observance).map {
            
            $0.0.removeTimeObserver($0.1)
        }
        self.removeNotification()
    }
}

// MARK: - Actions -

private
extension ViewController
{
    @objc
    func sendUrlAction(_ sender: UIButton)
    {
        guard let url: URL = self.urlField.text.flatMap({ URL(string: $0) }) else {
            
            return
        }
        
        self.sendAction(.setupPlayerAction(url: url))
        self.urlField.resignFirstResponder()
    }
    
    @objc
    func playAction(_ sender: UIButton)
    {
        self.sendAction(.playAction)
    }
    
    @objc
    func pauseAction(_ sender: UIButton)
    {
        self.sendAction(.pauseAction)
    }
    
    @objc
    func startSeekAction(_ sender: UISlider)
    {
        self.isSeeking = true
    }
    
    @objc
    func finishSeekingAction(_ sender: UISlider)
    {
        let value: Float = sender.value
        
        self.isSeeking = false
        self.sendAction(.seekAction(toSeconds: value))
    }
}

// MARK: - Notification Methods -

private
extension ViewController
{
    func registerNotification()
    {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(handlePlaybackStalledNotification(_:)), name: .AVPlayerItemPlaybackStalled, object: nil)
        notification.addObserver(self, selector: #selector(handleNewAccessLogEntryNotification(_:)), name: .AVPlayerItemNewAccessLogEntry, object: nil)
        notification.addObserver(self, selector: #selector(handleNewErrorLogEntryNotification(_:)), name: .AVPlayerItemNewErrorLogEntry, object: nil)
    }
    
    func removeNotification()
    {
        let notification = NotificationCenter.default
        notification.removeObserver(self)
    }
    
    @objc
    func handlePlaybackStalledNotification(_ sender: Notification)
    {
        guard let item = sender.object as? AVPlayerItem else {
            
            return
        }
        
        let currentTime: CMTime = item.currentTime()
        var isHanging: Bool = item.isPlaybackLikelyToKeepUp
        isHanging &= (CMTimeCompare(currentTime, .zero) == 1)
        isHanging &= (CMTimeCompare(currentTime, item.duration) != 0)
        
        isHanging.isTrue {
            
            print("!!!!!! isHanging")
        }
    }
    
    @objc
    func handleNewAccessLogEntryNotification(_ sender: NSNotification)
    {
        guard let accessLog: AVPlayerItemAccessLog = sender.object.compactMap(as: AVPlayerItem.self, transform: { $0.accessLog() }) else {
            
            return
        }
        
        print("!!!!!! Access log: \(accessLog)")
        
        accessLog.events.forEach {
            
            event in
            
            print("!!!!!! Access event: \(event)")
        }
    }
    
    @objc
    func handleNewErrorLogEntryNotification(_ sender: NSNotification)
    {
        guard let errorLog: AVPlayerItemErrorLog = sender.object.compactMap(as: AVPlayerItem.self, transform: { $0.errorLog() }) else {
            
            return
        }
        
        print("!!!!!! Error log: \(errorLog)")
        
        errorLog.events.forEach {
            
            event in
            
            print("!!!!!! Event event: \(event)")
        }
    }
}

// MARK: - Private Methods -

private
extension ViewController
{
    func sendAction(_ action: PlayerAction)
    {
        if case .setupPlayerAction(let url) = action {
            
            let player = createPlayer(fromUrl: url)
            
            self.playerView.player = player
            self.setupPlayTime(withPlayer: player)
            self.oberverPlayProgress(withPlayer: player)
            self.setupPlayerStatus(withPlayer: player)
            self.setupBufferProgress(withPlayer: player)
            self.setupPlayError(withPlayer: player)
        }
        
        if case .updateTotalDuration(let duration) = action {
            
            let date = Date(timeIntervalSince1970: duration)
            let totalDuration: String = self.formatter.string(from: date)
            
            self.trackBar.maximumValue = Float(duration)
            self.totalDutation = totalDuration
            self.updateDuration()
        }
        
        if case .updatePlayedTime(let playedTime) = action {
            
            self.updateDuration(withPlayedTime: playedTime)
        }
        
        if case .playAction = action {
            
            let handler: DTVideoPlayerView.PlayedHandler = {
                
                playerView in
                
            }
            
            self.playerView.play(withPlayedHandler: handler)
        }
        
        if case .pauseAction = action {
            
            self.playerView.pause()
        }
        
        if case .seekAction(let toSeconds) = action {
            
            let completionHandler: (Bool) -> Void = {
                completion in
                
            }
            
            let date = Date(timeIntervalSince1970: TimeInterval(toSeconds))
            self.playerView.player?.seek(to: date, completionHandler: completionHandler)
        }
        
//        if case .volumnAction(let increase) = action {
//
//
//        }
    }
    
    func setupPlayTime(withPlayer player: AVPlayer)
    {
        guard let item: AVPlayerItem = player.currentItem else {
            
            return
        }
        
        let handler: (AVPlayerItem, NSKeyValueObservedChange<AVPlayerItem.Status>) -> Void = {
            
            [unowned self] item, _ in
            
            guard item.status == .readyToPlay else {
                
                return
            }
            
            let seconds: TimeInterval = item.duration.seconds
            
            self.sendAction(.updateTotalDuration(seconds))
        }
        
        let observation = item.observe(\.status, options: .new, changeHandler: handler)
        
        self.observations += observation
    }
    
    func oberverPlayProgress(withPlayer player: AVPlayer)
    {
        // 0.5 sec
        let time = CMTimeMake(value: 1, timescale: 2)
        
        let handler: (CMTime) -> Void = {
            
            [unowned self] time in
            
            let seconds: TimeInterval = time.seconds
            
            self.sendAction(.updatePlayedTime(seconds))
        };
        
        let observance = player.addPeriodicTimeObserver(forInterval: time, queue: .main, using: handler)
        
        self.observance = observance
    }
    
    func setupPlayerStatus(withPlayer player: AVPlayer)
    {
        guard let item: AVPlayerItem = player.currentItem else {
            
            return
        }
        
        let handler: (AVPlayerItem, NSKeyValueObservedChange<AVPlayerItem.Status>) -> Void = {
            
            item, _ in
            
            let status: String = {
                
                if item.status == .unknown {
                    
                    return "Unknow"
                }
                
                if item.status == .readyToPlay {
                    
                    return "Ready to play"
                }
                
                return "Error"
            }()
            
            print("!!!!!! Status update to: \(status)")
        }
        
        let observation = item.observe(\.status, options: .new, changeHandler: handler)
        
        self.observations += observation
    }
    
    func setupPlayError(withPlayer player: AVPlayer)
    {
        guard let item: AVPlayerItem = player.currentItem else {
            
            return
        }
        
        let handler: (AVPlayerItem, NSKeyValueObservedChange<Error?>) -> Void = {
            
            item, _ in
            
            guard let error = item.error else {
                
                return
            }
            
            print("!!!!!! Error: \(error.localizedDescription)")
        }
        
        let observation = item.observe(\.error, options: .new, changeHandler: handler)
        
        self.observations += observation
    }
    
    func setupBufferProgress(withPlayer player: AVPlayer)
    {
        guard let item: AVPlayerItem = player.currentItem else {
            
            return
        }
        
        let handler: (AVPlayerItem, NSKeyValueObservedChange<Array<NSValue>>) -> Void = {
            
            item, _ in
            
            guard let timeRage: CMTimeRange = item.loadedTimeRanges.first?.timeRangeValue else {
                
                return
            }
            
            let progress = Float(timeRage.duration.seconds / item.duration.seconds)
            
            self.bufferProgressView.progress = progress
        }
        
        let observation = item.observe(\.loadedTimeRanges, options: .new, changeHandler: handler)
        
        self.observations += observation
    }
    
    func updateDuration(withPlayedTime playedTime: TimeInterval = .zero)
    {
        guard !self.isSeeking else {
            
            return
        }
        
        let date = Date(timeIntervalSince1970: playedTime)
        let playedTimeString: String = self.formatter.string(from: date)
        let duration: String = playedTimeString + "/" + self.totalDutation.or("")
        
        self.trackBar.value = Float(playedTime)
        self.durationLabel.text = duration
    }
}
