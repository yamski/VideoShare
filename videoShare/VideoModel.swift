//
//  VideoModel.swift
//  videoShare
//
//  Created by JOHN YAM on 7/23/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import Photos

protocol Video {
//    var asset: PHAsset  { get }
    var identifier: String { get }
    var duration: NSTimeInterval { get }
    var durationString: String! { get }
    var title: String? { get set }
    var tags: [String] { get set }
}


class VideoModel: NSObject, NSCoding, Video {
//    let asset: PHAsset
    let identifier: String
    var duration: NSTimeInterval
    var durationString: String!
    var title: String?
    var tags: [String]

    init(asset:PHAsset, duration: NSTimeInterval){
//        self.asset = asset
        self.identifier = asset.localIdentifier
        self.duration = duration
//        self.title = "Untitled"
        self.tags = []
        super.init()
        self.durationString = stringFromTimeInterval(duration) as String
    }
    
    required init(coder decoder: NSCoder) {
     
        self.identifier = decoder.decodeObjectForKey("indentifier") as! String
        self.duration = decoder.decodeDoubleForKey("duration")
        self.durationString = decoder.decodeObjectForKey("durationString") as! String
        self.title = decoder.decodeObjectForKey("title") as? String
        self.tags = decoder.decodeObjectForKey("tags") as! [String]
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(identifier, forKey: "indentifier")
        coder.encodeDouble(duration, forKey: "duration")
        coder.encodeObject(durationString, forKey: "durationString")
        coder.encodeObject(title, forKey: "title")
        coder.encodeObject(tags, forKey: "tags")
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        
    }
}
