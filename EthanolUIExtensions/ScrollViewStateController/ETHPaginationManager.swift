//
//  ETHPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 20/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

public protocol ETHPaginationManagerDelegate {
  func paginationManagerDidStartLoading(controller: ETHPaginationManager, onCompletion: CompletionHandler)
}

public class ETHPaginationManager: NSObject {
  var delegate: ETHPaginationManagerDelegate?
  var scrollView = UIScrollView()
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  static let DefaultStateConfig = ETHStateConfiguration(thresholdInitiateLoading: 0, thresholdStartLoading: defaultLoaderHeight,
	loaderFrame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, defaultLoaderHeight),
	showDefaultLoader: true)

  public init(scrollView: UIScrollView, delegate: ETHPaginationManagerDelegate, stateConfig: ETHStateConfiguration? = nil) {
    super.init()
    
    self.scrollView = scrollView
    self.delegate = delegate
    self.stateConfig = stateConfig ?? ETHPaginationManager.DefaultStateConfig
    self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self,
														   showDefaultLoader: self.stateConfig.showDefaultLoader)
  }

	/**
	Calculating scrollView offset, that is how far scrollView has moved in vertical direction from bottom
	- parameter offset: scrollView's current offset
	- returns: Offset of scrollView bottom from super view's bottom
	*/
  private func offsetValueFromBottom(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, self.scrollView.contentSize.height - self.scrollView.frame.size.height)
    let bottomOffset = offset - calculatedOffset
    return bottomOffset
  }
}

// MARK: - ETHScrollViewStateControllerDataSource
extension ETHPaginationManager: ETHScrollViewStateControllerDataSource {
  public func scrollViewStateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.offsetValueFromBottom(offset) > self.stateConfig.thresholdInitiateLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerShouldReleaseToStartLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.offsetValueFromBottom(offset) > self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerShouldReleaseToCancelLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.offsetValueFromBottom(offset) < self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = self.scrollView.contentInset
    newInset.bottom += startAnimation ? self.stateConfig.loaderFrame.size.height : -self.stateConfig.loaderFrame.size.height
    return newInset
  }
  
  public func scrollViewStateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.y = self.scrollView.contentSize.height
    self.stateConfig.loaderFrame = frame
    return frame
  }
 
}

// MARK: - ETHScrollViewStateControllerDelegate
extension ETHPaginationManager: ETHScrollViewStateControllerDelegate {
  
  public func scrollViewStateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.paginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
