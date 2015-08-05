//
//  VideoDetailVC.swift
//  videoShare
//
//  Created by JOHN YAM on 8/4/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import UIKit
import Photos

class VideoDetailVC: UIViewController {
    
    var player: AVPlayer! {
        didSet {
            configureView()
        }
    }
    
    var video: VideoModel!
    var asset: PHAsset!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.navigationBar.hidden = true
    }
    
    func configureView() {
        
        print("config")
        let avLayer = AVPlayerLayer(player: player)
        avLayer.frame = CGRectMake(0, 10, screenWidth, 200)
        view.layer.addSublayer(avLayer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
