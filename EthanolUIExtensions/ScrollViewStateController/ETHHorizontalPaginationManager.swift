//
//  ETHHorizontalPaginationManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 21/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

public protocol ETHHorizontalPaginationManagerDelegate {
  func horizontalPaginationManagerDidStartLoading(controller: ETHHorizontalPaginationManager, onCompletion: CompletionHandler)
}

public class ETHHorizontalPaginationManager: NSObject {
  var delegate: ETHHorizontalPaginationManagerDelegate?
  var scrollView = UIScrollView()
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!
  static let DefaultStateConfig = ETHStateConfiguration(thresholdInitiateLoading: 0, thresholdStartLoading: 0,
		loaderFrame: CGRectMake(0, 0, defaultLoaderHeight, UIScreen.mainScreen().bounds.size.height),
		showDefaultLoader: true)

	/**
	Initialization method

	- parameter scrollView:  scrollView
	- parameter delegate:    pagination manager delegate
	- parameter stateConfig: set to default state configuration if state configuration is not specified

	- returns: horizontal pagination manager
	*/
	public init(scrollView: UIScrollView, delegate: ETHHorizontalPaginationManagerDelegate, stateConfig: ETHStateConfiguration? = nil) {
		super.init()

		self.scrollView = scrollView
		self.delegate = delegate
		self.stateConfig = stateConfig ?? ETHHorizontalPaginationManager.DefaultStateConfig
		self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self,
			delegate: self, showDefaultLoader: self.stateConfig.showDefaultLoader)
	}

  private func horizontalOffsetValue(offset: CGFloat) -> CGFloat {
    let calculatedOffset = max(0, self.scrollView.contentSize.width - self.scrollView.frame.size.width)
    let horizontalOffset = offset - calculatedOffset
    return horizontalOffset
  }
}

// MARK: - ETHScrollViewStateControllerDataSource
extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDataSource {
  public func scrollViewStateControllerWillObserveVerticalScrolling() -> Bool {
    return false
  }
  
  public func scrollViewStateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.horizontalOffsetValue(offset) > self.stateConfig.thresholdInitiateLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerShouldReleaseToStartLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.horizontalOffsetValue(offset) > self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerShouldReleaseToCancelLoading(offset: CGFloat) -> Bool {
    let shouldStart = self.horizontalOffsetValue(offset) < self.stateConfig.thresholdStartLoading
    return shouldStart
  }
  
  public func scrollViewStateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = self.scrollView.contentInset
    newInset.right += startAnimation ? self.stateConfig.loaderFrame.size.width : -self.stateConfig.loaderFrame.size.width
    return newInset
  }
  
  public func scrollViewStateControllerLoaderFrame() -> CGRect {
    var frame = self.stateConfig.loaderFrame
    frame.origin.x = self.scrollView.contentSize.width
    self.stateConfig.loaderFrame = frame
    return frame
  }
}

// MARK: - ETHScrollViewStateControllerDelegate
extension ETHHorizontalPaginationManager: ETHScrollViewStateControllerDelegate {
  public func scrollViewStateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.horizontalPaginationManagerDidStartLoading(self, onCompletion: onCompletion)
  }
}
