//
//  Menu.swift
//  videoShare
//
//  Created by JOHN YAM on 6/25/15.
//  Copyright (c) 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit

protocol MenuProtocol {
    
    func adjustExposure(sender: UISlider)
    func adjustTemp(sender: UISlider)
    func adjustTint(sender: UISlider)
}

class Menu: UIVisualEffectView {
    var delegate: MenuProtocol?
    var exposureSlider = UISlider()
    var tempSlider = UISlider()
    var tintSlider = UISlider()
    var sliders: [UISlider] = []
    

    override init(effect: UIVisualEffect?) {
        
        sliders += [exposureSlider, tempSlider, tintSlider]
        
        let menuItemHeight:CGFloat = 60
        let borderSpacing: CGFloat = 2
        
        let menuHeight: CGFloat = CGFloat(sliders.count) * (menuItemHeight + borderSpacing)
        
        super.init(effect: effect)
    
        backgroundColor = UIColor.clearColor()
        
        let orientation = UIDevice.currentDevice().orientation
        
        if (orientation.isPortrait) {
            frame = CGRectMake(0, 0 - menuHeight, screenWidth, menuHeight)
            
        } else if (orientation.isLandscape) {
            frame = CGRectMake(screenWidth + menuHeight, 0, screenWidth, menuHeight)
        }
        
        
        for (i, slider) in sliders.enumerate(){
            
            let bgView = UIView(frame: CGRectMake(0, CGFloat(i) * (borderSpacing + menuItemHeight), frame.width, menuItemHeight))
            bgView.backgroundColor = UIColor(red:0.84, green:0.93, blue:0.95, alpha:0.15)
            addSubview(bgView)
            
            let sliderNames = ["Exposure", "Temperature", "Tint"]
            
            slider.frame = CGRectMake(20, (bgView.frame.height - 10) / 2, screenWidth * 0.55, 20)
            slider.tintColor = UIColor(red:0.95, green:0.84, blue:0.32, alpha:1)
            bgView.addSubview(slider)
            
            let sliderToLabelSpace: CGFloat = 20
            let labelWidth: CGFloat = frame.width - slider.frame.width - slider.frame.origin.x - sliderToLabelSpace
            let label = UILabel(frame: CGRectMake(slider.frame.origin.x + slider.frame.width + sliderToLabelSpace, 0, labelWidth, bgView.frame.height))
            label.text = sliderNames[i]
            label.textAlignment = NSTextAlignment.Left
            bgView.addSubview(label)
            
        }

        exposureSlider.minimumValue = 0
        exposureSlider.maximumValue = 1
        exposureSlider.value = 0.5
        
        tempSlider.minimumValue = 3000
        tempSlider.maximumValue = 8000
      
        tintSlider.minimumValue = -150
        tintSlider.maximumValue = 150
        
        if (orientation.isLandscape) {
            transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
        }
        
        exposureSlider.addTarget(self, action: "exposureTapped:", forControlEvents: UIControlEvents.ValueChanged)
        tempSlider.addTarget(self, action: "tempTapped:", forControlEvents: UIControlEvents.ValueChanged)
        tintSlider.addTarget(self, action: "tintTapped:", forControlEvents: UIControlEvents.ValueChanged)
    }

    convenience init() {
        self.init(effect: UIBlurEffect(style: .Light))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func exposureTapped(sender: UISlider) {
        print("slide 0", appendNewline: false)
        self.delegate?.adjustExposure(sender)
    }
    
    func tempTapped(sender: UISlider) {
        print("slide 1", appendNewline: false)
        self.delegate?.adjustTemp(sender)
    }
    
    func tintTapped(sender: UISlider) {
        print("slide 2", appendNewline: false)
        self.delegate?.adjustTint(sender)
    }
}