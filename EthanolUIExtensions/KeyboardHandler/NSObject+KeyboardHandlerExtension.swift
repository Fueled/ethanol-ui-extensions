//
//  NSObject+ETHKeyboardHandlerObjectExtension.swift
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

/** Helper block to convert UIViewAnimationCurve to UIViewAnimationOptions */

public let UIAnimationOptionsFromCurve = {(curve : UIViewAnimationCurve) -> UIViewAnimationOptions in
	switch (curve) {
	case .EaseInOut:
		return .CurveEaseInOut
	case .EaseIn:
		return .CurveEaseIn
	case .EaseOut:
		return .CurveEaseOut
	case .Linear:
		return .CurveLinear
	}
}

/** Enum describing keyboard notification which triggered the callback */

@objc public enum KeyboardNotificationState: NSInteger {
	case DidShow
	case DidHide
	case WillShow
	case WillHide
}

/** Helper typecast for Notification handler Block */

public typealias KeyboardNotificationBlock = (isShowing: Bool, notificationState: KeyboardNotificationState,startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions) -> Void

/**
ETHKeyboardHandlerObjectExtension Extends NSObjects to begin handling keyboard
notifications.
*/

public extension NSObject {
	
	/**
	Public Method to add Observers for Keyboard Hide/Show Notifications and responds via a `KeyboardNotificationBlock` Handler.
	In Case the reciever is already observing notifications, this method simply replaces the handler with the new handler.
	*/
	
	final public func eth_registerForKeyboardNotificationsWithHandler(handler:KeyboardNotificationBlock) {
		self.notificationClosure = handler
		if !eth_observingNotifications { // Replaces handler if already observing
			registerForKeyboardNotifications()
		}
	}
	
	/** Public Method to Return ClassName if any, Can be overwritten by a subclass */
	
	public var ClassName: String {
		return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last ?? ">NSObject<"
	}
	
	/** Public method to Remove Observing from keyboard notifications */
	
	final public func eth_deRegisterForKeyboardNotifications() {
		self.eth_observingNotifications = false
		self.notificationClosure = nil
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
		ETHLogDebug("DERegistered Observers for keyboard Notification for object \(self) of class \(ClassName)")
	}
	
	/** Read Only variable to describe Keyboard State */
	
	final private (set) public var eth_keyboardShown: Bool {
		get {
			return objc_getAssociatedObject(self, &isKeyboardShownKey)?.boolValue ?? false
		}
		set (isShown) {
			objc_setAssociatedObject(self, &isKeyboardShownKey, isShown, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	/** Public variable for `KeyboardNotificationBlock` closures for keyboard notifications */
	final public var eth_keyboardNotificationBlock: KeyboardNotificationBlock? {
		get {
			return self.notificationClosure
		}
		set(block) {
			self.notificationClosure = block
		}
	}
	
	/**
	Get the displayed keyboard size. The size is CGSizeZero if the keyboard is not displayed.
	*/
	
	final public var eth_keyboardSize: CGSize {
		return self.keyboardSize
	}
	/** Read Only variable for determining if the object in question is currently observing keyboard Notifications */
	final private (set) public var eth_observingNotifications: Bool {
		get {
			return objc_getAssociatedObject(self, &isObservingNotificationsKey)?.boolValue ?? false
		}
		set (value) {
			objc_setAssociatedObject(self, &isObservingNotificationsKey, NSNumber(bool: value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
}


//MARK: - Private Methods
/** Private Methods */

public extension NSObject {
	
	private func registerForKeyboardNotifications() {
		//Adding Observers with blocks to avoid conflict with namespaces of owning NSObjects
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self](notification) -> Void in
			if let this = self where this.eth_observingNotifications {
				this.keyboardWillShow(notification)
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self](notification) -> Void in
			if let this = self where this.eth_observingNotifications {
				this.keyboardWillHide(notification)
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
			if let this = self where this.eth_observingNotifications {
				this.keyboardDidShow(notification)
			}
		}
		
		NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
			if let this = self where this.eth_observingNotifications {
				this.keyboardDidHide(notification)
			}
		}
		
		self.eth_observingNotifications = true
	}
	
	private func keyboardWillShow(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(true, notificationState: .WillShow, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	private func keyboardDidShow(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(true, notificationState: .DidShow, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	private func keyboardDidHide(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(false, notificationState: .DidHide, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	private func keyboardWillHide(notification: NSNotification) {
		guard let userInfo = notification.userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(false, notificationState: .WillHide, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	/** Internal Method to update Closure with data */
	private func respondToKeyboardNotificationsWithKeyboardShowing(isShowing: Bool, notificationState: KeyboardNotificationState, startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions) {
		self.eth_keyboardShown = isShowing
		if let closure = self.notificationClosure {
			closure(isShowing: isShowing, notificationState: notificationState, startKeyboardRect: startKeyboardRect, endKeyboardRect: endKeyboardRect, duration: duration, options: options)
		} else {
			ETHLogWarning("ETHLogWarn: There is no closure supplied to handle responses for Keyboard Notifications to object \(self)")
		}
	}
	
	/** Internal Method to Calculate data from Keyboard Hide/Show Notifications = (keyboard rects, duration and animation options)*/
	private func generateDataForKeyboardNotification(userInfo: [NSObject:AnyObject]) -> (endRect: CGRect, beginRect: CGRect, duration: Double, option: UIViewAnimationOptions) {
		let endKeyboardRect =  userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue ?? CGRectZero
		let beginKeyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue ?? CGRectZero
		let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.0
		let curve = UIViewAnimationCurve(rawValue:userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue ?? 0) ?? UIViewAnimationCurve.Linear
		let animationOption = UIAnimationOptionsFromCurve(curve)
		
		return (endRect: endKeyboardRect, beginRect: beginKeyboardRect, duration: duration, option: animationOption)
	}
}


/** State Methods */
private var keyboardNotificationHandlerClosureKey: UInt8 = 0
private var isKeyboardShownKey: UInt8 = 1
private var keyboardSizeKey: UInt8 = 2
private var isObservingNotificationsKey: UInt8 = 3

public extension NSObject {
	
	private var keyboardSize: CGSize {
		get {
			if let size = objc_getAssociatedObject(self, &keyboardSizeKey) {
				return size.CGSizeValue()
			}
			return CGSize.zero
		}
		set (value) {
			objc_setAssociatedObject(self, &keyboardSizeKey, NSValue(CGSize:value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	/** Keyboard Notification Closure */
	private var notificationClosure: KeyboardNotificationBlock? {
		get {
			let object = objc_getAssociatedObject(self, &keyboardNotificationHandlerClosureKey)
			let wrapper = object as? KeyboardNotificationHandlerWrapper
			return wrapper?.notificationClosure
		}
		set (closure) {
			if let closure = closure {
				let wrapperClass = KeyboardNotificationHandlerWrapper()
				wrapperClass.notificationClosure = closure
				objc_setAssociatedObject(self, &keyboardNotificationHandlerClosureKey, wrapperClass, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
				// This is retain and not copy because we now store the closure encapsulated within a class since we cannot store it directly.
			} else {
				objc_setAssociatedObject(self, &keyboardNotificationHandlerClosureKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			}
		}
	}
}

/** Private Internal Class to wrap the `KeyboardNotificationBlock` closure as notificationClosure and store it within an objc class association */
private class KeyboardNotificationHandlerWrapper {
	var notificationClosure: KeyboardNotificationBlock?
}

