
//
//  ETHScrollViewStateController.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

/*
-ETHScrollViewStateController manages the state of your scrollView irrespective of whether its used as a pull-to-refresh or paginator (load more) or something else.

-One can design their own pull-to-refresh or paginator by implementing ETHScrollViewStateController's datasource methods
*/

/**
Scroll view states

- Normal:        when user is simply scrolling to see data
- Ready:         when user has pulled the scrollView enough i.e. beyond a threshold and loading could begin if released at this stage
- WillBeLoading: when user has released the scrollView (beyond a threshold) and it is about to get stablise at a threshold
- Loading:       when user has started loading
*/
enum ETHScrollViewStateControllerState: Int {
  case Normal
  case Ready
  case WillBeLoading
  case Loading
}

/**
*  Scroll view state configuration's initial values
*/
public struct ETHStateConfiguration {
	var thresholdInitiateLoading: CGFloat = 0
	var thresholdStartLoading: CGFloat = 0
	var loaderFrame = CGRectZero
	var showDefaultLoader = true
}

// Default height of pull to refresh or paginator
let defaultLoaderHeight: CGFloat = 64.0

public typealias CompletionHandler = () -> Void

public protocol ETHScrollViewStateControllerDataSource {
	/**
	It defines the condition whether to use y or x point for content offset

	- returns: Boolean value
	*/
  func scrollViewStateControllerWillObserveVerticalScrolling() -> Bool

	/**
	It defines the condition when to enter the loading zone

	- parameter offset: Calculated offset value of scrollView's offset from edges

	- returns: Boolean value
	*/
  func scrollViewStateControllerShouldInitiateLoading(offset: CGFloat) -> Bool

	/**
	It defines the condition when the loader stablises (after releasing) and loading can start

	- parameter offset: Calculated offset value of scrollView's offset from edges

	- returns: Boolean value
	*/
  func scrollViewStateControllerShouldReleaseToStartLoading(offset: CGFloat) -> Bool
  
	/**
	It defines the condition when to cancel loading

	- parameter offset:  Calculated offset value of scrollView's offset from edges

	- returns: Boolean value
	*/
  func scrollViewStateControllerShouldReleaseToCancelLoading(offset: CGFloat) -> Bool
  
	/**
	It will return the loader frame

	- returns: Loader frame
	*/
  func scrollViewStateControllerLoaderFrame() -> CGRect
  
	/**
	It will return the loader inset

	- parameter startAnimation: Float value for animation duration

	- returns: Loader insets
	*/
  func scrollViewStateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets
}

extension ETHScrollViewStateControllerDataSource {
  public func scrollViewStateControllerWillObserveVerticalScrolling() -> Bool {
    // default implementation
    return true
  }
  
}

public protocol ETHScrollViewStateControllerDelegate {
  func scrollViewStateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIActivityIndicatorView)
  func scrollViewStateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool
  func scrollViewStateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler)
  func scrollViewStateControllerDidFinishLoading(controller: ETHScrollViewStateController)
}

extension ETHScrollViewStateControllerDelegate {
  public func scrollViewStateControllerShouldStartLoading(controller: ETHScrollViewStateController) -> Bool {
    // default implementation
    return true
  }

  public func scrollViewStateControllerWillStartLoading(controller: ETHScrollViewStateController, loadingView: UIActivityIndicatorView) {
    // default imlpementation
  }
  
  public func scrollViewStateControllerDidFinishLoading(controller: ETHScrollViewStateController) {
    // default imlpementation
  }
}

public class ETHScrollViewStateController: NSObject {
  
  let insetInsertAnimationDuration: NSTimeInterval = 0.7
  let insetRemoveAnimationDuration: NSTimeInterval = 0.3
  
  var dataSource: ETHScrollViewStateControllerDataSource?
  var delegate: ETHScrollViewStateControllerDelegate?
  
  private var scrollView = UIScrollView()
  private var state: ETHScrollViewStateControllerState = .Normal
  private var loadingView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
  
  public init(scrollView: UIScrollView, dataSource: ETHScrollViewStateControllerDataSource,
	delegate: ETHScrollViewStateControllerDelegate, showDefaultLoader: Bool = true) {
    super.init()
    
    self.scrollView = scrollView
    self.dataSource = dataSource
    self.delegate = delegate
    self.state = .Normal

    self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
    if showDefaultLoader {
      addDefaultLoadView()
    }
  }

	private func addDefaultLoadView() {
		if let frame = self.dataSource?.scrollViewStateControllerLoaderFrame() {
			self.loadingView.frame = frame
			self.scrollView.addSubview(self.loadingView)
		}
	}

  override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentOffset" {
      var newOffset: CGFloat = 0
      if dataSource?.scrollViewStateControllerWillObserveVerticalScrolling() == true {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.y)!

      } else {
        newOffset = (change?[NSKeyValueChangeNewKey]?.CGPointValue?.x)!
      }
      
      handleLoadingCycle(newOffset)
    }
  }

  private func handleLoadingCycle(offset: CGFloat) {
	if (self.dataSource?.scrollViewStateControllerShouldInitiateLoading(offset) == true) {
		self.delegate?.scrollViewStateControllerWillStartLoading(self, loadingView: self.loadingView)
	}

    if self.scrollView.dragging {
      switch self.state {
      case .Normal:
		if (self.dataSource?.scrollViewStateControllerShouldReleaseToStartLoading(offset) == true) {
			self.state = .Ready
		}
      case .Ready:
		if (self.dataSource?.scrollViewStateControllerShouldReleaseToCancelLoading(offset) == true) {
			self.state = .Normal
		}
	  default: break
      }
      
    } else if scrollView.decelerating {
      if self.state == .Ready {
        handleReadyState()
      }
    }
  }

  private func handleReadyState() {
    self.state = .WillBeLoading
	if self.delegate?.scrollViewStateControllerShouldStartLoading(self) == true {
		if let frame = self.dataSource?.scrollViewStateControllerLoaderFrame() {
			self.loadingView.frame = frame
		}
      startUIAnimation({ [weak self] () -> Void in
        if let weakSelf = self {
          weakSelf.startLoading()
        }
      })
      
    } else {
      self.state = .Normal
    }
  }

  private func startLoading() {
    self.state = .Loading
    self.delegate?.scrollViewStateControllerDidStartLoading(self, onCompletion: {[weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.stopLoading()
      }
    })
  }

  private func stopLoading() {
    self.state = .Normal
    
    self.stopUIAnimation({ [weak self] () -> Void in
      if let weakSelf = self {
        weakSelf.delegate?.scrollViewStateControllerDidFinishLoading(weakSelf)
      }
    })
  }
  
  private func startUIAnimation(onCompletion: CompletionHandler) {
    handleAnimation(startAnimation: true) { () -> Void in
      onCompletion()
    }
  }
  
  private func stopUIAnimation(onCompletion: CompletionHandler) {
    handleAnimation(startAnimation: false) { () -> Void in
      onCompletion()
    }
  }
  
  private func handleAnimation(startAnimation startAnimation: Bool, onCompletion: CompletionHandler) {
    if startAnimation {
      self.loadingView.startAnimating()
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        let oldContentOffset = self.scrollView.contentOffset
		if let contentInsets = self.dataSource?.scrollViewStateControllerInsertLoaderInsets(startAnimation) {
			self.scrollView.contentInset = contentInsets
		}
        self.scrollView.contentOffset = oldContentOffset /* this has been done to make the animation smoother as just animating the content inset has little glitch */
        onCompletion()
      }
    } else {
      self.loadingView.stopAnimating()
      dispatch_async(dispatch_get_main_queue()) { () -> Void in
        UIView.animateWithDuration(self.insetRemoveAnimationDuration, animations: {[weak self] () -> Void in
          if let weakSelf = self, let contentInsets = weakSelf.dataSource?.scrollViewStateControllerInsertLoaderInsets(startAnimation) {
            weakSelf.scrollView.contentInset = contentInsets
          }
        }, completion: { (finished: Bool) -> Void in
            onCompletion()
        })
      }
    }
  }

	/**
	removing KVO observer
	*/
  deinit {
    self.scrollView.removeObserver(self, forKeyPath: "contentOffset")
  }
}