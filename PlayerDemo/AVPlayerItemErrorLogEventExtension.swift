//
//  AVPlayerItemErrorLogEventExtension.swift
//
//  Created by Eden on 2022/12/29.
//  
//

import AVFoundation.AVPlayerItem

public extension AVPlayerItemErrorLogEvent
{
    override var description: String {
        
        var output: Dictionary<String, any CustomStringConvertible> = [:]
        output["date"] = self.date
        output["uri"] = self.uri ?? ""
        output["serverAddress"] = self.serverAddress ?? ""
        output["playbackSessionID"] = self.playbackSessionID ?? ""
        output["errorStatusCode"] = self.errorStatusCode
        output["errorDomain"] = self.errorDomain
        output["errorStatusCode"] = self.errorComment
        
        let description = output.reduce(into: "") {
            
            $0 += "\"\($1.key)\": \($1.value)\n"
        }
        
        return description
    }
}
