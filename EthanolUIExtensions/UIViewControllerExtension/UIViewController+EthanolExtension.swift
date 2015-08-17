//
//  ETHUIViewControllerExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation

extension UIViewController {
  
  /**
  *  Returns the Top ViewController of app or nil if none has been added yet.
  *  @return UIViewController An optional 'UIViewController' object representing Top ViewController of app.
  */

 public class func topMostController() -> UIViewController? {
    var topController : UIViewController? = nil
  
  guard let window = UIApplication.sharedApplication().keyWindow else {
    return nil
  }
  
  topController = window.rootViewController
  
  repeat {
    if let newTopController = topController {
      if newTopController.isKindOfClass(UINavigationController) {
        let topNavigationViewController =  newTopController as! UINavigationController
        if topNavigationViewController.visibleViewController != nil {
          topController = topNavigationViewController.visibleViewController!
        } else {
          topController = newTopController.presentedViewController!
        }
      } else if newTopController.isKindOfClass(UITabBarController) {
        let topTabBarViewController = newTopController as! UITabBarController
        if topTabBarViewController.selectedViewController != nil {
          topController = topTabBarViewController.selectedViewController!
        } else {
          topController = newTopController.presentedViewController!
        }
      } else {
        topController = newTopController.presentedViewController!
      }
    }
  } while (topController?.presentedViewController != nil)

  return topController
  }
}

