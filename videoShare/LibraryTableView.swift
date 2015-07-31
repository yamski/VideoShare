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

class LibraryTableView: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate ,VideoCellProtocol {
    
    @IBOutlet weak var tableViewHeader: UIView!
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.allowsSelection = false
        }
    }
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tagBtn: UIButton!
    var searchBar: UISearchBar!
    var searchBarHidden: Bool {
        get {
            return tableView.contentOffset.y > 0
        }
    }
    var disableBarBtns: Bool? {
        didSet {
            searchBtn.enabled = disableBarBtns!
            tagBtn.enabled = disableBarBtns!
        }
    }

    var imageManager = PHImageManager.defaultManager()
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedInstance.checkForDirectory()
        DataManager.sharedInstance.fetchResults()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, screenHeight, 50))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        hideSearchBar()
    }
    

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.sharedInstance.getDataArray().count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! VideoCell
        
        let dataArray = DataManager.sharedInstance.getDataArray()
        let tempTuple = dataArray[indexPath.row]
        
        print("printing creation date: \(tempTuple.2.creationDate)")
        let tempDict = tempTuple.0
        
        if let videoModel = tempDict[tempTuple.1] {
            
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
        
        let dataArray = DataManager.sharedInstance.getDataArray()
        let videoObject = dataArray[index]

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
    
        UIView.animateWithDuration(0.5) { () -> Void in
            
            if self.searchBarHidden {
                self.tableView.contentOffset = CGPointMake(0, 0)
            } else {
                self.hideSearchBar()
            }
        }
    }
    
    func hideSearchBar() {
        searchBar.resignFirstResponder()
  
        
        let contentOffset = self.tableView.contentOffset;
        let height: CGFloat = CGRectGetHeight(self.tableView.tableHeaderView!.frame);
        let point = CGPoint(x: 0,y: height)
        let newOffSet =  CGPoint(x: contentOffset.x, y: contentOffset.y + point.y)
        self.tableView.contentOffset = newOffSet;
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        if let enteredText = searchBar.text {
            DataManager.sharedInstance.filteredArray = DataManager.sharedInstance.masterVideoArray.filter({
                let dict = $0.0
                let key = $0.1 as String
                let videoModel = dict[key]
                
                return videoModel!.title?.rangeOfString(enteredText, options: .CaseInsensitiveSearch) !=  nil
            })
            tableView.reloadData()
        }
    }
    
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        hideSearchBar()
        searchBar.resignFirstResponder()
    }
    
    @IBAction func tagBtnTapped(sender: AnyObject) {
        print("filtered array \(DataManager.sharedInstance.filteredArray)")
        self.dismissViewControllerAnimated(true, completion: nil)
    }

   
}