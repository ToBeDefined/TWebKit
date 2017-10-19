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
@protocol WKPreviewActionItem;

typedef NS_ENUM(NSUInteger, TWebViewLoadStatus) {
    TWebViewLoadStatusIsLoading = 1,
    TWebViewLoadStatusSuccess   = 2,
    TWebViewLoadStatusFailed    = 3,
};


#pragma mark - TWebViewDelegate

@protocol TWebViewDelegate <NSObject>

@optional

- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;

#pragma mark - 3D Touch Peek & Pop; iOS 10+ available
// Set whether to allow preview url;
// If you return to NO, the following two methods will not run;
// If you return to YES, The following two methods will be run when hard pressed.
- (BOOL)webView:(TWebView *)webView shouldPreviewURL:(nullable NSURL *)url API_AVAILABLE(ios(10.0));

// If you return to nil, the preview link will be made in Safari
// If you do not want to preview the url, please return NO at method "- webView:shouldPreviewURL:"
// param "actions" is the iOS default support actions
- (nullable UIViewController *)webView:(TWebView *)webView previewingViewControllerForURL:(nullable NSURL *)url defaultActions:(NSArray<id <WKPreviewActionItem>> *)actions API_AVAILABLE(ios(10.0));

// Pop the previewing ViewController and then run this method
- (void)webView:(TWebView *)webView commitPreviewingURL:(nullable NSURL *)url controller:(UIViewController *)controller API_AVAILABLE(ios(10.0));

@end


#pragma mark - TWebView

@interface TWebView : UIView

#pragma mark - TWebView Property
@property (nonatomic, weak) id<TWebViewDelegate> _Nullable delegate;
@property (nonatomic, weak) id<TWebViewDelegate> _Nullable commonDelegate;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

// Progress View
@property (nonatomic, assign, getter=isShowProgress) BOOL showProgress;
@property (nonatomic, strong) UIColor *progressTintColor;

// User Interaction
@property (nonatomic, assign) BOOL canSelectContent;    // if set NO, Block most of the pages select content.
@property (nonatomic, assign) BOOL canScrollChangeSize;
@property (nonatomic, assign) BOOL blockTouchCallout;   // Block ActionSheet & Long Press Menus
// only uper ios 8.0
@property (nonatomic, assign) BOOL canScrollBack API_AVAILABLE(ios(8.0));
// only uper ios 9.0
@property (nonatomic, assign) BOOL block3DTouch API_AVAILABLE(ios(9.0));

// Texts
@property (nonatomic, copy) NSString *confirmText;
@property (nonatomic, copy) NSString *cancelText;
@property (nonatomic, copy) NSString *loadingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

#pragma mark - TWebView Function
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

- (void)getDocumentTitle:(void (^)(NSString * _Nullable title))completion;

// 9.0以及之后，8.0之前可用
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
// 9.0之后可用
- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(ios(9.0));

+ (nullable NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data;

- (void)runJavascript:(NSString *)js completion:(void (^ _Nullable)(_Nullable id obj, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

