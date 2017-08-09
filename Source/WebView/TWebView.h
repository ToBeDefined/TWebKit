//
//  TWebView.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/22.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebViewConfig.h"


NS_ASSUME_NONNULL_BEGIN

@class TWebView;
@class WKNavigation;

typedef NS_ENUM(NSUInteger, TWebViewLoadStatus) {
    TWebViewLoadStatusIsLoding = 1,
    TWebViewLoadStatusSuccess  = 2,
    TWebViewLoadStatusFailed   = 3,
};

@protocol TWebViewDelegate <NSObject>

@optional

- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;

@end

@interface TWebView : UIView

@property (nonatomic, weak) id<TWebViewDelegate> _Nullable delegate;
@property (nonatomic, weak) id<TWebViewDelegate> _Nullable commonDelegate;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

// Progress View
@property (nonatomic, assign, getter=isShowProgress) BOOL showProgress;
@property (nonatomic, strong) UIColor *progressTintColor;

// User Interaction
// only uper ios 8.0
@property (nonatomic, assign) BOOL canScrollBack API_AVAILABLE(ios(8.0));
@property (nonatomic, assign) BOOL canScrollChangeSize API_AVAILABLE(ios(8.0));
@property (nonatomic, assign) BOOL blockActionSheet API_AVAILABLE(ios(8.0));
// only uper ios 9.0
@property (nonatomic, assign) BOOL block3DTouch API_AVAILABLE(ios(9.0));

// Texts
@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *lodingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

- (instancetype)init;
- (instancetype)initWithConfig:(TWebViewConfig *)config;
- (nullable id<TWebViewDelegate>)getDelegateWithSEL:(SEL)sel;

- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL;

- (void)clearCache;

// this forceOverride just once valid
- (void)resetCookieForceOverride:(BOOL)forceOverride;

// 9.0以及之后，8.0之前可用
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
// 9.0之后可用
- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(ios(9.0));

+ (nullable NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data;

- (void)runJavascript:(NSString *)js completion:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

