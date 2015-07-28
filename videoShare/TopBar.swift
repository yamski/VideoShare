//
//  File.swift
//  videoShare
//
//  Created by JOHN YAM on 6/25/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit

protocol TopButtonProtocol {
    func checkFlash()
    func showHideMenu()
    func selectCamera()
}

class TopBar: UIView {
    
    var delegate: TopButtonProtocol?
    let timeLabel: UILabel!
    let adjustMenuBtn: UIButton!
    let toggleCameraBtn: UIButton!
    let flashBtn: UIButton!
    let flashLabel: UILabel!
    
    override init(frame: CGRect) {

        let itemHeight: CGFloat = 40
        let itemPlacement = (frame.height - itemHeight)/2
        let imageSpacing = 45 as CGFloat
        
        timeLabel = UILabel(frame: CGRectMake(frame.width - 105, itemPlacement , 80, itemHeight))
        timeLabel.textAlignment = NSTextAlignment.Center
        timeLabel.text = "00:00:00"
        timeLabel.font = UIFont.systemFontOfSize(20)
        timeLabel.textColor = UIColor.blackColor()
        
        flashBtn = UIButton(frame: CGRectMake(timeLabel.frame.origin.x - imageSpacing - itemHeight, itemPlacement, itemHeight, itemHeight))
        flashBtn.setImage(UIImage(named: "flash"), forState: .Normal)
        flashBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        flashLabel = UILabel(frame: CGRectMake(flashBtn.frame.origin.x + flashBtn.frame.width - 10 , frame.height/2 - 10, 30, 20))
        flashLabel.font = UIFont.systemFontOfSize(12)
        flashLabel.text = "OFF"
     
        adjustMenuBtn = UIButton(frame: CGRectMake(25, itemPlacement, itemHeight, itemHeight))
        adjustMenuBtn.backgroundColor = UIColor.clearColor()
        adjustMenuBtn.setTitle("- / +", forState: .Normal)
        adjustMenuBtn.titleLabel?.font = UIFont.systemFontOfSize(20)
        adjustMenuBtn.setTitleColor(UIColor.blackColor(), forState: .Normal)
        
        toggleCameraBtn = UIButton(frame: CGRectMake(adjustMenuBtn.frame.origin.x + adjustMenuBtn.frame.width + imageSpacing, itemPlacement, itemHeight, itemHeight))
        toggleCameraBtn.setImage(UIImage(named: "rotatecamera.png"), forState: .Normal)
        toggleCameraBtn.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        
        super.init(frame: frame)
        
        backgroundColor = UIColor(red:0.95, green:0.84, blue:0.32, alpha:0.75)
        
        flashBtn.addTarget(self, action: "flashTapped", forControlEvents: .TouchUpInside)
        adjustMenuBtn.addTarget(self, action: "menuBtnTapped", forControlEvents: .TouchUpInside)
        toggleCameraBtn.addTarget(self, action: "camerBtnTapped", forControlEvents: .TouchUpInside)
        
        addSubview(timeLabel)
        addSubview(flashBtn)
        addSubview(flashLabel)
        addSubview(adjustMenuBtn)
        addSubview(toggleCameraBtn)
        
    }
    
    convenience init() {
        self.init(frame: CGRectMake(0, 0, screenWidth, 50))
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func flashTapped() {
        self.delegate?.checkFlash()
    }
    
    func menuBtnTapped() {
        self.delegate?.showHideMenu()
    }
    
    func camerBtnTapped() {
        self.delegate?.selectCamera()
    }
    
}