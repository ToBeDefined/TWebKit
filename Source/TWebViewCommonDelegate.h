//
//  TWebViewCommonDelegate.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TWebView.h"

@interface TWebViewCommonDelegate : NSObject <TWebViewDelegate>

+ (instancetype)sharedInstance;

- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;


@end
