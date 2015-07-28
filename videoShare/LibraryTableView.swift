//
//  File.swift
//  videoShare
//
//  Created by JOHN YAM on 7/22/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVKit

class LibraryTableView: UIViewController, UITableViewDataSource, UITableViewDelegate, DisplayVideoProtocol {
    
    @IBOutlet weak var tableView: UITableView!
    
    var videoResults: PHFetchResult?
//    var assetModels = [VideoModel]()
    var imageManager: PHImageManager?
    var player: AVPlayer?
    var dataFilePath: String?
    
//    var archiveDict:[String:VideoModel]?
    var masterVideoArray: [([String: VideoModel], String, PHAsset)] = []
    var archivedModelArray:[[String:VideoModel]]?
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForDirectory()
        tableView.allowsSelection = false
        imageManager = PHImageManager.defaultManager()
        
        fetchResults()
        
        
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       return masterVideoArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        print("cell for row ran")
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        let tempTuple = masterVideoArray[indexPath.row]
        let tempDict = tempTuple.0
        
        if let videoModel = tempDict[tempTuple.1]{
            cell.videoLength.text = videoModel.durationString
            cell.title.text = videoModel.title
        }
        
        cell.videoBtn.tag = indexPath.row
        cell.delegate = self
        
        imageManager!.requestImageForAsset(tempTuple.2, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .AspectFill, options: nil) { (result, _ ) in
       
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? VideoCell {

                cell.videoBtn.setBackgroundImage(result, forState: UIControlState.Normal)
            }
        }

        return cell
    }
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "VideoPlayer" {
            
            if let playerVC = segue.destinationViewController as? AVPlayerVC {
                
                dispatch_async(dispatch_get_main_queue()) {playerVC.player = self.player}
            }
        }
    }
    
    
    func launchVideo(index: Int) {
        
        let videoObject = masterVideoArray[index]
        
        let result = PHAsset.fetchAssetsWithLocalIdentifiers([videoObject.1], options: nil)
        
        result.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            let video = asset as! PHAsset
            
            self.imageManager!.requestPlayerItemForVideo(video, options: nil) { (playerItem, info) -> Void in
                
                self.player = AVPlayer(playerItem: playerItem!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("VideoPlayer", sender: self)
                })
            }
        }
    }
    
    func checkForDirectory() {
        let filemgr = NSFileManager.defaultManager()
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        
        let docsDir = dirPaths[0]
        dataFilePath = docsDir.stringByAppendingPathComponent("data.archive")
        
        if filemgr.fileExistsAtPath(dataFilePath!) {
            archivedModelArray = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!) as? [[String: VideoModel]]
            print("found models")
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
                print("archived models exists")
                for dict in archivedData {
                    for (key,value) in dict {
                        print("enumerating")
                        if key == videoAsset.identifier {
                            print("found matching key in archive")
                            videoDict[key] = value
                        }
                    }
                }
            }
            
            let tuple = (videoDict, videoAsset.identifier, asset as! PHAsset)
            tempArray.append(tuple)
            self.masterVideoArray = tempArray
            
            print("done syncing data")
            
        })

    }
    

    

}