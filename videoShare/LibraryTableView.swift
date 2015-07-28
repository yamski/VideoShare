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
    var assetModels = [VideoModel]()
    var assets: [PHAsset] = []
    
    var videoDict = [String: VideoModel]()
    
    var imageManager: PHImageManager?
    var player: AVPlayer?
    var dataFilePath: String?
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForDirectory()
        tableView.allowsSelection = false
        imageManager = PHImageManager.defaultManager()
        
        videoResults = PHAsset.fetchAssetsWithMediaType(PHAssetMediaType.Video, options: nil)
        
        videoResults?.enumerateObjectsUsingBlock({ (asset, index, stop ) -> Void in
            
            self.assets.append(asset as! PHAsset)
            
            let videoAsset = VideoModel(asset: asset as! PHAsset, duration: asset.duration)
            
//            self.assetModels.append(videoAsset)
            
            self.mergeVideoCollection(videoAsset)
            
            
        })
        
        
      
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

       return assetModels.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        let asset = assetModels[indexPath.row]
        cell.videoBtn.tag = indexPath.row
        cell.delegate = self
        cell.videoLength.text = asset.durationString
        cell.title.text = asset.title
        
        imageManager!.requestImageForAsset(assets[indexPath.row], targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .AspectFill, options: nil) { (result, _ ) in
       
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
        
        let videoObject = assetModels[index]
        
        let result = PHAsset.fetchAssetsWithLocalIdentifiers([videoObject.identifier], options: nil)
        
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
            assetModels = NSKeyedUnarchiver.unarchiveObjectWithFile(dataFilePath!) as! [VideoModel]
            print("found models")
        }
    }

    
    func archiveVideo() {
        
        if NSKeyedArchiver.archiveRootObject(assetModels, toFile: dataFilePath!) {
            print("Success writing to file!")
        } else {
            print("Unable to write to file!")
        }
    }
    
    var archiveDict:[String:VideoModel]?
    func mergeVideoCollection(video: VideoModel) {
        
        videoDict[video.identifier] = video
        
        for (key,value) in archiveDict! {
            if key == video.identifier {
                videoDict[key] = value
            }
        }
        
    //test
    }

}