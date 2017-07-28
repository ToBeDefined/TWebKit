//
//  TWebViewConfig.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/23.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TWebViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface TWebViewConfig : NSObject

@property (nonatomic, weak) id<TWebViewDelegate> _Nullable webViewCommonDelegate;
@property (nonatomic, weak) id<TWebViewDelegate> _Nullable webViewDelegate;
@property (nonatomic, assign) BOOL forceOverrideCookie;
@property (nonatomic, assign) BOOL showProgressView;
@property (nonatomic, strong) UIColor *progressTintColor;

// User Interaction
// only uper ios 8.0
@property (nonatomic, assign) BOOL canScrollBack;
@property (nonatomic, assign) BOOL canScrollChangeSize;
@property (nonatomic, assign) BOOL blockActionSheet;
// only uper ios 9.0
@property (nonatomic, assign) BOOL block3DTouch;


@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *lodingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END

