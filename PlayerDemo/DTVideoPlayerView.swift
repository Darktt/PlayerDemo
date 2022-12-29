//
//  DTVideoPlayerView.swift
//
//  Created by Darktt on 16/5/4.
//  Copyright © 2016 Darktt. All rights reserved.
//

import UIKit
import AVFoundation

public final class DTVideoPlayerView: UIView
{
    public typealias PlayedHandler = (_ playerView: DTVideoPlayerView) -> Void
    
    // MARK: - Properties -
    
    public override class var layerClass: AnyClass {
        
        return AVPlayerLayer.self
    }
    
    public var player: AVPlayer? {
        
        set {
            
            self.playerLayer.player = newValue
            self.unregisterOberver()
            self.registerOberver()
        }
        
        get {
            
            return self.playerLayer.player
        }
    }
    
    public var looper: AVPlayerLooper?
    
    public var videoGravity: AVLayerVideoGravity {
        
        willSet {
            
            self.playerLayer.videoGravity = newValue
        }
    }
    
    public var isPlaying: Bool {
        
        get {
            
            guard let player = self.player else {
                
                return false
            }
            
            let status = player.timeControlStatus
            
            return status == .playing
        }
    }
    
    private var playerLayer: AVPlayerLayer {
        
        return self.layer as! AVPlayerLayer
    }
    
    private var playedHandler: PlayedHandler?
    private var keyValueObservation: NSKeyValueObservation?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(player: AVPlayer, frame: CGRect = CGRect.zero)
    {
        self.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        super.init(frame: frame)
        
        self.player = player
    }
    
    public override init(frame: CGRect)
    {
        self.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        self.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        super.init(coder: aDecoder)
    }
    
    deinit
    {
        self.unregisterOberver()
    }
    
    // MARK: Public Method
    
    public func playPause()
    {
        guard let player = self.player else {
            
            return
        }
        
        if self.isPlaying {
            
            player.pause()
            
            return
        }
        
        player.play()
    }
    
    public func play(withPlayedHandler playedHandler: PlayedHandler? = nil)
    {
        guard let player = self.player else {
            
            return
        }
        
        self.playedHandler = playedHandler
        player.play()
    }
    
    public func pause()
    {
        guard let player = self.player else {
            
            return
        }
        
        player.pause()
    }
}

// MARK: - Key value observing -

private extension DTVideoPlayerView
{
    func registerOberver()
    {
        guard let player = self.player else {
            
            return
        }
        
        // Observe timeControlStatus
        let changeHandler: (AVPlayer, NSKeyValueObservedChange<AVPlayer.TimeControlStatus>) -> Void = {
            
            (player, change) in
            
            guard let playedHandler = self.playedHandler,
                    player.timeControlStatus == .playing else {
                
                return
            }
            
            playedHandler(self)
            self.playedHandler = nil
        }
        
        self.keyValueObservation = player.observe(\.timeControlStatus, options: [.new], changeHandler: changeHandler)
    }
    
    func unregisterOberver()
    {
        self.keyValueObservation?.invalidate()
        self.keyValueObservation = nil
    }
}

// MARK: - Bridge SwiftUI -

#if canImport(SwiftUI)

import SwiftUI

@available(iOS 13.0, *)
public struct VideoPlayerView: UIViewRepresentable
{
    // MARK: - Properties -
    
    private let viewModel: ViewModel = ViewModel()
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(player: AVPlayer? = nil, looper: AVPlayerLooper? = nil)
    {
        self.viewModel.player = player
        self.viewModel.looper = looper
    }
    
    public func makeUIView(context: UIViewRepresentableContext<VideoPlayerView>) -> DTVideoPlayerView
    {
        let view = DTVideoPlayerView(frame: .zero)
        
        return view
    }
    
    public func updateUIView(_ uiView: DTVideoPlayerView, context: UIViewRepresentableContext<VideoPlayerView>)
    {
        let viewModel: ViewModel = self.viewModel
        
        uiView.player = viewModel.player
        uiView.looper = viewModel.looper
        uiView.videoGravity = viewModel.videoGravity
    }
    
    // MARK: - Bridge Methods -
    
    public func playPause(_ playPause: Bool)
    {
        self.viewModel.playPause = playPause
    }
    
    public func player(_ player: AVPlayer?) -> VideoPlayerView
    {
        self.viewModel.player = player
        
        return self
    }
    
    public func videoGravity(_ videoGravity: AVLayerVideoGravity) -> VideoPlayerView
    {
        self.viewModel.videoGravity = videoGravity
        
        return self
    }
}

@available(iOS 13.0, *)
struct VideoPlayerView_Previews: PreviewProvider
{
    static var previews: some View {
        
        VideoPlayerView()
            .background(Color.black)
            .previewLayout(.fixed(width: 1280.0, height: 720.0))
    }
}

// MARK: - VideoPlayerView.ViewModel -

@available(iOS 13.0, *)
private extension VideoPlayerView
{
    class ViewModel
    {
        // MARK: - Properties -
        
        fileprivate var player: AVPlayer?
        
        fileprivate var looper: AVPlayerLooper?
        
        fileprivate var videoGravity: AVLayerVideoGravity = .resizeAspectFill
        
        fileprivate var playPause: Bool = false {
            
            willSet {
                
                if newValue {
                    
                    self.player?.play()
                    return
                }
                
                self.player?.pause()
            }
        }
        
        // MARK: - Methods -
        // MARK: Initial Method
        
        fileprivate init() { }
    }
}

#endif
