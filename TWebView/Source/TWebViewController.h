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

@interface TWebViewController : UIViewController

@property (nonatomic, strong) TWebView *webView;

@property (nonatomic, copy) NSString * _Nullable navTitle;

- (instancetype)init;

- (void)loadURLFromString:(NSString *)urlString;

- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride;

#pragma mark - CommonWebViewDelegate

- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;


@end

NS_ASSUME_NONNULL_END
