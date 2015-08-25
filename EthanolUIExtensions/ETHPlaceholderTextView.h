//
//  ETHPlaceholderTextView.h
//  Ethanol
//
//  Created by Stephane Copin on 6/17/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ETHPlaceholderTextView : UITextView

@property (nonatomic, strong) NSString *placeholder;
@property (nonatomic, strong) NSAttributedString *attributedPlaceholder;

@property (nonatomic, assign) UIEdgeInsets placeholderInsets;

@end
