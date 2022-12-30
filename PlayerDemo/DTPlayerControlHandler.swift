//
//  DTPlayerControlHandler.swift
//
//  Created by Darktt on 19/9/25.
//  Copyright © 2019 Darktt. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizer
import CoreGraphics.CGBase

public class DTPlayerControlHandler
{
    // MARK: - Properties -
    
    public weak var delegate: DTPlayerControlHandlerDelegate?
    
    public var configuration: Configuration = Configuration()
    
    public var volumeLevel: CGFloat = 0.0
    
    public var totalPlayInterval: TimeInterval = 0.0
    
    public var playedInterval: TimeInterval = 0.0
    
    public var isEnabled: Bool = true {
        
        willSet {
            
            self.gestureRecognizer?.isEnabled = newValue
        }
    }
    
    private var event: Event = .default
    private var gestureRecognizer: UIGestureRecognizer?
    
    // MARK: - Methods -
    // MARK: Initial Method
    
    public init(delegate: DTPlayerControlHandlerDelegate)
    {
        self.delegate = delegate
    }
    
    public func add(to view: UIView)
    {
        if let gestureRecognizer = self.gestureRecognizer {
            
            // Remove from previous view.
            let previousView: UIView = gestureRecognizer.view!
            previousView.removeGestureRecognizer(gestureRecognizer)
            
            // Add to new view.
            view.addGestureRecognizer(gestureRecognizer)
            return
        }
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        
        view.addGestureRecognizer(gestureRecognizer)
        self.gestureRecognizer = gestureRecognizer
    }
}

// MARK: - Actions -

private extension DTPlayerControlHandler
{
    @objc
    func panGestureHandler(_ sender: UIPanGestureRecognizer)
    {
        let state: UIGestureRecognizer.State = sender.state
        let view: UIView? = sender.view
        let velocity: CGPoint = sender.velocity(in: view)
        
        if state != .began {
            // When not begin state.
            if self.event == .volume {
                
                self.volumeGestureHandler(sender)
            } else {
                
                self.seekGestureHandler(sender)
            }
            return
        }
        
        // Begin state.
        let maximumVelocityOfDirection: CGFloat = max(abs(velocity.x), abs(velocity.y))
        let event: Event = (maximumVelocityOfDirection == abs(velocity.x)) ? .seek : .volume
        
        // Notify delegate
        if event == .volume {
            
            self.delegate?.controlHandler(willChangeVolumeLevel: self)
        }
        
        if event == .seek {
            
            self.delegate?.controlHandler(willBeginSeek: self)
        }
        
        self.event = event
    }
    
    func volumeGestureHandler(_ sender: UIPanGestureRecognizer)
    {
        let state: UIGestureRecognizer.State = sender.state
        let view: UIView? = sender.view
        let point: CGPoint = sender.translation(in: view)
        var volumeLevel: CGFloat = self.volumeLevel
        
        if state == .ended {
            
            self.event = .default
            self.volumeLevel = 0.0
            self.delegate?.controlHandler(self, didChangeVolumeLevel: volumeLevel)
        }
        
        if state != .changed {
            
            return
        }
        
        let volumeGestureScale: CGFloat = self.configuration.gestureScale.volume
        
        if abs(point.y) >= volumeGestureScale {
            
            let multiple: CGFloat = abs(point.y) / volumeGestureScale
            let volumeIncrement: CGFloat = self.configuration.increment.volume
            let addtionInterval: CGFloat = (point.y > 0.0) ? -volumeIncrement : volumeIncrement
            
            volumeLevel += (addtionInterval * multiple)
            
            volumeLevel = min(volumeLevel, 1.0)
            volumeLevel = max(0.0, volumeLevel)
            
            self.volumeLevel = volumeLevel
            self.delegate?.controlHandler(self, didChangeVolumeLevel: volumeLevel)
            sender.setTranslation(.zero, in: view)
        }
    }
    
    func seekGestureHandler(_ sender: UIPanGestureRecognizer)
    {
        let state: UIGestureRecognizer.State = sender.state
        let view: UIView? = sender.view
        let point: CGPoint = sender.translation(in: view)
        var seekingInterval: TimeInterval = self.playedInterval
        
        if state == .ended {
            
            self.event = .default
            self.delegate?.controlHandler(self, didFinishSeekToSeconds: seekingInterval)
        }
        
        if state != .changed {
            
            return
        }
        
        let seekGestureScale: CGFloat = self.configuration.gestureScale.seek
        
        if abs(point.x) >= seekGestureScale {
            
            let multiple: CGFloat = abs(point.x) / seekGestureScale
            let seekIncrement: CGFloat = self.configuration.increment.seek
            let addtionInterval: CGFloat = (point.x > 0.0) ? seekIncrement : -seekIncrement
            
            seekingInterval += TimeInterval(addtionInterval * multiple)
            seekingInterval = min(seekingInterval, self.totalPlayInterval)
            seekingInterval = max(0.0, seekingInterval)
            
            self.playedInterval = seekingInterval
            self.delegate?.controlHandler(self, didSeekToSeconds: seekingInterval)
            sender.setTranslation(.zero, in: view)
        }
    }
}

// MARK: - DTPlayerControlHandler.Configuration -

public extension DTPlayerControlHandler
{
    struct Configuration
    {
        var gestureScale: Group = Group()
        
        var increment: Group = Group()
        
        fileprivate init()
        {
            self.gestureScale.volume = 2.0
            self.gestureScale.seek = 1.0
            
            self.increment.volume = 0.01
            self.increment.seek = 1.0
        }
    }
}

// MARK: - DTPlayerControlHandler.Configuration.Group -

public extension DTPlayerControlHandler.Configuration
{
    struct Group {
        
        var volume: CGFloat = 0.0
        
        var seek: CGFloat = 0.0
        
        fileprivate init() {}
    }
}

// MARK: - DTPlayerControlHandler.Event -

private extension DTPlayerControlHandler
{
    enum Event
    {
        case `default`
        
        case volume
        
        case seek
    }
}

// MARK: - DTPlayerControlHandlerDelegate -

public protocol DTPlayerControlHandlerDelegate: AnyObject
{
    func controlHandler(willChangeVolumeLevel handler: DTPlayerControlHandler)
    
    func controlHandler(_ handler: DTPlayerControlHandler, didChangeVolumeLevel level: CGFloat)
    
    func controlHandler(willBeginSeek handler: DTPlayerControlHandler)
    
    func controlHandler(_ handler: DTPlayerControlHandler, didSeekToSeconds seconds: TimeInterval)
    
    func controlHandler(_ handler: DTPlayerControlHandler, didFinishSeekToSeconds seconds: TimeInterval)
}
