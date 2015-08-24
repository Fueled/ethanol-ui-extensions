//
//  ETHPlaceholderTextView.m
//  Ethanol
//
//  Created by Stephane Copin on 6/17/14.
//  Copyright (c) 2014 Fueled. All rights reserved.
//

#import "ETHPlaceholderTextView.h"

#define kDefaultPlaceholderInset UIEdgeInsetsMake(8.0f, 4.0f, 9.0f, 4.0f)

@interface ETHPlaceholderTextView ()

@property (nonatomic, weak) UILabel * placeholderLabel;

@end

@implementation ETHPlaceholderTextView

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if(self != nil) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if(self != nil) {
    [self commonInit];
  }
  return self;
}

- (void)commonInit {
  self.placeholderInsets = kDefaultPlaceholderInset;
  
  UILabel * placeholderLabel = [[UILabel alloc] init];
  [self updatePlaceholderFrame];
  [self addSubview:placeholderLabel];
  self.placeholderLabel = placeholderLabel;
  
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleTextViewDidBeginEditing:)
                                               name:UITextViewTextDidBeginEditingNotification
                                             object:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleTextViewDidChange:)
                                               name:UITextViewTextDidChangeNotification
                                             object:self];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(handleTextViewDidEndEditing:)
                                               name:UITextViewTextDidEndEditingNotification
                                             object:self];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UITextViewTextDidBeginEditingNotification
                                                object:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UITextViewTextDidChangeNotification
                                                object:self];
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:UITextViewTextDidEndEditingNotification
                                                object:self];
}

- (void)setText:(NSString *)text {
  [super setText:text];
  
  [self updatePlaceholderVisibility];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  [self updatePlaceholderFrame];
}

- (void)updatePlaceholderFrame {
  CGRect frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
  self.placeholderLabel.frame = UIEdgeInsetsInsetRect(frame, self.placeholderInsets);
  [self.placeholderLabel sizeToFit];
}

- (NSString *)placeholder {
  return self.placeholderLabel.text;
}

- (void)setPlaceholder:(NSString *)placeholder {
  self.placeholderLabel.text = placeholder;
  
  [self updatePlaceholderFrame];
}

- (NSAttributedString *)attributedPlaceholder {
  return self.placeholderLabel.attributedText;
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder {
  self.placeholderLabel.attributedText = attributedPlaceholder;
  
  [self updatePlaceholderFrame];
}

- (void)handleTextViewDidBeginEditing:(NSNotification *)notification {
  [self updatePlaceholderVisibility];
}

- (void)handleTextViewDidChange:(NSNotification *)notification {
  [self updatePlaceholderVisibility];
}

- (void)handleTextViewDidEndEditing:(NSNotification *)notification {
  [self updatePlaceholderVisibility];
}

- (void)updatePlaceholderVisibility {
  self.placeholderLabel.hidden = [self.text length] > 0;
  [self sendSubviewToBack:self.placeholderLabel];
}

@end