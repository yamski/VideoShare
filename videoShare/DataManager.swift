//
//  DataManager.swift
//  videoShare
//
//  Created by JOHN YAM on 7/27/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import Photos

class DataManager {
    
    var dataFilePath: String?
    var archivedModelArray:[[String:VideoModel]]?
    var masterVideoArray: [([String: VideoModel], String, PHAsset)] = []
    var filteredArray: [([String: VideoModel], String, PHAsset)] = []
    
    var userIsSearching: Bool {
        get{
            return  DataManager.sharedInstance.filteredArray.count != 0
        }
        set {
            self.userIsSearching =  DataManager.sharedInstance.filteredArray.count != 0
        }
    }
    
    class var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        return Static.instance
    }
    

    
    func checkForDirectory() {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        dataFilePath = docsDir.stringByAppendingPathComponent("data.archive")
        
        if filemgr.fileExistsAtPath(dataFilePath!) {
            archivedModelArray = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!) as? [[String: VideoModel]]
        }
    }
    
    
    func archiveVideo() {
        
        var tempArray: [[String: VideoModel]] = []
        
        for tup in masterVideoArray {
            tempArray.append(tup.0)
        }
        
        if NSKeyedArchiver.archiveRootObject(tempArray, toFile: dataFilePath!) {
            print("Success writing to file!")
        } else {
            print("Unable to write to file!")
        }
    }
    
    func updateModels(index: Int, model: VideoModel, identifier: String) {
        var tempTuple = masterVideoArray[index]
        var tempDict = tempTuple.0
        tempDict[identifier] = model
        tempTuple.0 = tempDict
        masterVideoArray[index] = tempTuple
        
        print("master count: \(masterVideoArray.count)")
        
        archiveVideo()
    }
    
    func fetchResults(){
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let results = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Video, options: fetchOptions)
        
        var tempArray: [([String: VideoModel], String, PHAsset)] = []
        
        results.enumerateObjectsUsingBlock({ (asset, index, stop ) -> Void in
            
            let videoAsset = VideoModel(asset: asset as! PHAsset, duration: asset.duration)
            
            // build dictionary with key of the local identifier
            var videoDict = [videoAsset.identifier: videoAsset]
            
            if let archivedData = self.archivedModelArray {
            
                for dict in archivedData {
                    for (key,value) in dict {
                        
                        if key == videoAsset.identifier {
                            videoDict[key] = value
                        }
                    }
                }
            }
            
            let tuple = (videoDict, videoAsset.identifier, asset as! PHAsset)
            tempArray.append(tuple)
            self.masterVideoArray = tempArray
        })
    }
    

}

//This creates a class variable that holds a structure, which itself contains a static constant reference to the class. By declaring the static keyword in a struct, the instantiation will thereby be called on the type itself, instead of locally to the object referencing the struct. This little bit of trickery uses dispatch_once behind the scenes, as a constant is thread-safe, and has lazy instantiation that will only be created when first needed.