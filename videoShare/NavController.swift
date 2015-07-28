//
//  NavController.swift
//  videoShare
//
//  Created by JOHN YAM on 5/4/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit

class NavController: UINavigationController {
    
    override func shouldAutorotate() -> Bool {
        
        let topVC = self.topViewController
        return topVC!.shouldAutorotate()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        let topVC = self.topViewController
        return topVC!.supportedInterfaceOrientations()
    }
    
    
}
