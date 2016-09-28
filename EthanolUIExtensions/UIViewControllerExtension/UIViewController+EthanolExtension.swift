//
//  ETHUIViewControllerExtension.swift
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

extension UIViewController {
	
	/**
	*  Returns the Top ViewController of app or nil if none has been added yet.
	*  @return UIViewController An optional 'UIViewController' object representing Top ViewController of app.
	*/
	
	public static var topMostController: UIViewController? {
		var topController: UIViewController? = nil
		
		guard let window = UIApplication.shared.keyWindow else {
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
