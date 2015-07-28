//
//  AVPlayerVC.swift
//  videoShare
//
//  Created by JOHN YAM on 7/6/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//

import Foundation
import AVKit
import UIKit
import Photos

class AVPlayerVC: AVPlayerViewController {
    
    let imageManager = PHImageManager.defaultManager()
    

    
    var videoAsset: PHAsset? {
        didSet {
            configureView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func configureView() {
//        if let vAsset = videoAsset {
//            imageManager?.requestPlayerItemForVideo(vAsset, options: nil, resultHandler: { (playerItem, info) -> Void in
//               self.player = AVPlayer(playerItem: playerItem)
//            })
//        }
    }
}