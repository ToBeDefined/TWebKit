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

typedef NS_ENUM(NSUInteger, IBCWebViewConfigBlockType) {
    IBCWebViewConfigBlockTypeNotSet,
    IBCWebViewConfigBlockTypeAllow,
    IBCWebViewConfigBlockTypeForbidden,
};

@interface TWebViewConfig : NSObject

@property (class, nonatomic, strong, readonly) TWebViewConfig *defaultConfig;

@property (nonatomic, weak) id<TWebViewDelegate> _Nullable webViewCommonDelegate;
@property (nonatomic, weak) id<TWebViewDelegate> _Nullable webViewDelegate;

@property (nonatomic, assign) BOOL forceOverrideCookie;

@property (nonatomic, assign) BOOL showProgressView;
@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, assign) CGFloat progressViewHeight;

// User Interaction

// if set IBCWebViewConfigBlockTypeNone, Block most of the pages select content.
@property (nonatomic, assign) IBCWebViewConfigBlockType selectContentType;
@property (nonatomic, assign) IBCWebViewConfigBlockType scrollChangeSizeType;
// Block ActionSheet & Long Press Menus
@property (nonatomic, assign) IBCWebViewConfigBlockType touchCalloutType;
// only uper ios 8.0
@property (nonatomic, assign) IBCWebViewConfigBlockType scrollBackType;
// only uper ios 9.0
@property (nonatomic, assign) IBCWebViewConfigBlockType webView3DTouchType API_AVAILABLE(ios(9.0));

@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *loadingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

- (instancetype)init;

+ (instancetype)defaultConfig;

@end

NS_ASSUME_NONNULL_END

