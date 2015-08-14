//
//  ETHKeyboardHandlerProtocol.swift
//  EthanolUIExtensions
//
//  Created by svs-fueled on 14/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation
import EthanolUtilities

/** ETHKeyboardHandlerProtocol protocol

*/
protocol ETHKeyboardHandlerProtocol {
	
  /**
    Protocol Callback method to respond to keyboard notifications
  */

  func respondToKeyboardNotificationsWithKeyboardShowing(isShowing:Bool, startKeyboardRect:CGRect, endKeyboardRect:CGRect, duration:NSTimeInterval, options:UIViewAnimationOptions)

}

