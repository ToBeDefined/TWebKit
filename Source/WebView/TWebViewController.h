//
//  TWebViewController.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TWebViewControllerNavigationTitleLevel) {
    TWebViewControllerNavigationTitleLevelDefault   = 0,
    TWebViewControllerNavigationTitleLevelAlways    = 1,
};

@interface TWebViewController : UIViewController

@property (nonatomic, strong) TWebView *webView;

@property (nonatomic, copy) NSString * _Nullable navTitle NS_DEPRECATED(2.0, 2.0, 2.0, 2.0, "Use `navgationTitle`");
@property (nonatomic, copy) NSString * _Nullable navgationTitle;
@property (nonatomic, assign) TWebViewControllerNavigationTitleLevel navgationTitleLevel;
@property (nonatomic, strong) UIImage * _Nullable backImage;

@property (nonatomic, strong) NSArray<id<UIPreviewActionItem>> * _Nonnull previewActions;

- (instancetype)init;

- (instancetype)initWithConfig:(TWebViewConfig *)config;

- (void)loadURLFromString:(NSString *)urlString;
- (void)loadURLAndAutoConversionFromString:(NSString *)urlString;

- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride;

@end

NS_ASSUME_NONNULL_END
