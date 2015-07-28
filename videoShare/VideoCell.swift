//
//  VideoCell.swift
//  videoShare
//
//  Created by JOHN YAM on 7/22/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

protocol DisplayVideoProtocol {
    func launchVideo(index: Int)
    func archiveVideo()
}

@IBDesignable class VideoCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var title: UITextField! {

        didSet {
            if (title.text != "Untitled") {
                title.textColor = UIColor(red:0.88, green:0.88, blue:0.88, alpha:1)
            } else {
                title.textColor = UIColor(red:0.12, green:0.29, blue:0.41, alpha:1)
            }
        }
    }
    @IBOutlet weak var videoLength: UILabel!
    @IBOutlet weak var cancelText: UIButton!
    @IBOutlet weak var saveText: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    
    var delegate: DisplayVideoProtocol?
    var index: Int?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.title.delegate = self
        hiddenBtns(hide: true)
    }
    
    
    @IBAction func videoBtnTapped(sender: AnyObject) {
        print("video btn pressed. tag #: \(sender.tag)")
        delegate?.launchVideo(sender.tag)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        videoBtn.enabled = false
        title.text = ""
        hiddenBtns(hide: false)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if title.text == "" {title.text = "Untitled"}
        hiddenBtns(hide: true)
        videoBtn.enabled = true
        title.resignFirstResponder()
        
        self.delegate?.archiveVideo()
    
    }
    
    func hiddenBtns(hide hide: Bool) {
        cancelText.hidden = hide
        saveText.hidden = hide
    }
    

}
