//
//  UINavigationController+EthanolExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 18/08/15.
//  Copyright © 2015 Fueled. All rights reserved.
//

import Foundation
import EthanolTools

private var TransitionOptionKey:UInt8 = 0

private class TransitionOptionsContainer {
	var options:UIViewAnimationOptions = UIViewAnimationOptions.TransitionNone
}

private let TransitionDurationOption = { (options:UIViewAnimationOptions) -> NSTimeInterval in
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

private let ReverseAnimationForAnimation = { (animation:UIViewAnimationOptions) -> UIViewAnimationOptions in
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

public extension UIViewController {
	
	public func eth_backButtonTapped(){
		self.navigationController?.eth_popViewControllerWithMatchingAnimationAnimated(true, completionHandler: nil)
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
		
		let titleString = self.eth_currentBackButtonTitle ?? ""
		viewController.navigationItem.setCustomBackButtonWithTitle(titleString, target: viewController, selector: "eth_backButtonTapped")
	}
	
	/**
	*  Perform a transition to a new view controller instantly, discarding the current navigation stack.
	*  The used navigation controller is the one injected from the ETHFramework injector,
	*  which defaults to UINavigationController.
	*
	*  @param viewController    The view controller to perform the transition to.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The newly created navigation controller.
	*/
	public func eth_transitionToNewRootViewController(viewController: UIViewController, completion: (Bool -> Void)) -> UINavigationController? {
		return self.eth_transitionToNewRootViewController(viewController, transitionOption:UIViewAnimationOptions.TransitionNone, completion:completion)
	}
	
	/**
	*  Perform a transition to a new view controller, discarding the current navigation stack, and allowing to specify the animation type.
	*  The used navigation controller type is the type of the navigation controller used to call the method.
	*
	*  @param viewController    The view controller to perform the transition to.
	*  @param transitionOption  The transition animation to use. It must start with UIViewAnimationOptionTransition.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The newly created navigation controller.
	*/
	public func eth_transitionToNewRootViewController(viewController: UIViewController, transitionOption: UIViewAnimationOptions, completion:(Bool -> Void)) -> UINavigationController? {
		return self.eth_transitionToNewRootViewController(viewController, options: .NavigationController, transitionOption: transitionOption, completionHandler: completion) as? UINavigationController
	}
	
	/**
	*  Perform a transition to a new view controller, discarding the current navigation stack, and allowing to specify the animation type.
	*  The used navigation controller type is the type of the navigation controller used to call the method.
	*
	*  @param viewController    The view controller to perform the transition to.
	*  @param options           The options which defines the behavior when assigning the new root view controller.
	*  @param transitionOption  The transition animation to use. It must start with UIViewAnimationOptionTransition.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The newly created navigation controller.
	*/
	public func eth_transitionToNewRootViewController(viewController: UIViewController, options: ETHAnimatedTransitionNewRootOptions, transitionOption: UIViewAnimationOptions, completionHandler: (Bool -> Void)) -> UIViewController?  {
		
		let window = self.view.window ?? UIApplication.sharedApplication().windows.first!
		var resultViewController: UIViewController? = nil;
		if(options.contains(.NavigationController)) {
			print("Transition to new root controller (%@), creating a new instance of UINavigationController for it \(viewController)")
			if let navigationController = ETHInjector().instanceForClass(UINavigationController) as? UINavigationController {
				navigationController.viewControllers = [viewController]
				resultViewController = navigationController;
			}
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
	
	/**
	*  Pop the current view controller with the specifed animation.
	*
	*  @param transitionOption  The animation to use. It must start with UIViewAnimationOptionTransition.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The popped view controller.
	*/
	public func eth_popViewControllerWithTransitionOption(transitionOption: UIViewAnimationOptions, completionHandler: (Bool -> Void)?) -> UIViewController? {
		
		let viewController = self.viewControllers.last
		
		UIView.transitionWithView(self.view, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
			UIView.performWithoutAnimation({ () -> Void in
				self.popViewControllerAnimated(false)
			})
			}, completion: completionHandler)
		
		return viewController
	}
	
	/**
	*  Pop the current view controller, with an animation matching which was used to push the view controller.
	*  If such an animation is not found, its behavior is equivalent to popViewControllerAnimated:.
	*
	*  @param animated          Specify whether or not the pop should be animated.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The popped view controller.
	*/
	public func eth_popViewControllerWithMatchingAnimationAnimated(animated: Bool, completionHandler: (Bool -> Void)?) -> UIViewController? {
		if(self.viewControllers.count == 0) {
			return nil
		}
		
		guard let viewController = self.viewControllers.last else { return nil }
		
		if(!animated) {
			self.popViewControllerAnimated(false)
			if let completionHandler = completionHandler {
				completionHandler(true)
			}
		} else {
			if let transitionOptionContainer = objc_getAssociatedObject(viewController, &TransitionOptionKey) as? TransitionOptionsContainer {
				let transitionOption = transitionOptionContainer.options
				
				self.eth_popViewControllerWithTransitionOption(animated ? transitionOption : UIViewAnimationOptions.TransitionNone, completionHandler: completionHandler)
			} else {
				self.popViewControllerAnimated(true)
				if let completionHandler = completionHandler {
					completionHandler(true)
				}
			}
		}
		return viewController
	}
	
	/**
	*  Retrieve the currently displayed back button title (if any).
	*  @return The current back button title, or nil if there is no back button.
	*/
	public final var eth_currentBackButtonTitle: String? {
		if(self.viewControllers.count < 2) {
			return nil;
		}
		let current = self.viewControllers[self.viewControllers.count - 1]
		let previous = self.viewControllers[self.viewControllers.count - 2]
		
		return current.navigationItem.customBackButtonTitle ?? previous.navigationItem.customBackButtonTitle ?? previous.navigationController?.navigationBar.backItem?.title
	}
}
