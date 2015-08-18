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

private var customBackButtonKey: UInt8 = 1
private var attributedTitleKey: UInt8 = 2

extension UINavigationItem {
  
  /**
  *  Adds a custom back button.
  *  @param title The custom back button title.
  *  @param target The navigationItem's ViewController where custom back button is to be added.
  *  @param selector The selector to be executed on tapping custom back button.
  */
  
  public func setCustomBackButtonWithTitle(title: String, target: UIViewController, selector: Selector) -> Void {
    self.setCustomBackButtonWithTitle(title, image: nil, target: target, selector: selector)
  }
  
  
  /**
  *  Adds a custom back button.
  *  @param image The custom back button image.
  *  @param target The navigationItem's ViewController where custom back button is to be added.
  *  @param selector The selector to be executed on tapping custom back button.
  */
  
  public func setCustomBackButtonWithImageName(image: UIImage, target: UIViewController, selector: Selector) -> Void {
    self.setCustomBackButtonWithTitle(nil, image: image, target: target, selector: selector)
  }
  
  /**
  *  Adds a custom back button. Either title or imageName should be passed to see the newly added custom back button.
  *  @param title The custom back button title.
  *  @param image The custom back button image.
  *  @param target The navigationItem's ViewController where custom back button is to be added.
  *  @param selector The selector to be executed on tapping custom back button.
  */
  
  public func setCustomBackButtonWithTitle(title: String? , image: UIImage?, target: UIViewController, selector: Selector) -> Void {
    self.hidesBackButton = true
    let backButton = UIButton(type: UIButtonType.Custom)
    backButton.exclusiveTouch = true

    let navBarHeight = target.navigationController!.navigationBar.frame.size.height
    let frame = CGRectMake(0.0, 0.0, kBackButtonWidth, navBarHeight)
    backButton.frame = frame
    
    var imageWidth: CGFloat = 0.0
    if let image = image {
      imageWidth = image.size.width
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
    self.customBackButton = backButton
  }
  
  /**
  *  Removes custom back button if any has been added.
  */
  public func removeCustomBackButton(){
    if let _ = self.customBackButton {
      self.leftBarButtonItem = nil
      self.customBackButton = nil
    }
  }
  
  /**
  *  Returns the title of a custom back button or nil if none has been added yet.
  *  @return title An optional 'String' object representing title of custom back button.
  */
  
  public func customBackButtonTitle() -> String? {
    return self.customBackButton?.titleForState(UIControlState.Normal)
  }
  
  /**
  
  *  UIButton to be used as the custom back button of NavigationItem.

  *  Returns the custom back button or nil if none has been added yet.
  *  customBackButton An optional 'UIButton' object representing custom back button.
  */
  
  private (set)  public var customBackButton: UIButton? {
    get {
      return objc_getAssociatedObject(self, &customBackButtonKey) as? UIButton
    }
    set(backButton){
      objc_setAssociatedObject(self, &customBackButtonKey, backButton, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  
  /**
  *  NSAttributedString to be used as the title of NavigationItem.
  */
  
  public var attributedTitle: NSAttributedString? {
    get {
      return  self.labelForAttributedTitle()?.attributedText
    }
    set(attributedTitle){
      self.setAttributedTitle(attributedTitle)
    }
  }
  
  private func setAttributedTitle(attributedTitle:NSAttributedString?){
    let label: UILabel
    if let currentLabel = self.labelForAttributedTitle() {
      label = currentLabel
    } else {
      label = UILabel()
      label.tag = kAttributedTitleLabelTag
      self.titleView = label
    }
    
    label.attributedText = attributedTitle
    label.textAlignment = NSTextAlignment.Center
    label.sizeToFit()
  }
  

  private func labelForAttributedTitle() -> UILabel? {
    var label : UILabel? = nil
    if let currentLabel = self.titleView as? UILabel where currentLabel.tag == kAttributedTitleLabelTag {
      label = currentLabel
    }
    return label
  }
  
}
