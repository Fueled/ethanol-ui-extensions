//
//  UINavigationItemExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//


import Foundation

let kAttributedTitleLabelTag = 325

let kBackButtonWidth: CGFloat = 75.0
let kNavigationBarHeight: CGFloat = 44.0

extension UINavigationItem {
  
  public func setCustomBackButtonWithTitle(title:String, target:UIViewController, selector: Selector) -> Void {
    self.setCustomBackButtonWithTitle(title, imageName: nil, target: target, selector: selector)
  }
  
  public func setCustomBackButtonWithImageName(imageName:String, target:UIViewController, selector: Selector) -> Void {
    self.setCustomBackButtonWithTitle(nil, imageName: imageName, target: target, selector: selector)
  }
  
  public func setCustomBackButtonWithTitle(title:String? , imageName:String?, target:UIViewController, selector: Selector) -> Void {
    self.hidesBackButton = true
    let backButton = UIButton(type: UIButtonType.Custom)
    backButton.exclusiveTouch = true
    
    let frame = CGRectMake(0.0, 0.0, kBackButtonWidth, kNavigationBarHeight)
    backButton.frame = frame
    
    var imageWidth: CGFloat = 0.0
    if let imageName = imageName {
      let image = UIImage(named: imageName)
      imageWidth = (image?.size.width)!
      backButton.setImage(image, forState: UIControlState.Normal)
    }
    
    if let title = title {
      backButton.setTitle(title, forState: UIControlState.Normal)
      backButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    backButton.addTarget(target, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
    let edgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, kBackButtonWidth - imageWidth)
    backButton.imageEdgeInsets = edgeInsets
    
    self.leftBarButtonItem = UIBarButtonItem(customView: backButton)
  }
  
  public func customBackButtonTitle()-> String? {
    var title: String? = ""
    
    if let backButton = self.customBackButton(){
      title = backButton.titleForState(UIControlState.Normal)
    }
    
    return title
  }
  
  public func customBackButton()-> UIButton? {
    var backButton: UIButton? = nil

    if let customView = self.leftBarButtonItem?.customView {
      if customView.isKindOfClass(UIButton) {
         backButton = customView as? UIButton
      }
    }
    return backButton
  }
  
  public func setAttributedTitle(attributedTitle:NSAttributedString){
    var label = self.labelForAttributedTitle()
    
    if label == nil {
      label = UILabel()
      label!.tag = kAttributedTitleLabelTag
      self.titleView = label
    }
    
    label?.attributedText = attributedTitle
    label?.textAlignment = NSTextAlignment.Center
    label?.sizeToFit()
  }
  
  func labelForAttributedTitle() -> UILabel? {
    var label : UILabel? = nil
    
    if let titleView = self.titleView {
      if titleView.isKindOfClass(UILabel) {
          label = titleView as? UILabel
        if label?.tag != kAttributedTitleLabelTag {
          label = nil
        }
      }
    }
    return label
  }
  
}
