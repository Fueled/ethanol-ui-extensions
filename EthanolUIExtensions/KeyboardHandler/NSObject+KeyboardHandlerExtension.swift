//
//  NSObject+ETHKeyboardHandlerObjectExtension.swift
//  EthanolUIExtensions
//
//  Created by svs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation

/** Helper block to convert UIViewAnimationCurve to UIViewAnimationOptions */

public let ETHAnimationOptionsFromCurve = {(curve : UIViewAnimationCurve) -> UIViewAnimationOptions in
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

/** Helper typecast for Notification handler Block */
public typealias ETHKeyboardNotificationBlock = (isShowing:Bool, startKeyboardRect:CGRect, endKeyboardRect:CGRect, duration:NSTimeInterval, options:UIViewAnimationOptions)-> Void

/** ETHKeyboardHandlerObjectExtension Extends ETHKeyboardHandler for NSObjects */

public extension NSObject {
  /* Public Method to add Observers for Keyboard Hide/Show Notifications */
  public func eth_RegisterForKeyboardNotificationsWithHandler(handler:ETHKeyboardNotificationBlock) {
    self.notificationClosure = handler
    registerForKeyboardNotifications()
  }
  
  var theClassName:String {
    return NSStringFromClass(self.dynamicType).componentsSeparatedByString(".").last!
  }
  
  /* Remove Observing from keyboard notifications */
  public func eth_DeRegisterForKeyboardNotifications() {
    self.notificationClosure = nil
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardDidHideNotification, object: nil)
    NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    
    print("ETHLogDebug: DERegistered Observers for keyboard Notification for object \(self) of class \(theClassName)")
  }
  
  public var eth_isKeyboardShown:Bool {
    return objc_getAssociatedObject(self, isKeyboardShownKey).boolValue
  }
  
  public var eth_keyboardNotificationBlock:ETHKeyboardNotificationBlock? {
    return self.notificationClosure
  }
  
  public func eth_setKeyboardNotificationBlock(notificationBlock:ETHKeyboardNotificationBlock?) {
    self.notificationClosure = notificationBlock
  }
  
  public var eth_keyboardSize:CGSize {
    return self.keyboardSize
  }
}


//MARK: - Private Methods
public extension NSObject {
  private func registerForKeyboardNotifications() {
    //Adding Observers with blocks to avoid conflict with namespaces of owning NSObjects
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
      self?.keyboardWillShow(notification)
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardWillHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
      self?.keyboardWillHide(notification)
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidShowNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
      self?.keyboardDidShow(notification)
    }
    
    NSNotificationCenter.defaultCenter().addObserverForName(UIKeyboardDidHideNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self] (notification) -> Void in
      self?.keyboardDidHide(notification)
    }
  }
  
  private func keyboardWillShow (notification : NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardData = self.generateDataForKeyboardNotification(userInfo)
    self.respondToKeyboardNotificationsWithKeyboardShowing(true, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
  }
  
  private func keyboardDidShow (notification : NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardData = self.generateDataForKeyboardNotification(userInfo)
    self.respondToKeyboardNotificationsWithKeyboardShowing(true, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
  }
  
  private func keyboardDidHide (notification : NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardData = self.generateDataForKeyboardNotification(userInfo)
    self.respondToKeyboardNotificationsWithKeyboardShowing(false, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
  }
  
  private func keyboardWillHide (notification : NSNotification) {
    guard let userInfo = notification.userInfo else { return }
    let keyboardData = self.generateDataForKeyboardNotification(userInfo)
    self.respondToKeyboardNotificationsWithKeyboardShowing(false, startKeyboardRect: keyboardData.beginRect, endKeyboardRect: keyboardData.endRect, duration: keyboardData.duration, options: keyboardData.option)
  }
  
  /* Internal Method to update Closure with data */
  private func respondToKeyboardNotificationsWithKeyboardShowing(isShowing:Bool, startKeyboardRect:CGRect, endKeyboardRect:CGRect, duration:NSTimeInterval, options:UIViewAnimationOptions) {
    self.setIsKeyboardShown(isShowing)
    if let closure = self.notificationClosure {
      closure(isShowing:isShowing, startKeyboardRect:startKeyboardRect, endKeyboardRect:endKeyboardRect, duration:duration, options:options)
    } else {
      print("ETHLogWarn: There is no closure supplied to handle responses for Keyboard Notifications to object \(self)")
    }
  }
  
  /* Internal Method to Calculate data from Keyboard Hide/Show Notifications = (keyboard rects, duration and animation options)*/
  private func generateDataForKeyboardNotification(userInfo:[NSObject:AnyObject]) -> (endRect:CGRect, beginRect:CGRect, duration:Double, option:UIViewAnimationOptions) {
    let endKeyboardRect =  userInfo[UIKeyboardFrameEndUserInfoKey]?.CGRectValue ?? CGRectZero
    let beginKeyboardRect = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue ?? CGRectZero
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]?.doubleValue ?? 0.0
    let curve = UIViewAnimationCurve(rawValue:userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue ?? 0) ?? UIViewAnimationCurve.Linear
    let animationOption = ETHAnimationOptionsFromCurve(curve)
    
    return (endRect:endKeyboardRect, beginRect:beginKeyboardRect, duration:duration, option:animationOption)
  }
}


/* State Methods */
private let keyboardNotificationHandlerClosureKey = "keyboardNotificationHandlerClosureKey"
private let isKeyboardShownKey = "isKeyboardShownKey"
private let keyboardSizeKey = "keyboardSizeKey"

public extension NSObject {
  /* Keyboard State */
  private func setIsKeyboardShown(isShown:Bool) {
    objc_setAssociatedObject(self, keyboardNotificationHandlerClosureKey, isShown, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
  }
  
  private var keyboardSize:CGSize {
    get {
      return objc_getAssociatedObject(self, keyboardSizeKey).CGSizeValue()
    }
    set (value) {
      objc_setAssociatedObject(self, keyboardSizeKey, NSValue(CGSize:value), objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  /* Keyboard Notification Closure */
  
  private class KeyboardNotificationHandlerClosure {
    var notificationClosure:ETHKeyboardNotificationBlock?
  }
  
  private var notificationClosure:ETHKeyboardNotificationBlock? {
    get {
      let closure = objc_getAssociatedObject(self, keyboardNotificationHandlerClosureKey) as? KeyboardNotificationHandlerClosure
      return closure?.notificationClosure
    }
    set (closure) {
      if closure != nil {
        let newClosureClass = KeyboardNotificationHandlerClosure()
        newClosureClass.notificationClosure = closure
        objc_setAssociatedObject(self, keyboardNotificationHandlerClosureKey, newClosureClass, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN) // This is retain and not copy because we now store the closure encapsulated within a class since we cannot store it directly.
      } else {
        objc_setAssociatedObject(self, keyboardNotificationHandlerClosureKey, nil, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
      }
    }
  }
}
