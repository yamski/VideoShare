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

    var identifier: String { get }
    var duration: NSTimeInterval { get }
    var durationString: String! { get }
    var title: String? { get set }
    var tags: [String] { get set }
    var isFavorite: Bool! {get set}
}


class VideoModel: NSObject, NSCoding, Video {

    let identifier: String
    var duration: NSTimeInterval
    var durationString: String!
    var title: String?
    var tags: [String]
    var isFavorite: Bool!

    init(asset:PHAsset, duration: NSTimeInterval){

        identifier = asset.localIdentifier
        self.duration = duration
        tags = []
        isFavorite = false
        super.init()
        self.durationString = stringFromTimeInterval(duration) as String
    }
    
    required init(coder decoder: NSCoder) {
     
        identifier = decoder.decodeObjectForKey("indentifier") as! String
        duration = decoder.decodeDoubleForKey("duration")
        durationString = decoder.decodeObjectForKey("durationString") as! String
        title = decoder.decodeObjectForKey("title") as? String
        tags = decoder.decodeObjectForKey("tags") as! [String]
        isFavorite = decoder.decodeBoolForKey("isFavorite") as Bool
    }
    
    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(identifier, forKey: "indentifier")
        coder.encodeDouble(duration, forKey: "duration")
        coder.encodeObject(durationString, forKey: "durationString")
        coder.encodeObject(title, forKey: "title")
        coder.encodeObject(tags, forKey: "tags")
        coder.encodeBool(isFavorite, forKey: "isFavorite")
    }
    
    func stringFromTimeInterval(interval:NSTimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds)
        
    }
}
