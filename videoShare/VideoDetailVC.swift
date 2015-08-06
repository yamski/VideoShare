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
    
    @IBOutlet weak var topBar: UIView! {
        didSet {
            topBar.backgroundColor = UIColor(red:0.17, green:0.19, blue:0.22, alpha:1)
        }
    }
    var video: VideoModel!
    var asset: PHAsset!
    var avLayer: AVPlayerLayer!
    @IBOutlet weak var playerBackground: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        navigationController?.navigationBar.hidden = true
    }
    
    func configureView() {
        
        avLayer = AVPlayerLayer(player: player)
        avLayer.frame = CGRectMake(0, 75, screenWidth, screenWidth / 1.333)
        avLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        view.layer.addSublayer(avLayer)
    }
    
    
    @IBAction func goBack(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}
