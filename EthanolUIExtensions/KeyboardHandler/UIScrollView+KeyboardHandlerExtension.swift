//
//  UIScrollView+ETHKeyboardHandlerScrollviewExtension.swift
//  EthanolUIExtensions
//
//  Created by svs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation
import ObjectiveC

private let keyboardScrollOffsetKey = "keyboardScrollOffsetKey"
private let scrollViewBottomInsetKey = "scrollViewBottomInsetKey"
private let scrollViewIndicatorBottomInsetKey = "scrollViewIndicatorBottomInsetKey"

/** ETHKeyboardHandlerScrollviewExtension Extends UIScrollView

*/

public extension UIScrollView {
  
  public func eth_handleKeyboardNotificationsWithOffset(offset:CGFloat) {
    self.setKeyboardOffset(offset)
    self.eth_handleKeyboardNotifications()
  }
  
  public func eth_handleKeyboardNotifications () {
    self.eth_RegisterForKeyboardNotificationsWithHandler(eth_defaultKeyboardNotificationBlock())
  }
  
  public func eth_stopHandlingKeyboardNotifications() {
    self.eth_DeRegisterForKeyboardNotifications()
  }
  
  public func eth_defaultKeyboardNotificationBlock() -> ETHKeyboardNotificationBlock {
    return { [weak self](isShowing, startKeyboardRect, endKeyboardRect, duration, options) -> Void in
      self?.handleRecievedKeyboardNotification(isShowing, startKeyboardRect: startKeyboardRect, endKeyboardRect: endKeyboardRect, duration: duration, options: options)
    }
  }

}

public extension UIScrollView {
  
  private var keyboardScrollOffset: CGFloat {
    get {
      return objc_getAssociatedObject(self, keyboardScrollOffsetKey) as? CGFloat ?? CGFloat(0.0)
    }
    set (offset) {
      objc_setAssociatedObject(self, keyboardScrollOffsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  internal func setKeyboardOffset(value:CGFloat) {
    self.keyboardScrollOffset = value
  }
  
  private var scrollViewBottomInset: CGFloat? {
    get {
      return objc_getAssociatedObject(self, scrollViewBottomInsetKey) as? CGFloat
    }
    set (offset) {
      objc_setAssociatedObject(self, scrollViewBottomInsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  private var scrollViewIndicatorBottomInset: CGFloat? {
    get {
      return objc_getAssociatedObject(self, scrollViewIndicatorBottomInsetKey) as? CGFloat
    }
    set (offset) {
      objc_setAssociatedObject(self, scrollViewIndicatorBottomInsetKey, offset, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }
  
  private func handleRecievedKeyboardNotification(isShowing:Bool, startKeyboardRect:CGRect, endKeyboardRect:CGRect, duration:NSTimeInterval, options:UIViewAnimationOptions) {
    
    let currentShowState = isShowing ? "show" : "hide"
    ETHLogTrace("\(self) :Calling defaultKeyboardNotificationBlock: \(currentShowState), \(startKeyboardRect), \(endKeyboardRect), \(duration), \(options)")
    
    let keyboardOffset:CGFloat = keyboardScrollOffset
    if isShowing {
      
      let bottomInset = scrollViewBottomInset ?? self.contentInset.bottom
      if scrollViewBottomInset == nil {
        self.scrollViewBottomInset = bottomInset
      }
      
      let indicatorBottomInset = scrollViewIndicatorBottomInset ?? self.scrollIndicatorInsets.bottom
      if scrollViewIndicatorBottomInset == nil {
        scrollViewIndicatorBottomInset = indicatorBottomInset
      }
      
      let screenBounds = UIScreen.mainScreen().bounds
      let positionInWindow = self.window?.convertPoint(self.frame.origin, fromView: self.superview)
      let absoluteHeight = positionInWindow!.y + self.frame.size.height + self.contentOffset.y
      
      if absoluteHeight >= (screenBounds.size.height - endKeyboardRect.size.height) {
        var offset = fmax(0.0, screenBounds.size.height-absoluteHeight)
        ETHLogVerbose("\(self) : KeyboardNotificationBlock Show : Base offset is \(offset), keyboard offset is \(keyboardOffset)")
        offset -= keyboardOffset
        offset = endKeyboardRect.size.height - offset
        
        ETHLogDebug("\(self) : Keyboard notification block (show): calculated offset is \(offset) (Initial bottom offset: \(bottomInset))")
        ETHLogVerbose("\(self) : Keyboard notification block (show): initial indicator offset is \(indicatorBottomInset)")
        
        UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
          var edgeInsets = self.contentInset
          edgeInsets.bottom = offset + (bottomInset ?? 0.0)
          self.contentInset = edgeInsets
          
          edgeInsets = self.scrollIndicatorInsets
          self.scrollIndicatorInsets.bottom = offset + (indicatorBottomInset ?? 0.0)
          self.scrollIndicatorInsets = edgeInsets
          
          }, completion: { (finished) -> Void in })
      }
    } else {
      let bottomInset:CGFloat = self.scrollViewBottomInset ?? 0.0
      let indicatorBottomInset:CGFloat = self.scrollViewIndicatorBottomInset ?? 0.0
      
      ETHLogDebug("\(self) : Keyboard notification block (hide): initial offset is \(bottomInset)")
      ETHLogVerbose("\(self) : Keyboard notification block (hide): initial indicator offset is \(indicatorBottomInset)")
      UIView.animateWithDuration(duration, delay: 0.0, options: options, animations: { () -> Void in
        var edgeInsets = self.contentInset
        edgeInsets.bottom = bottomInset
        self.contentInset = edgeInsets
        
        edgeInsets = self.scrollIndicatorInsets
        self.scrollIndicatorInsets.bottom = indicatorBottomInset
        self.scrollIndicatorInsets = edgeInsets
        
        }, completion: { (finished) -> Void in
          self.scrollViewBottomInset = nil
          self.scrollViewIndicatorBottomInset = nil
      })
      
    }
  }
}
