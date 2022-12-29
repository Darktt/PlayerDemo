//
//  AVPlayerItemAccessLogEventExtension.swift
//
//  Created by Eden on 2022/12/29.
//  
//

import AVFoundation.AVPlayerItem

public extension AVPlayerItemAccessLogEvent
{
    override var description: String {
        
        var output = [String: Any]()
        output["numberOfMediaRequests"] = self.numberOfMediaRequests
        output["playbackStartDate"] = self.playbackStartDate?.description ?? ""
        output["uri"] = self.uri ?? ""
        output["serverAddress"] = self.serverAddress ?? ""
        output["numberOfServerAddressChanges"] = self.numberOfServerAddressChanges
        output["playbackSessionID"] = self.playbackSessionID ?? ""
        output["playbackStartOffset"] = self.playbackStartOffset
        output["segmentsDownloadedDuration"] = self.segmentsDownloadedDuration
        output["durationWatched"] = self.durationWatched
        output["numberOfStalls"] = self.numberOfStalls
        output["numberOfBytesTransferred"] = Int(self.numberOfBytesTransferred)
        output["transferDuration"] = self.transferDuration
        output["observedBitrate"] = self.observedBitrate
        output["indicatedBitrate"] = self.indicatedBitrate
        output["numberOfDroppedVideoFrames"] = self.numberOfDroppedVideoFrames
        output["startupTime"] = self.startupTime
        output["downloadOverdue"] = self.downloadOverdue
        
        if #available(iOS 15.0, *) { } else {
            
            output["observedMaxBitrate"] = self.observedMaxBitrate
            output["observedMinBitrate"] = self.observedMinBitrate
        }
        
        output["observedBitrateStandardDeviation"] = self.observedBitrateStandardDeviation
        output["playbackType"] = self.playbackType
        output["mediaRequestsWWAN"] = self.mediaRequestsWWAN
        output["switchBitrate"] = self.switchBitrate
        
        let description = output.reduce(into: "") {
            
            $0 += "\"\($1.key)\": \($1.value)\n"
        }
        
        return description
    }
}
