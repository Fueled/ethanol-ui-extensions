//
//  ETHRefreshManager.swift
//  ETHScrollViewStateController
//
//  Created by Ritesh-Gupta on 19/01/16.
//  Copyright © 2016 Ritesh. All rights reserved.
//

import Foundation
import UIKit

public protocol ETHRefreshManagerDelegate {
  func refreshManagerDidStartLoading(controller: ETHRefreshManager, onCompletion: CompletionHandler)
}

public class ETHRefreshManager: NSObject {
  var delegate: ETHRefreshManagerDelegate?
  var scrollView = UIScrollView()
  var scrollViewStateController: ETHScrollViewStateController!
  var stateConfig: ETHStateConfiguration!

  static let DefaultStateConfig = ETHStateConfiguration(thresholdInitiateLoading: 0, thresholdStartLoading: -defaultLoaderHeight,
		loaderFrame: CGRectMake(0, -defaultLoaderHeight,UIScreen.mainScreen().bounds.size.width, defaultLoaderHeight),
		showDefaultLoader: true)

  public init(scrollView: UIScrollView, delegate: ETHRefreshManagerDelegate?, stateConfig: ETHStateConfiguration? = nil) {

   super.init()
    
   self.scrollView = scrollView
   self.delegate = delegate
   self.stateConfig = stateConfig ?? ETHRefreshManager.DefaultStateConfig
   self.scrollViewStateController = ETHScrollViewStateController(scrollView: scrollView, dataSource: self, delegate: self,
		showDefaultLoader: self.stateConfig.showDefaultLoader)
  }
}

// MARK: - ETHScrollViewStateControllerDataSource
extension ETHRefreshManager: ETHScrollViewStateControllerDataSource {
  public func scrollViewStateControllerShouldInitiateLoading(offset: CGFloat) -> Bool {
    return offset < self.stateConfig.thresholdInitiateLoading
  }
  
  public func scrollViewStateControllerShouldReleaseToStartLoading(offset: CGFloat) -> Bool {
    return offset < self.stateConfig.thresholdStartLoading
  }
  
  public func scrollViewStateControllerShouldReleaseToCancelLoading(offset: CGFloat) -> Bool {
    return offset > self.stateConfig.thresholdStartLoading
  }

  public func scrollViewStateControllerInsertLoaderInsets(startAnimation: Bool) -> UIEdgeInsets {
    var newInset = self.scrollView.contentInset
    newInset.top += startAnimation ? self.stateConfig.loaderFrame.size.height : -self.stateConfig.loaderFrame.size.height
    return newInset
  }
  
  public func scrollViewStateControllerLoaderFrame() -> CGRect {
    return self.stateConfig.loaderFrame
  }
}

// MARK: - ETHScrollViewStateControllerDelegate
extension ETHRefreshManager: ETHScrollViewStateControllerDelegate {
  public func scrollViewStateControllerDidStartLoading(controller: ETHScrollViewStateController, onCompletion: CompletionHandler) {
    self.delegate?.refreshManagerDidStartLoading(self, onCompletion: onCompletion)
  }
  
}
