//
//  UIScrollView+ETHKeyboardHandlerScrollviewExtension.swift
//  EthanolUIExtensions
//
//  Created by svs-fueled on 14/08/15.
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
import ObjectiveC
import EthanolTools

/**
UIScrollView Extension to handle keyboard notifications internally by
manipulating the content inset of the scrollview
*/

public extension UIScrollView {
	
	/**
	*  Add observers for keyboard appearance and keyboard disappearance with the default notification block.
	*  The default block handles everything for you in term of keyboard management when a UITextField is selected.
	*  This method also adds a inset to the keyboard notifications
	*/
	public func eth_handleKeyboardNotificationsWithOffset(_ offset: CGFloat) {
		self.keyboardScrollOffset = offset
		self.eth_handleKeyboardNotifications()
	}
	
	/**
	* Add observers for keyboard appearance and keyboard disappearance with the default notification block.
	* The default block handles everything for you in term of keyboard management when a UITextField is selected.
	*/
	public func eth_handleKeyboardNotifications () {
		self.eth_registerForKeyboardNotificationsWithHandler(eth_defaultKeyboardNotificationBlock())
	}
	
	/**
	Remove observers for keyboard appearance and keyboard disappearance with the default notification block.
	*/
	public func eth_stopHandlingKeyboardNotifications() {
		self.eth_deRegisterForKeyboardNotifications()
	}
	
	/**
	*  Get the default block implementation used with -handleKeyboardNotfications.
	*
	*  @return The default block. Is never nil.
	*/
	public func eth_defaultKeyboardNotificationBlock() -> KeyboardNotificationBlock {
		return { [weak self](isShowing, notificationState, startKeyboardRect, endKeyboardRect, duration, options) -> Void in
			if let this = self {
				this.handleReceivedKeyboardNotification(isShowing, notificationState: notificationState, startKeyboardRect: startKeyboardRect, endKeyboardRect: endKeyboardRect, duration: duration, options: options)
			}
		}
	}
	
}

private var keyboardScrollOffsetKey: UInt8 = 4
private var storedScrollViewBottomInsetKey: UInt8 = 5
private var storedScrollViewIndicatorBottomInsetKey: UInt8 = 6

public extension UIScrollView {
	
	fileprivate var keyboardScrollOffset: CGFloat {
		get {
			return (objc_getAssociatedObject(self, &keyboardScrollOffsetKey) as? CGFloat) ?? 0.0
		}
		set (offset) {
			objc_setAssociatedObject(self, &keyboardScrollOffsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	fileprivate var scrollViewBottomInset: CGFloat? {
		get {
			return objc_getAssociatedObject(self, &storedScrollViewBottomInsetKey) as? CGFloat
		}
		set (offset) {
			objc_setAssociatedObject(self, &storedScrollViewBottomInsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	fileprivate var scrollViewIndicatorBottomInset: CGFloat? {
		get {
			return objc_getAssociatedObject(self, &storedScrollViewIndicatorBottomInsetKey) as? CGFloat
		}
		set (offset) {
			objc_setAssociatedObject(self, &storedScrollViewIndicatorBottomInsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	/**
	Private function called within the default block to handle keyboard notifications
	Internally updates scrollview insets
	*/
	fileprivate func handleReceivedKeyboardNotification(_ isShowing: Bool, notificationState: KeyboardNotificationState, startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: TimeInterval, options:UIViewAnimationOptions) {
		guard let window = self.window else {
			return
		}
		
		let currentShowState = isShowing ? "show" : "hide"
		
		ETHLogTrace(message: "\(self) :Calling defaultKeyboardNotificationBlock: \(currentShowState), \(startKeyboardRect), \(endKeyboardRect), \(duration), \(options)")
		
		// Dont handle didshow/didhide states for a scrollview by default.
		if notificationState == .didShow || notificationState == .didHide {
			return
		}
		
		
		let keyboardOffset:CGFloat = keyboardScrollOffset
		
		if isShowing { // Will Show Keyboard!!!
			
			//Setting up original inset values in case show has been called repeatedly for the same,
			// already visible keyboard
			let bottomInset = scrollViewBottomInset ?? self.contentInset.bottom
			if scrollViewBottomInset == nil {
				scrollViewBottomInset = bottomInset
			}
			
			let indicatorBottomInset = scrollViewIndicatorBottomInset ?? self.scrollIndicatorInsets.bottom
			if scrollViewIndicatorBottomInset == nil {
				scrollViewIndicatorBottomInset = indicatorBottomInset
			}
			
			let screenBounds = UIScreen.main.bounds
			let positionInWindow = window.convert(self.frame.origin, from: self.superview)
			let absoluteHeight = positionInWindow.y + self.frame.size.height + self.contentOffset.y
			
			//Determining if keyboard interferes with the content of the scrollview in anyway.
			if absoluteHeight >= (screenBounds.size.height - endKeyboardRect.size.height) {
				var offset = max(0.0, screenBounds.size.height-absoluteHeight)
				
				ETHLogVerbose(message: "\(self) : KeyboardNotificationBlock Show : Base offset is \(offset), keyboard offset is \(keyboardOffset)")
				offset -= keyboardOffset
				offset = endKeyboardRect.size.height - offset
				
				
				ETHLogDebug(message: "\(self) : Keyboard notification block (show): calculated offset is \(offset) (Initial bottom offset: \(bottomInset))")
				
				ETHLogVerbose(message: "\(self) : Keyboard notification block (show): initial indicator offset is \(indicatorBottomInset)")
				
				
				let animationClosure = { ()->() in
					var edgeInsets = self.contentInset
					edgeInsets.bottom = offset + bottomInset
					self.contentInset = edgeInsets
					
					edgeInsets = self.scrollIndicatorInsets
					self.scrollIndicatorInsets.bottom = offset + indicatorBottomInset
					self.scrollIndicatorInsets = edgeInsets
				}
				
				UIView.animate(withDuration: duration,
					delay: 0.0,
					options: options,
					animations:animationClosure,
					completion: { (finished) -> Void in
						animationClosure()
				})
			} else {
				ETHLogInfo(message: "\(self) : No need to reduce any viewable area, the keyboard is not interfering with the scrollview")
			}
		} else {
			let bottomInset:CGFloat = self.scrollViewBottomInset ?? 0.0
			let indicatorBottomInset:CGFloat = self.scrollViewIndicatorBottomInset ?? 0.0
			
			ETHLogDebug(message: "\(self) : Keyboard notification block (hide): initial offset is \(bottomInset)")
			
			ETHLogVerbose (message: "\(self) : Keyboard notification block (hide): initial indicator offset is \(indicatorBottomInset)")
			
			let animationClosure = { ()->() in
				var edgeInsets = self.contentInset
				edgeInsets.bottom = bottomInset
				self.contentInset = edgeInsets
				edgeInsets = self.scrollIndicatorInsets
				self.scrollIndicatorInsets.bottom = indicatorBottomInset
				self.scrollIndicatorInsets = edgeInsets
			}
			
			UIView.animate(withDuration: duration,
				delay: 0.0,
				options: options,
				animations:animationClosure,
				completion: { (finished) -> Void in
					animationClosure()
					self.scrollViewBottomInset = nil
					self.scrollViewIndicatorBottomInset = nil
			})
			
		}
	}
}
