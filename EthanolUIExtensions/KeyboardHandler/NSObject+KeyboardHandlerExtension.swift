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
	case .easeInOut:
		return UIViewAnimationOptions()
	case .easeIn:
		return .curveEaseIn
	case .easeOut:
		return .curveEaseOut
	case .linear:
		return .curveLinear
	}
}

/** Enum describing keyboard notification which triggered the callback */

@objc public enum KeyboardNotificationState: NSInteger {
	case didShow
	case didHide
	case willShow
	case willHide
}

/** Helper typecast for Notification handler Block */

public typealias KeyboardNotificationBlock = (_ isShowing: Bool, _ notificationState: KeyboardNotificationState,_ startKeyboardRect: CGRect, _ endKeyboardRect: CGRect, _ duration: TimeInterval, _ options: UIViewAnimationOptions) -> Void

/**
ETHKeyboardHandlerObjectExtension Extends NSObjects to begin handling keyboard
notifications.
*/

public extension NSObject {
	
	/**
	Public Method to add Observers for Keyboard Hide/Show Notifications and responds via a `KeyboardNotificationBlock` Handler.
	In Case the reciever is already observing notifications, this method simply replaces the handler with the new handler.
	*/
	
	final public func eth_registerForKeyboardNotificationsWithHandler(_ handler:@escaping KeyboardNotificationBlock) {
		self.notificationClosure = handler
		if !eth_observingNotifications { // Replaces handler if already observing
			registerForKeyboardNotifications()
		}
	}
	
	/** Public Method to Return ClassName if any, Can be overwritten by a subclass */
	
	public var ClassName: String {
		return NSStringFromClass(type(of: self)).components(separatedBy: ".").last ?? ">NSObject<"
	}
	
	/** Public method to Remove Observing from keyboard notifications */
	
	final public func eth_deRegisterForKeyboardNotifications() {
		self.eth_observingNotifications = false
		self.notificationClosure = nil
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardDidHide, object: nil)
		NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
		ETHLogDebug("DERegistered Observers for keyboard Notification for object \(self) of class \(ClassName)")
	}
	
	/** Read Only variable to describe Keyboard State */
	
	final fileprivate (set) public var eth_keyboardShown: Bool {
		get {
			return (objc_getAssociatedObject(self, &isKeyboardShownKey) as AnyObject).boolValue ?? false
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
	final fileprivate (set) public var eth_observingNotifications: Bool {
		get {
			if let associatedObject = objc_getAssociatedObject(self, &isObservingNotificationsKey) {
				return (associatedObject as AnyObject).boolValue ?? false
			} else {
				return false
			}
		}
		set (value) {
			objc_setAssociatedObject(self, &isObservingNotificationsKey, NSNumber(value: value as Bool), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

}


//MARK: - Private Methods
/** Private Methods */

public extension NSObject {

	fileprivate func registerForKeyboardNotifications() {
		//Adding Observers with blocks to avoid conflict with namespaces of owning NSObjects
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: OperationQueue.main) { [weak self](notification) -> Void in
			if let this = self , this.eth_observingNotifications {
				this.keyboardWillShow(notification)
			}
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: OperationQueue.main) { [weak self](notification) -> Void in
			if let this = self , this.eth_observingNotifications {
				this.keyboardWillHide(notification)
			}
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidShow, object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
			if let this = self , this.eth_observingNotifications {
				this.keyboardDidShow(notification)
			}
		}
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardDidHide, object: nil, queue: OperationQueue.main) { [weak self] (notification) -> Void in
			if let this = self , this.eth_observingNotifications {
				this.keyboardDidHide(notification)
			}
		}
		
		self.eth_observingNotifications = true
	}
	
	fileprivate func keyboardWillShow(_ notification: Notification) {
		guard let userInfo = (notification as NSNotification).userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(true, notificationState: .willShow, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	fileprivate func keyboardDidShow(_ notification: Notification) {
		guard let userInfo = (notification as NSNotification).userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(true, notificationState: .didShow, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	fileprivate func keyboardDidHide(_ notification: Notification) {
		guard let userInfo = (notification as NSNotification).userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(false, notificationState: .didHide, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	fileprivate func keyboardWillHide(_ notification: Notification) {
		guard let userInfo = (notification as NSNotification).userInfo else { return }
		let keyboardData = self.generateDataForKeyboardNotification(userInfo)
		self.respondToKeyboardNotificationsWithKeyboardShowing(false, notificationState: .willHide, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
	}
	
	/** Internal Method to update Closure with data */
	fileprivate func respondToKeyboardNotificationsWithKeyboardShowing(_ isShowing: Bool, notificationState: KeyboardNotificationState, startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: TimeInterval, options: UIViewAnimationOptions) {
		self.eth_keyboardShown = isShowing
		if let closure = self.notificationClosure {
			closure(isShowing, notificationState, startKeyboardRect, endKeyboardRect, duration, options)
		} else {
			ETHLogWarning("ETHLogWarn: There is no closure supplied to handle responses for Keyboard Notifications to object \(self)")
		}
	}
	
	/** Internal Method to Calculate data from Keyboard Hide/Show Notifications = (keyboard rects, duration and animation options)*/
	fileprivate func generateDataForKeyboardNotification(_ userInfo: [AnyHashable: Any]) -> (endRect: CGRect, beginRect: CGRect, duration: Double, option: UIViewAnimationOptions) {
		let endKeyboardRect =  (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
		let beginKeyboardRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
		let duration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double) ?? 0.0
		let curve = UIViewAnimationCurve(rawValue: userInfo[UIKeyboardAnimationCurveUserInfoKey] as? Int ?? 0) ?? UIViewAnimationCurve.linear
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
	
	fileprivate var keyboardSize: CGSize {
		get {
			if let size = objc_getAssociatedObject(self, &keyboardSizeKey) {
				return (size as AnyObject).cgSizeValue
			}
			return CGSize.zero
		}
		set (value) {
			objc_setAssociatedObject(self, &keyboardSizeKey, NSValue(cgSize:value), objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	/** Keyboard Notification Closure */
	fileprivate var notificationClosure: KeyboardNotificationBlock? {
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

