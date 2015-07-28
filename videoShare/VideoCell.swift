//
//  VideoCell.swift
//  videoShare
//
//  Created by JOHN YAM on 7/22/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import Foundation
import UIKit

//extension UIButton {
//    @IBInspectable var cornerRadius: CGFloat {
//        get {
//            return layer.cornerRadius
//        }
//        set {
//            layer.cornerRadius = newValue
//            layer.masksToBounds = newValue > 0
//        }
//    }
//}

protocol DisplayVideoProtocol {
    func launchVideo(index: Int)
}

class VideoCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var title: UITextField! 
    @IBOutlet weak var videoLength: UILabel!
    @IBOutlet weak var cancelText: UIButton!
    @IBOutlet weak var saveText: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    
    var delegate: DisplayVideoProtocol?
    var index: Int!
    var videoModel: VideoModel!
    var videoIndentifier: String!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if title.text == "Untitled" {
            title.textColor = UIColor.lightGrayColor()
        } else {
            title.textColor = UIColor.greenColor()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.title.delegate = self
        hiddenBtns(hide: true)
    }
    
    
    @IBAction func videoBtnTapped(sender: AnyObject) {
        delegate?.launchVideo(sender.tag)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        videoBtn.enabled = false
        title.text = ""
        hiddenBtns(hide: false)
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {

        hiddenBtns(hide: true)
        videoBtn.enabled = true
        title.resignFirstResponder()
        layoutSubviews()
        
        if let newText = textField.text { videoModel.title = newText }
        DataManager.sharedInstance.updateModels(index, model: videoModel, identifier: videoIndentifier)
    }
    
    func hiddenBtns(hide hide: Bool) {
        cancelText.hidden = hide
        saveText.hidden = hide
    }
    

}
