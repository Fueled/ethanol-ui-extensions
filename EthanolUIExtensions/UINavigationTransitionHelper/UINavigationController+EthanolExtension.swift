//
//  UINavigationController+EthanolExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 18/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation

private var TransitionOptionKey:UInt8 = 0

private class TransitionOptionsContainer {
  var options:UIViewAnimationOptions = UIViewAnimationOptions.TransitionNone
}

let TransitionDurationOption = { (options:UIViewAnimationOptions) -> NSTimeInterval in
  var timeInterval = 0.0
  switch(options) {
  case UIViewAnimationOptions.TransitionCurlUp, UIViewAnimationOptions.TransitionCurlDown:
    timeInterval = 0.35
  case UIViewAnimationOptions.TransitionFlipFromTop,UIViewAnimationOptions.TransitionFlipFromLeft,UIViewAnimationOptions.TransitionFlipFromRight,UIViewAnimationOptions.TransitionFlipFromBottom:
    timeInterval = 0.75
  default:
    break
  }
  return timeInterval
}

let ReverseAnimationForAnimation = { (animation:UIViewAnimationOptions) -> UIViewAnimationOptions in
  switch(animation) {
  case UIViewAnimationOptions.TransitionCurlUp:
    return UIViewAnimationOptions.TransitionCurlDown;
  case UIViewAnimationOptions.TransitionCurlDown:
    return UIViewAnimationOptions.TransitionCurlUp;
  case UIViewAnimationOptions.TransitionFlipFromBottom:
    return UIViewAnimationOptions.TransitionFlipFromTop;
  case UIViewAnimationOptions.TransitionFlipFromLeft:
    return UIViewAnimationOptions.TransitionFlipFromRight;
  case UIViewAnimationOptions.TransitionFlipFromRight:
    return UIViewAnimationOptions.TransitionFlipFromLeft;
  case UIViewAnimationOptions.TransitionFlipFromTop:
    return UIViewAnimationOptions.TransitionFlipFromBottom;
  default:
    return animation;
  }
}

public struct  ETHAnimatedTransitionNewRootOptions : OptionSetType {
  
  public let rawValue: UInt

  public init(rawValue newRawValue:UInt) {
    rawValue = newRawValue
  }
  /**
  *  No option (Default). The view controller is assigned as-is.
  */
  static let None = ETHAnimatedTransitionNewRootOptions(rawValue: 0)
  /**
  *  The view controller is first wrapped into a UINavigationController, and then this navigation controller
  *  is used as the new root view controller.
  */
  static let NavigationController = ETHAnimatedTransitionNewRootOptions(rawValue: 1)
}

public extension UINavigationController {
  
  /**
  *  Perform a transition to a new view controller, allowing to specify the animation type.
  *
  *  @param viewController    The view controller to perform the transition to.
  *  @param transitionOption  The transition animation to use. It must start with UIViewAnimationOptionTransition.
  *  @param completionHandler A block called when the transition animation has completed.
  */
  
  public func eth_animatedTransitionToViewController(viewController: UIViewController, transitionOption: UIViewAnimationOptions, completionHandler: (Bool -> Void)) {
    
    UIView.transitionWithView(self.view, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
      UIView.performWithoutAnimation({ () -> Void in
        self.pushViewController(viewController, animated: false)
      })
    }, completion:completionHandler)
   
    let reverseOptionsContainer = TransitionOptionsContainer()
    reverseOptionsContainer.options = ReverseAnimationForAnimation(transitionOption)
    objc_setAssociatedObject(viewController, &TransitionOptionKey, reverseOptionsContainer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    
    var title = ""
    if let eth_currentBackButtonTitle = self.eth_currentBackButtonTitle() {
      title = eth_currentBackButtonTitle
    }
    viewController.navigationItem.setCustomBackButtonWithTitle(title, target: self, selector: "backButtonTapped")
    
    
//    [viewController.navigationItem eth_setCustomBackButtonActionBlock:^(UIButton *backButton, CustomBackButtonActionCompletedBlock completedBlock) {
//      [self eth_popViewControllerWithMatchingAnimationAnimated:YES completion:^(BOOL finished) {
//      completedBlock(YES);
//      }];
//      }                                                       // Since the new view controller is already pushed, this returns the correct back button title
//      title:[self eth_currentBackButtonTitle]];
  }
  
  private func backButtonTapped(){
    self.eth_popViewControllerWithMatchingAnimationAnimated(true) { (Bool finished) -> Void in
      
    }
  }
  
  
  public func eth_transitionToNewRootViewController(viewController: UIViewController, completion: (Bool -> Void)) -> UINavigationController? {
    return self.eth_transitionToNewRootViewController(viewController, transitionOption:UIViewAnimationOptions.TransitionNone, completion:completion)
  }
  
  public func eth_transitionToNewRootViewController(viewController: UIViewController, transitionOption: UIViewAnimationOptions, completion:(Bool -> Void)) -> UINavigationController? {
      return self.eth_transitionToNewRootViewController(viewController, options: ETHAnimatedTransitionNewRootOptions.NavigationController, transitionOption: transitionOption, completionHandler: completion) as? UINavigationController
  }
  
  public func eth_transitionToNewRootViewController(viewController: UIViewController, options: ETHAnimatedTransitionNewRootOptions, transitionOption: UIViewAnimationOptions, completionHandler: (Bool -> Void)) -> UIViewController?  {
    
    let window = self.view.window ?? UIApplication.sharedApplication().windows.first!
    var resultViewController: UIViewController? = nil;
    if(options.contains(ETHAnimatedTransitionNewRootOptions.NavigationController)) {
      print("Transition to new root controller (%@), creating a new instance of UINavigationController for it \(viewController)")
      let navigationController = UINavigationController()
      navigationController.viewControllers = [viewController]
      resultViewController = navigationController;
    } else {
      print("Transition to new root controller \(viewController)")
      resultViewController = viewController;
    }
    
    let viewTransitionAnimations = { () -> Void in
      window.rootViewController = resultViewController;
    }
    // Don't perform the transition if there is no animation option
    if (transitionOption.contains(UIViewAnimationOptions.TransitionNone)) {
      viewTransitionAnimations()
      completionHandler(true)
      return resultViewController
    }
    
    UIView.transitionWithView(window, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
      UIView.performWithoutAnimation(viewTransitionAnimations)
      }, completion: completionHandler)
    return resultViewController
  }
  
  
  public func eth_popViewControllerWithTransitionOption(transitionOption: UIViewAnimationOptions, completionHandler: (Bool -> Void)) -> UIViewController? {
    
    let viewController = self.viewControllers.last
    
    UIView.transitionWithView(self.view, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
      UIView.performWithoutAnimation({ () -> Void in
        self.popViewControllerAnimated(false)
      })
      }, completion: completionHandler)
    
    return viewController
  }
  
  
  public func eth_popViewControllerWithMatchingAnimationAnimated(animated: Bool, completionHandler: (Bool -> Void)) -> UIViewController? {
    if(self.viewControllers.count == 0) {
      return nil
    }

    let viewController = self.viewControllers.last!
    if(!animated) {
      self.popViewControllerAnimated(false)
      completionHandler(true)
    } else {
      if let transitionOptionContainer = objc_getAssociatedObject(viewController, &TransitionOptionKey) as? TransitionOptionsContainer {
        let transitionOption = transitionOptionContainer.options
        self.eth_popViewControllerWithTransitionOption(animated ? transitionOption : UIViewAnimationOptions.TransitionNone, completionHandler: completionHandler)
      } else {
        self.popViewControllerAnimated(true)
        completionHandler(true);
      }
    }
    return viewController
  }
  
  
  public func eth_currentBackButtonTitle() -> String? {
    if(self.viewControllers.count < 2) {
      return nil;
    }
    let current = self.viewControllers[self.viewControllers.count - 1]
    let previous = self.viewControllers[self.viewControllers.count - 2]
    
    return previous.navigationItem.title ?? current.navigationItem.title ?? previous.navigationController?.navigationBar.backItem?.title
  }
}



