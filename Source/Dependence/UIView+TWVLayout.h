//
//  UIView+UIView_TWVLayout.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TWVLayoutAttribute) {
    Left,
    Right,
    Top,
    Bottom,
    Leading,
    Trailing,
    Width,
    Height,
    CenterX,
    CenterY,
    
    LeftMargin NS_ENUM_AVAILABLE_IOS(8_0),
    RightMargin NS_ENUM_AVAILABLE_IOS(8_0),
    TopMargin NS_ENUM_AVAILABLE_IOS(8_0),
    BottomMargin NS_ENUM_AVAILABLE_IOS(8_0),
    LeadingMargin NS_ENUM_AVAILABLE_IOS(8_0),
    TrailingMargin NS_ENUM_AVAILABLE_IOS(8_0),
    CenterXWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
    CenterYWithinMargins NS_ENUM_AVAILABLE_IOS(8_0),
};

typedef NS_ENUM(NSUInteger, TWVLayoutGuide) {
    TopLayoutGuide,
    BottomLayoutGuide,
    TopLayoutGuideTop,
    TopLayoutGuideBottom,
    BottomLayoutGuideTop,
    BottomLayoutGuideBottom,
} NS_ENUM_AVAILABLE_IOS(7_0) ;


@interface UIView (TWVLayout)

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                        is:(CGFloat)constant;

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view;

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant;

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                 attribute:(TWVLayoutAttribute)attr2;

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                 attribute:(TWVLayoutAttribute)attr2
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant;

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIViewController *)controller
                               layoutGuide:(TWVLayoutGuide)attr2 API_AVAILABLE(ios(7.0));

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIViewController *)controller
                               layoutGuide:(TWVLayoutGuide)attr2
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant API_AVAILABLE(ios(7.0));

@end
