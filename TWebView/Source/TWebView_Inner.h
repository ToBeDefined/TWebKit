//
//  TWebView_Inner.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebView.h"
@class WKProcessPool;
@class WKWebView;
@class TWKWebViewDelegate;
@class TUIWebViewDelegate;

@interface TWebView()

@property (nonatomic, strong) WKProcessPool *processPool;
@property (nonatomic, strong) WKWebView *wkWebView NS_AVAILABLE(10_10, 8_0);
@property (nonatomic, strong) TWKWebViewDelegate *wkWebViewDelegate;

@property (nonatomic, strong) UIWebView *uiWebView;
@property (nonatomic, strong) TUIWebViewDelegate *uiWebViewDelegate;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL forceOverrideCookie;

@property (nonatomic, strong) NSURLRequest *request;

@property (nonatomic, weak) NSLayoutConstraint *progressViewTopConstraint;

- (void)setProgress:(double)progress animated:(BOOL)animated;

@end
