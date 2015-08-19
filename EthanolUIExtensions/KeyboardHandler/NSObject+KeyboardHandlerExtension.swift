//
//  NSObject+ETHKeyboardHandlerObjectExtension.swift
//  EthanolUIExtensions
//
//  Created by svs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
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

@objc public enum KeyboardNotificationState: NSInteger {
  case DidShow
  case DidHide
  case WillShow
  case WillHide
}

/** Helper typecast for Notification handler Block */
public typealias KeyboardNotificationBlock = (isShowing: Bool, notificationState: KeyboardNotificationState,startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions) -> Void

/** ETHKeyboardHandlerObjectExtension Extends ETHKeyboardHandler for NSObjects */

public extension NSObject {
  /* Public Method to add Observers for Keyboard Hide/Show Notifications */
  public func eth_registerForKeyboardNotificationsWithHandler(handler:KeyboardNotificationBlock) {
    self.notificationClosure = handler
    registerForKeyboardNotifications()
  }
  
  var ClassName: String {
    return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
  }
  
  /* Remove Observing from keyboard notifications */
  public func eth_deRegisterForKeyboardNotifications() {
    self.isObservingNotifications = false
    self.notificationClosure = nil
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    ETHLogDebug("DERegistered Observers for keyboard Notification for object \(self) of class \(ClassName)")
  }
  
  /* Keyboard State */
  private (set) public var eth_isKeyboardShown: Bool {
    get {
      return objc_getAssociatedObject(self, &isKeyboardShownKey).boolValue
    }
    set (isShown) {
      objc_setAssociatedObject(self, &isKeyboardShownKey, isShown, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  public var eth_keyboardNotificationBlock: KeyboardNotificationBlock? {
    get {
      return self.notificationClosure
    }
    set(block) {
      self.notificationClosure = block
    }
  }
  
  public var eth_keyboardSize: CGSize {
    return self.keyboardSize
  }
}


//MARK: - Private Methods
public extension NSObject {
  
  private func registerForKeyboardNotifications() {
    //Adding Observers with blocks to avoid conflict with namespaces of owning NSObjects

    weak var weakSelf = self
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      if let this = weakSelf where this.isObservingNotifications {
        this.keyboardWillShow(notification)
      }
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      
      if let this = weakSelf where this.isObservingNotifications {
        this.keyboardWillHide(notification)
      }
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      if let this = weakSelf where this.isObservingNotifications {
        this.keyboardDidShow(notification)
      }
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
      if let this = weakSelf where this.isObservingNotifications {
        this.keyboardDidHide(notification)
      }
    }
    
    self.isObservingNotifications = true
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
  
  /* Internal Method to update Closure with data */
  private func respondToKeyboardNotificationsWithKeyboardShowing(isShowing: Bool, notificationState: KeyboardNotificationState, startKeyboardRect: CGRect, endKeyboardRect: CGRect, duration: NSTimeInterval, options: UIViewAnimationOptions) {
    self.eth_isKeyboardShown = isShowing
    if let closure = self.notificationClosure {
      closure(isShowing: isShowing, notificationState: notificationState, startKeyboardRect: startKeyboardRect, endKeyboardRect: endKeyboardRect, duration: duration, options: options)
    } else {
      ETHLogWarning("ETHLogWarn: There is no closure supplied to handle responses for Keyboard Notifications to object \(self)")
    }
  }
  
  /* Internal Method to Calculate data from Keyboard Hide/Show Notifications = (keyboard rects, duration and animation options)*/
  private func generateDataForKeyboardNotification(userInfo: [NSObject:AnyObject]) -> (endRect: CGRect, beginRect: CGRect, duration: Double, option: UIViewAnimationOptions) {
    let endKeyboardRect =  userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue ?? CGRectZero
    let beginKeyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue ?? CGRectZero
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.0
    let curve = UIViewAnimationCurve(rawValue:userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue ?? 0) ?? UIViewAnimationCurve.Linear
    let animationOption = UIAnimationOptionsFromCurve(curve)
    
    return (endRect: endKeyboardRect, beginRect: beginKeyboardRect, duration: duration, option: animationOption)
  }
}


/* State Methods */
private var keyboardNotificationHandlerClosureKey: UInt8 = 0
private var isKeyboardShownKey: UInt8 = 1
private var keyboardSizeKey: UInt8 = 2
private var isObservingNotificationsKey: UInt8 = 3

public extension NSObject {
  
  public var isObservingNotifications: Bool {
    get {
      return objc_getAssociatedObject(self, &isObservingNotificationsKey).boolValue ?? false
    }
    set (value) {
      objc_setAssociatedObject(self, &isObservingNotificationsKey, NSNumber(bool: value), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  private var keyboardSize: CGSize {
    get {
      return objc_getAssociatedObject(self, &keyboardSizeKey).CGSizeValue()
    }
    set (value) {
      objc_setAssociatedObject(self, &keyboardSizeKey, NSValue(CGSize:value), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  /* Keyboard Notification Closure */
  
  private var notificationClosure: KeyboardNotificationBlock? {
    get {
      let object = objc_getAssociatedObject(self, &keyboardNotificationHandlerClosureKey)
      let wrapper = object as? KeyboardNotificationHandlerWrapper
      return wrapper?.notificationClosure
    }
    set (closure) {
      if closure != nil {
        let wrapperClass = KeyboardNotificationHandlerWrapper()
        wrapperClass.notificationClosure = closure
        objc_setAssociatedObject(self, &keyboardNotificationHandlerClosureKey, wrapperClass, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) // This is retain and not copy because we now store the closure encapsulated within a class since we cannot store it directly.
      } else {
        objc_setAssociatedObject(self, &keyboardNotificationHandlerClosureKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      }
    }
  }
}

private class KeyboardNotificationHandlerWrapper {
  var notificationClosure: KeyboardNotificationBlock?
}

