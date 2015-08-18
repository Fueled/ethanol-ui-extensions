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
    //Handle Back
    //  [viewController.navigationItem eth_setCustomBackButtonActionBlock:^(UIButton *backButton, CustomBackButtonActionCompletedBlock completedBlock) {
    //  [self eth_popViewControllerWithMatchingAnimationAnimated:YES completion:^(BOOL finished) {
    //  completedBlock(YES);
    //  }];
    //  }                                                       // Since the new view controller is already pushed, this returns the correct back button title
    //  title:[self eth_currentBackButtonTitle]];
    //  }
  }
  
  public
  
//  - (UIViewController *)eth_popViewControllerWithTransitionOption:(UIViewAnimationOptions)transitionOption
//  completion:(void (^)(BOOL finished))completionHandler {
//  UIViewController * viewController = self.viewControllers[self.viewControllers.count - 1];
//  [UIView transitionWithView:self.view
//  duration:[self eth_animationDurationForAnimation:transitionOption]
//  options:transitionOption
//  animations:^{
//  [UIView performWithoutAnimation:^{
//  [self popViewControllerAnimated:NO];
//  }];
//  }
//  completion:completionHandler];
//  
//  return viewController;
//  }

}



