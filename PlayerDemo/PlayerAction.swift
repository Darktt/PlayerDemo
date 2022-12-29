//
//  PlayerAction.swift
//  PlayerDemo
//
//  Created by Eden on 2022/12/28.
//

import Foundation
import CoreMedia.CMTime

enum PlayerAction
{
    case setupPlayerAction(url: URL)
    
    case updateTotalDuration(_ duration: TimeInterval)
    
    case updatePlayedTime(_ playedTime: TimeInterval)
    
    case playAction
    
    case pauseAction
    
    case seekAction(toSeconds: Float)
    
    case volumnAction(increase: Float)
}
