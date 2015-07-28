//
//  PreviewLayerVC.swift
//  videoShare
//
//  Created by JOHN YAM on 5/1/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//

import UIKit
import AVFoundation


class PreviewLayerVC: UIViewController {

    var pLayer = AVCaptureVideoPreviewLayer()
    var session: AVCaptureSession!
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        pLayer = AVCaptureVideoPreviewLayer(session: session)
        pLayer.frame = view.bounds
        
        //Indicates how the video is displayed within a player layer’s bounds rect.
        pLayer.videoGravity = AVLayerVideoGravityResizeAspect
        
        view.layer.insertSublayer(pLayer, atIndex: 0)
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        return UIInterfaceOrientation.Portrait
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
