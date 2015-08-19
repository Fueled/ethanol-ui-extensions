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
  
  public static var topMostController: UIViewController? {
    var topController: UIViewController? = nil
    
    guard let window = UIApplication.sharedApplication().keyWindow else {
      return nil
    }
    
    topController = window.rootViewController
    
    repeat {
      if let newTopController = topController {
        if let topNavigationViewController =  newTopController as? UINavigationController {
          if let visibleViewController = topNavigationViewController.visibleViewController {
            topController = visibleViewController
          } else {
            if let presentedController = newTopController.presentedViewController {
              topController = presentedController
            }
          }
        } else if let topTabBarViewController = newTopController as? UITabBarController {
          if let selectedController = topTabBarViewController.selectedViewController {
            topController = selectedController
          } else {
            if let presentedController = newTopController.presentedViewController {
              topController = presentedController
            }
          }
        } else {
          if let presentedController = newTopController.presentedViewController {
            topController = presentedController
          }
        }
      }
    } while (topController?.presentedViewController != nil)
    
    return topController
  }
  
  final public var isTopMostController: Bool {
    return (self === UIViewController.topMostController)
  }
}