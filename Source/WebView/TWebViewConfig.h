//
//  TWebViewConfig.h
//  TWebView
//
//  Created by TBD on 2017/7/23.
//  Copyright © 2017年 TBD. All rights reserved.
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
@property (nonatomic, assign) CGFloat progressViewHeight;

// User Interaction
@property (nonatomic, assign) BOOL canSelectContent;        // if set NO, Block most of the pages select content.
@property (nonatomic, assign) BOOL canScrollChangeSize;
@property (nonatomic, assign) BOOL blockTouchCallout;       // Block ActionSheet & Long Press Menus
// only uper ios 8.0
@property (nonatomic, assign) BOOL canScrollBack API_AVAILABLE(ios(8.0));
// only uper ios 9.0
@property (nonatomic, assign) BOOL block3DTouch API_AVAILABLE(ios(9.0));

@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *loadingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

- (instancetype)init;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END

