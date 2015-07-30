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

class LibraryTableView: UIViewController, UITableViewDataSource, UITableViewDelegate, VideoCellProtocol {
    
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tagBtn: UIButton!
    
    @IBOutlet weak var searchBar: UIView!
    
    @IBOutlet weak var searhBarPosY: NSLayoutConstraint!
    var imageManager = PHImageManager.defaultManager()
    var player: AVPlayer?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataManager.sharedInstance.checkForDirectory()
        DataManager.sharedInstance.fetchResults()
        tableView.allowsSelection = false
        
        print(self.searchBar.frame.origin.y)
        
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cell count: \(DataManager.sharedInstance.masterVideoArray.count)")
       return DataManager.sharedInstance.masterVideoArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        let tempTuple = DataManager.sharedInstance.masterVideoArray[indexPath.row]
        let tempDict = tempTuple.0
        
        if let videoModel = tempDict[tempTuple.1]{
            
            cell.videoModel = videoModel
            cell.videoIndentifier = videoModel.identifier
            cell.videoLength.text = videoModel.durationString
            cell.title.text = videoModel.title
            cell.indexPath = indexPath
        }
        
        cell.delegate = self
        cell.videoBtn.tag = indexPath.row
        cell.tableView = tableView
        
        imageManager.requestImageForAsset(tempTuple.2, targetSize: CGSize(width: 100.0, height: 100.0), contentMode: .AspectFill, options: nil) { (result, _ ) in
       
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
        
        let videoObject = DataManager.sharedInstance.masterVideoArray[index]
        
        let result = PHAsset.fetchAssetsWithLocalIdentifiers([videoObject.1], options: nil)
        
        result.enumerateObjectsUsingBlock { (asset, index, stop) -> Void in
            
            let video = asset as! PHAsset
            
            self.imageManager.requestPlayerItemForVideo(video, options: nil) { (playerItem, info) -> Void in
                
                self.player = AVPlayer(playerItem: playerItem!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.performSegueWithIdentifier("VideoPlayer", sender: self)
                })
            }
        }
    }
    
    @IBAction func searchBtnTapped(sender: AnyObject) {
        print("search btn tapped")
        self.view.layoutIfNeeded()
        self.searhBarPosY.constant = 0

        UIView.animateWithDuration(0.25, animations: { () -> Void in
      
            self.view.layoutIfNeeded()
            }) { (suceeded) -> Void in
        print(self.searchBar.frame)
        }
    }
    
    @IBAction func tagBtnTapped(sender: AnyObject) {
    }

   
}