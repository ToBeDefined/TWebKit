//
//  TWebViewController.h
//  TWebView
//
//  Created by TBD on 2017/7/27.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWebViewControllerNavigationTitleLevel) {
    TWebViewControllerNavigationTitleLevelDefault   = 0,
    TWebViewControllerNavigationTitleLevelAlways    = 1,
};

@interface TWebViewController : UIViewController

/// default is `NSURLRequestUseProtocolCachePolicy`
@property (class, nonatomic, assign) NSURLRequestCachePolicy defaultCachePolicy;
/// default is `60.0`
@property (class, nonatomic, assign) NSTimeInterval defaultTimeoutInterval;

@property (nonatomic, strong) TWebView *webView;

@property (nonatomic, copy) NSString * _Nullable navTitle NS_DEPRECATED(2.0, 2.0, 2.0, 2.0, "Use `navgationTitle`");
@property (nonatomic, copy) NSString * _Nullable navgationTitle;
@property (nonatomic, assign) TWebViewControllerNavigationTitleLevel navgationTitleLevel;
@property (nonatomic, strong) UIImage * _Nullable backImage;

@property (nonatomic, strong) NSArray<id<UIPreviewActionItem>> * _Nonnull previewActions API_AVAILABLE(ios(9.0));

- (instancetype)init;

- (instancetype)initWithConfig:(TWebViewConfig *)config;

/// use defaultCachePolicy and defaultTimeoutInterval for NSURLRequest
- (void)loadURLFromString:(NSString *)urlString;

- (void)loadURLFromString:(NSString *)urlString
              cachePolicy:(NSURLRequestCachePolicy)cachePolicy
          timeoutInterval:(NSTimeInterval)timeoutInterval;

- (void)loadLocalFileInPath:(NSString *)filePath;

- (void)loadLocalFileInBasePath:(NSString *)basePath relativeFilePath:(nullable NSString *)relativeFilePath;

- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride NS_SWIFT_NAME(resetWebViewCookie(forceOverride:));

@end

NS_ASSUME_NONNULL_END
