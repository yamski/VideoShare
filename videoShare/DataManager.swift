//
//  DataManager.swift
//  videoShare
//
//  Created by JOHN YAM on 7/27/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation

class DataManager {
    
    var dataFilePath: String?
    
    class var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        return Static.instance
    }
    
    var videoCollection:[String:VideoModel]? {
        
        didSet {
            
        }
    }
    
    func checkForDirectory() {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        dataFilePath = docsDir.stringByAppendingPathComponent("data.archive")
        
        if filemgr.fileExistsAtPath(dataFilePath!) {
            videoCollection = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!) as? [String:VideoModel]
            print("found models")
        }
    }
    
    
    func archiveVideo() {
        
        if let videoCollection = videoCollection {
            if NSKeyedArchiver.archiveRootObject(videoCollection, toFile: dataFilePath!) {
                print("Success writing to file!")
            } else {
                print("Unable to write to file!")
            }
        }
    }

}

//This creates a class variable that holds a structure, which itself contains a static constant reference to the class. By declaring the static keyword in a struct, the instantiation will thereby be called on the type itself, instead of locally to the object referencing the struct. This little bit of trickery uses dispatch_once behind the scenes, as a constant is thread-safe, and has lazy instantiation that will only be created when first needed.