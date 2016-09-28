//
//  UINavigationController+EthanolExtension.swift
//  EthanolUIExtensions
//
//  Created by hhs-fueled on 18/08/15.
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
import EthanolTools

private var TransitionOptionKey:UInt8 = 0

private class TransitionOptionsContainer {
	var options:UIViewAnimationOptions = UIViewAnimationOptions()
}

private let TransitionDurationOption = { (options:UIViewAnimationOptions) -> TimeInterval in
	var timeInterval = 0.0
	switch(options) {
	case UIViewAnimationOptions.transitionCurlUp, UIViewAnimationOptions.transitionCurlDown:
		timeInterval = 0.35
	case UIViewAnimationOptions.transitionFlipFromTop, UIViewAnimationOptions.transitionFlipFromLeft, UIViewAnimationOptions.transitionFlipFromRight, UIViewAnimationOptions.transitionFlipFromBottom:
		timeInterval = 0.75
	default:
		break
	}
	return timeInterval
}

private let ReverseAnimationForAnimation = { (animation:UIViewAnimationOptions) -> UIViewAnimationOptions in
	switch(animation) {
	case UIViewAnimationOptions.transitionCurlUp:
		return UIViewAnimationOptions.transitionCurlDown;
	case UIViewAnimationOptions.transitionCurlDown:
		return UIViewAnimationOptions.transitionCurlUp;
	case UIViewAnimationOptions.transitionFlipFromBottom:
		return UIViewAnimationOptions.transitionFlipFromTop;
	case UIViewAnimationOptions.transitionFlipFromLeft:
		return UIViewAnimationOptions.transitionFlipFromRight;
	case UIViewAnimationOptions.transitionFlipFromRight:
		return UIViewAnimationOptions.transitionFlipFromLeft;
	case UIViewAnimationOptions.transitionFlipFromTop:
		return UIViewAnimationOptions.transitionFlipFromBottom;
	default:
		return animation;
	}
}

public struct  ETHAnimatedTransitionNewRootOptions: OptionSet {
	
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
	public func eth_backButtonTapped() {
		_ = self.navigationController?.eth_popViewControllerWithMatchingAnimationAnimated(true, completionHandler: nil)
	}
}

public extension UIWindow {
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
	public func eth_transitionToNewRootViewController(_ viewController: UIViewController, completion: ((Bool) -> Void)?) -> UINavigationController? {
		return self.eth_transitionToNewRootViewController(viewController, transitionOption:UIViewAnimationOptions(), completion:completion)
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
	public func eth_transitionToNewRootViewController(_ viewController: UIViewController, transitionOption: UIViewAnimationOptions, completion:((Bool) -> Void)?) -> UINavigationController? {
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
	public func eth_transitionToNewRootViewController(_ viewController: UIViewController, options: ETHAnimatedTransitionNewRootOptions, transitionOption: UIViewAnimationOptions, completionHandler: ((Bool) -> Void)?) -> UIViewController?  {
		var resultViewController: UIViewController? = nil;
		if(options.contains(.NavigationController)) {
			if let navigationController = ETHInjector().instance(for: UINavigationController.self) as? UINavigationController {
				navigationController.viewControllers = [viewController]
				resultViewController = navigationController
			}
		} else {
			resultViewController = viewController
		}
		
		let viewTransitionAnimations = { () -> Void in
			self.rootViewController = resultViewController
		}
		// Don't perform the transition if there is no animation option
		if (transitionOption == UIViewAnimationOptions()) {
			viewTransitionAnimations()
			DispatchQueue.main.async {
				completionHandler?(true)
			}
			return resultViewController
		}
		
		UIView.transition(with: self, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
			UIView.performWithoutAnimation(viewTransitionAnimations)
			}, completion: completionHandler)
		return resultViewController
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
	public func eth_animatedTransitionToViewController(_ viewController: UIViewController, transitionOption: UIViewAnimationOptions, completionHandler: ((Bool) -> Void)?) {
		UIView.transition(with: self.view, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
			UIView.performWithoutAnimation({ () -> Void in
				self.pushViewController(viewController, animated: false)
			})
		}, completion:completionHandler)
		
		let reverseOptionsContainer = TransitionOptionsContainer()
		reverseOptionsContainer.options = ReverseAnimationForAnimation(transitionOption)
		objc_setAssociatedObject(viewController, &TransitionOptionKey, reverseOptionsContainer, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		
		let titleString = self.eth_currentBackButtonTitle ?? ""
		viewController.navigationItem.setCustomBackButtonWithTitle(titleString, target: viewController, selector: #selector(UIViewController.eth_backButtonTapped))
	}
	
	/**
	*  Pop the current view controller with the specifed animation.
	*
	*  @param transitionOption  The animation to use. It must start with UIViewAnimationOptionTransition.
	*  @param completionHandler A block called when the transition animation has completed.
	*
	*  @return The popped view controller.
	*/
	public func eth_popViewControllerWithTransitionOption(_ transitionOption: UIViewAnimationOptions, completionHandler: ((Bool) -> Void)?) -> UIViewController? {
		let viewController = self.viewControllers.last
		
		UIView.transition(with: self.view, duration: TransitionDurationOption(transitionOption), options: transitionOption, animations: { () -> Void in
			UIView.performWithoutAnimation({ () -> Void in
				self.popViewController(animated: false)
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
	public func eth_popViewControllerWithMatchingAnimationAnimated(_ animated: Bool, completionHandler: ((Bool) -> Void)?) -> UIViewController? {
		if(self.viewControllers.count == 0) {
			DispatchQueue.main.async {
				completionHandler?(true)
			}
			return nil
		}
		
		guard let viewController = self.viewControllers.last else { return nil }
		
		if(!animated) {
			self.popViewController(animated: false)
			DispatchQueue.main.async {
				completionHandler?(true)
			}
		} else {
			if let transitionOptionContainer = objc_getAssociatedObject(viewController, &TransitionOptionKey) as? TransitionOptionsContainer {
				let transitionOption = transitionOptionContainer.options
				
				_ = self.eth_popViewControllerWithTransitionOption(animated ? transitionOption : UIViewAnimationOptions(), completionHandler: completionHandler)
			} else {
				self.popViewController(animated: true)
				DispatchQueue.main.async {
					completionHandler?(true)
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
