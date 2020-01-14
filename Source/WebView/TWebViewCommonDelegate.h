//
//  TWebViewCommonDelegate.h
//  TWebView
//
//  Created by TBD on 2017/7/27.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TWebViewCommonDelegate : NSObject <TWebViewDelegate>

@property (class, nonatomic, strong, readonly) TWebViewCommonDelegate *shared;

#pragma mark - TWebViewDelegate
- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;

#pragma mark - 3D Touch Peek & Pop; iOS 10+ available
- (BOOL)webView:(TWebView *)webView shouldPreviewURL:(nullable NSURL *)url API_AVAILABLE(ios(10.0));

- (nullable UIViewController *)webView:(TWebView *)webView previewingViewControllerForURL:(nullable NSURL *)url defaultActions:(NSArray<id <WKPreviewActionItem>> *)actions API_AVAILABLE(ios(10.0));

- (void)webView:(TWebView *)webView commitPreviewingURL:(nullable NSURL *)url controller:(UIViewController *)controller API_AVAILABLE(ios(10.0));

@end

NS_ASSUME_NONNULL_END
