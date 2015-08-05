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

class LibraryTableView: UIViewController {
    
    @IBOutlet weak var tableViewHeader: UIView! {
        didSet {
            tableViewHeader.backgroundColor = UIColor(red:0.17, green:0.19, blue:0.22, alpha:1)
        }
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.allowsSelection = true
        }
    }
    
    @IBOutlet weak var tagTableView: UITableView! {
        didSet {
            tagTableView.backgroundColor = UIColor.magentaColor()
        }
    }
    @IBOutlet weak var tagTableViewRighConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var tagBtn: UIButton!
    
    var searchBar: UISearchBar!
    
    var searchBarHidden: Bool {
        return tableView.contentOffset.y > 0
    }
    
    var isTagViewHidden = true
    
    var disableBarBtns: Bool? {
        didSet {
            searchBtn.enabled = disableBarBtns!
            tagBtn.enabled = disableBarBtns!
        }
    }

    var imageManager = PHImageManager.defaultManager()
    var player: AVPlayer?
    
    
    var location: CGPoint?
    var prevLocation: CGPoint?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DataManager.sharedInstance.checkForDirectory()
        DataManager.sharedInstance.fetchResults()
        
        searchBar = UISearchBar(frame: CGRectMake(0, 0, screenHeight, 50))
        searchBar.delegate = self
        tableView.tableHeaderView = searchBar
        print("frames: \(tagTableView.frame.origin.x), screen width: \(screenWidth)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        hideSearchBar()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "VideoPlayer" {
            
            if let playerVC = segue.destinationViewController as? AVPlayerVC {
                
                dispatch_async(dispatch_get_main_queue()) {playerVC.player = self.player}
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
    
    @IBAction func tagBtnTapped(sender: AnyObject) {
        
        tagTableViewRighConstraint.constant = (isTagViewHidden ? 0 : -200)
        !isTagViewHidden
    
        UIView.animateWithDuration(0.5) { () -> Void in
                self.view.layoutIfNeeded()
        }
        
    }
    
    func backToCamera() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    //MARK: Touches for top bar

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            location = touch.locationInView(self.view)
            prevLocation = location
            
            if (location!.y < searchBar.frame.height && location!.y - prevLocation!.y > 20){
                tableViewHeader.touchesMoved(touches, withEvent: event)
            }
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            
            location = touch.locationInView(self.view)
            tableViewHeader.frame = CGRectMake(0, location!.y - 10, tableViewHeader.frame.size.width, tableViewHeader.frame.size.height)
            
            if (location!.y > 200) {
                
                tableViewHeader.frame = CGRectMake(0, 200, tableViewHeader.frame.size.width, tableViewHeader.frame.size.height);
            }
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if (location!.y - prevLocation!.y > 20) {
            slideTopBarToY(200)
            
        } else if (location!.y - prevLocation!.y > 0 && location!.y - prevLocation!.y <= 20) {
            slideTopBarToY(200)
            
        } else if (location!.y - prevLocation!.y < -20) {
            slideTopBarToY(0)
            
        } else if (location!.y - prevLocation!.y < 0 && location!.y - prevLocation!.y >= -20) {
            slideTopBarToY(0)
        }
    }
    
    func slideTopBarToY(yPoint: CGFloat) {
        
        UIView.animateWithDuration(0.25, animations: { () -> Void in
 
            self.tableViewHeader.frame = CGRectMake(0, yPoint, self.tableViewHeader.frame.size.width, self.tableViewHeader.frame.size.height)
            self.view.layoutIfNeeded()
        })
    }
   
}

//MARK: TableView Delegate & DataSource

extension LibraryTableView: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count = Int()
        
        if tableView == self.tableView {
            count = DataManager.sharedInstance.getDataArray().count
        } else if tableView == tagTableView {
            count = 10
        }
        return count
}
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var returningCell: UITableViewCell?
        
        if tableView == self.tableView {
        
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
                returningCell = cell
            
        } else if tableView == tagTableView {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("tagsCell", forIndexPath: indexPath)
            returningCell = cell
        }

        return returningCell!
    }
    
}

// MARK: Search Bar Delegate Methods

extension LibraryTableView: UISearchBarDelegate {
    
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
}

extension LibraryTableView: VideoCellProtocol {
    
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
    
    func editInfo(index: Int) {

        if let vc = storyboard?.instantiateViewControllerWithIdentifier("videoDetailedInfo") as? VideoDetailVC {
        
            let dataArray = DataManager.sharedInstance.getDataArray()[index]
            let dict = dataArray.0
            vc.video = dict[dataArray.1]
            vc.asset = dataArray.2
            
            self.imageManager.requestPlayerItemForVideo(dataArray.2, options: nil) { (playerItem, info) -> Void in

                vc.player = AVPlayer(playerItem: playerItem!)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    navigationController?.pushViewController(vc, animated: true)
                })
            }
        }
    }
    
}