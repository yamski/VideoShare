//
//  TagsViewController.swift
//  videoShare
//
//  Created by JOHN YAM on 8/6/15.
//  Copyright © 2015 John Yam. All rights reserved.
//

import UIKit

class TagsViewController: UIViewController {
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tagTextField: UITextField! {
        didSet {
            tagTextField.delegate = self
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: 400)
    }
    
    @IBAction func addTagsPressed(sender: AnyObject) {
        
        if let text = tagTextField.text {
            createTagBtnWithText(text)
        }
        tagTextField.resignFirstResponder()
    }

    @IBAction func dismissVC(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func createTagBtnWithText(text: String) {
        let btn = UIButton(frame: CGRectMake(20, 20, 60, 40))
        btn.backgroundColor = UIColor.orangeColor()
        btn.setTitle(text, forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(12)
        
        scrollView.addSubview(btn)
        
    }
}

extension TagsViewController: UITextFieldDelegate {
    
//    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
//        
//        return true
//    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        textField.text = ""
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        if let text = textField.text {
            createTagBtnWithText(text)
        }
        textField.resignFirstResponder()
        return true
    }
}