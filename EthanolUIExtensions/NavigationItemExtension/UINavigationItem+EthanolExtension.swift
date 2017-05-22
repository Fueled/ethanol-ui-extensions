//
//  UINavigationItemExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 14/08/15.
//  Copyright (c) 2015 Fueled Digital Media, LLC.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation

private let kAttributedTitleLabelTag = 325
private let kBackButtonWidth: CGFloat = 75.0
private let kBackButtonHeight: CGFloat = 32.0

private var customBackButtonKey: UInt8 = 1
private var attributedTitleKey: UInt8 = 2

extension UINavigationItem {
	
	/**
	*  Adds a custom back button.
	*  @param title The custom back button title.
	*  @param target The navigationItem's ViewController where custom back button is to be added.
	*  @param selector The selector to be executed on tapping custom back button.
	*/
	
	public func setCustomBackButtonWithTitle(_ title: String, target: AnyObject, selector: Selector) -> Void {
		self.setCustomBackButtonWithTitle(title, image: nil, target: target, selector: selector)
	}
	
	
	/**
	*  Adds a custom back button.
	*  @param image The custom back button image.
	*  @param target The navigationItem's ViewController where custom back button is to be added.
	*  @param selector The selector to be executed on tapping custom back button.
	*/
	
	public func setCustomBackButtonWithImageName(_ image: UIImage, target: AnyObject, selector: Selector) -> Void {
		self.setCustomBackButtonWithTitle(nil, image: image, target: target, selector: selector)
	}
	
	/**
	*  Adds a custom back button. Either title or imageName should be passed to see the newly added custom back button.
	*  @param title The custom back button title.
	*  @param image The custom back button image.
	*  @param target The navigationItem's ViewController where custom back button is to be added.
	*  @param selector The selector to be executed on tapping custom back button.
	*/
	
	public func setCustomBackButtonWithTitle(_ title: String? , image: UIImage?, target: AnyObject, selector: Selector) -> Void {
		self.hidesBackButton = true
		let backButton = UIButton(type: UIButtonType.custom)
		backButton.isExclusiveTouch = true
		let frame = CGRect(x: 0.0, y: 0.0, width: kBackButtonWidth, height: kBackButtonHeight)
		backButton.frame = frame
		
		var imageWidth: CGFloat = 0.0
		if let image = image {
			imageWidth = image.size.width
			backButton.setImage(image, for: UIControlState())
		}
		
		if let title = title {
			backButton.setTitle(title, for: UIControlState())
			backButton.setTitleColor(UIColor.black, for: UIControlState())
		}
		
		backButton.addTarget(target, action: selector, for: UIControlEvents.touchUpInside)
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
	
	public var customBackButtonTitle: String? {
		get {
			return self.customBackButton?.title(for: UIControlState())
		}
	}
	
	/**
	
	*  UIButton to be used as the custom back button of NavigationItem.
	
	*  Returns the custom back button or nil if none has been added yet.
	*  customBackButton An optional 'UIButton' object representing custom back button.
	*/
	
	fileprivate (set)  public var customBackButton: UIButton? {
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
			let label: UILabel
			if let currentLabel = self.labelForAttributedTitle() {
				label = currentLabel
			} else {
				label = UILabel()
				label.tag = kAttributedTitleLabelTag
				self.titleView = label
			}
			
			label.attributedText = attributedTitle
			label.textAlignment = NSTextAlignment.center
			label.sizeToFit()
		}
	}
	
	fileprivate func labelForAttributedTitle() -> UILabel? {
		var label : UILabel? = nil
		if let currentLabel = self.titleView as? UILabel , currentLabel.tag == kAttributedTitleLabelTag {
			label = currentLabel
		}
		return label
	}
	
}
