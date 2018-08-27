//
//  UIView+UIView_TWVLayout.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "UIView+TWVLayout.h"

@implementation UIView (TWVLayout)

- (NSLayoutAttribute)getLayoutAttribute:(TWVLayoutAttribute)attr {
    switch (attr) {
        case Left:
            return NSLayoutAttributeLeft;
        case Right:
            return NSLayoutAttributeRight;
        case Top:
            return NSLayoutAttributeTop;
        case Bottom:
            return NSLayoutAttributeBottom;
        case Leading:
            return NSLayoutAttributeLeading;
        case Trailing:
            return NSLayoutAttributeTrailing;
        case Width:
            return NSLayoutAttributeWidth;
        case Height:
            return NSLayoutAttributeHeight;
        case CenterX:
            return NSLayoutAttributeCenterX;
        case CenterY:
            return NSLayoutAttributeCenterY;
            
        case LeftMargin:
            return NSLayoutAttributeLeftMargin;
        case RightMargin:
            return NSLayoutAttributeRightMargin;
        case TopMargin:
            return NSLayoutAttributeTopMargin;
        case BottomMargin:
            return NSLayoutAttributeBottomMargin;
        case LeadingMargin:
            return NSLayoutAttributeLeadingMargin;
        case TrailingMargin:
            return NSLayoutAttributeTrailingMargin;
        case CenterXWithinMargins:
            return NSLayoutAttributeCenterXWithinMargins;
        case CenterYWithinMargins:
            return NSLayoutAttributeCenterYWithinMargins;
            
        default:
            return NSLayoutAttributeNotAnAttribute;
    }
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                        is:(CGFloat)constant {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutAttribute attribute = [self getLayoutAttribute:attr];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:constant];
    [self addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view {
    return [self twv_makeConstraint:attr equealTo:view multiplier:1.0 constant:0.0];
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutAttribute attribute = [self getLayoutAttribute:attr];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:attribute
                                                                 multiplier:multiplier
                                                                   constant:constant];
    switch (attribute) {
        case NSLayoutAttributeWidth:
        case NSLayoutAttributeHeight:
            [view addConstraint:constraint];
            break;
            
        default:
            if (view != self.superview) {
                [view addConstraint:constraint];
            } else {
                [self.superview addConstraint:constraint];
            }
            break;
    }
    return constraint;
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                 attribute:(TWVLayoutAttribute)attr2 {
    return [self twv_makeConstraint:attr
                           equealTo:view
                          attribute:attr2
                         multiplier:1.0
                           constant:0.0];
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIView *)view
                                 attribute:(TWVLayoutAttribute)attr2
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutAttribute attribute = [self getLayoutAttribute:attr];
    NSLayoutAttribute attribute2 = [self getLayoutAttribute:attr2];
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:view
                                                                  attribute:attribute2
                                                                 multiplier:multiplier
                                                                   constant:constant];
    [self.superview addConstraint:constraint];
    return constraint;
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIViewController *)controller
                               layoutGuide:(TWVLayoutGuide)attr2 {
    return [self twv_makeConstraint:attr
                           equealTo:controller
                        layoutGuide:attr2
                         multiplier:1.0
                           constant:0.0];
}

- (NSLayoutConstraint *)twv_makeConstraint:(TWVLayoutAttribute)attr
                                  equealTo:(UIViewController *)controller
                               layoutGuide:(TWVLayoutGuide)attr2
                                multiplier:(CGFloat)multiplier
                                  constant:(CGFloat)constant {
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSLayoutAttribute attribute = [self getLayoutAttribute:attr];
    NSLayoutAttribute attribute2 = NSLayoutAttributeNotAnAttribute;
    id<UILayoutSupport> layoutGuide = nil;
    switch (attr2) {
        case TopLayoutGuide:
            layoutGuide = controller.topLayoutGuide;
            attribute2 = NSLayoutAttributeBottom;
            break;
        case TopLayoutGuideTop:
            layoutGuide = controller.topLayoutGuide;
            attribute2 = NSLayoutAttributeTop;
            break;
        case TopLayoutGuideBottom:
            layoutGuide = controller.topLayoutGuide;
            attribute2 = NSLayoutAttributeBottom;
            break;
        case BottomLayoutGuide:
            layoutGuide = controller.bottomLayoutGuide;
            attribute2 = NSLayoutAttributeTop;
            break;
        case BottomLayoutGuideTop:
            layoutGuide = controller.bottomLayoutGuide;
            attribute2 = NSLayoutAttributeTop;
            break;
        case BottomLayoutGuideBottom:
            layoutGuide = controller.bottomLayoutGuide;
            attribute2 = NSLayoutAttributeBottom;
            break;
        default:
            return nil;
    }
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:attribute
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:layoutGuide
                                                                  attribute:attribute2
                                                                 multiplier:multiplier
                                                                   constant:constant];
    [controller.view addConstraint:constraint];
    return constraint;
}
@end
