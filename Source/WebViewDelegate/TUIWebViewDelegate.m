//
//  TUIWebViewDelegate.m
//  TWebView
//
//  Created by TBD on 2017/7/26.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "TUIWebViewDelegate.h"
#import "TWebView_Inner.h"
#import "TDefineAndCFunc.h"

// use NJK Progress https://github.com/ninjinkun/NJKWebViewProgress
NSString *completeRPCURLPath = @"/njkwebviewprogressproxy/complete";

const float WebViewInitialProgressValue = 0.1f;
const float WebViewInteractiveProgressValue = 0.5f;
const float WebViewFinalProgressValue = 0.9f;

@interface TUIWebViewDelegate()

@property(nonatomic, weak) TWebView *tWebView;

@property (nonatomic, readonly) float progress; // 0.0..1.0

@end

@implementation TUIWebViewDelegate
{
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
}

+ (instancetype)getDelegateWith:(TWebView *)webView {
    TUIWebViewDelegate *delegate = [[self.class alloc] init];
    delegate.tWebView = webView;
    return delegate;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.tWebView.request = request;
    
    if ([request.URL.path isEqualToString:completeRPCURLPath]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    if (delegate != nil) {
        ret = [delegate webView:self.tWebView
         shouldStartLoadRequest:self.tWebView.request];
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    BOOL isHTTPOrLocalFile = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"] || [request.URL.scheme isEqualToString:@"file"];
    if (ret && !isFragmentJump && isHTTPOrLocalFile && isTopLevelNavigation) {
        self->_currentURL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self.tWebView
  didStartLoadRequest:self.tWebView.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoading
                title:self.tWebView.loadingDefaultTitle];
    
    ++ self->_loadingCount;
    self->_maxLoadCount = fmax(self->_maxLoadCount, self->_loadingCount);
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self.tWebView didFinishLoadRequest:self.tWebView.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    NSString *title = self.tWebView.title;
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusSuccess
                title:isNotEmptyString(title) ? title : self.tWebView.successDefaultTitle];
    
    // 使用set方法重新注入js
    self.tWebView.selectContentType = self.tWebView.selectContentType;
    self.tWebView.scrollChangeSizeType = self.tWebView.scrollChangeSizeType;
    self.tWebView.touchCalloutType = self.tWebView.touchCalloutType;
    [self reduceLoadingCount:nil];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    TLog(@"%@", error);
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView
 didFailedLoadRequest:self.tWebView.request
            withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    NSString *title = self.tWebView.title;
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusFailed
                title:isNotEmptyString(title) ? title : self.tWebView.failedDefaultTitle];
    [self reduceLoadingCount:error];
}

#pragma mark - Calculate Progress
- (void)completeProgress {
    [self setProgress:1.0];
}

- (void)startProgress {
    if (self->_progress < WebViewInitialProgressValue) {
        [self setProgress:WebViewInitialProgressValue];
    }
}

- (void)setProgress:(float)progress {
    // progress should be incremental only
    if (progress > self->_progress || progress == 0) {
        self->_progress = progress;
        [self.tWebView setProgress:progress animated:YES];
    }
}

- (void)incrementProgress {
    float progress = self.progress;
    float maxProgress = self->_interactive ? WebViewFinalProgressValue : WebViewInteractiveProgressValue;
    float remainPercent = (float)self->_loadingCount / (float)self->_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)reset {
    self->_maxLoadCount = self->_loadingCount = 0;
    self->_interactive = NO;
    [self setProgress:0.0];
}

// UIWebView Calculate Progress Func
- (void)reduceLoadingCount:(nullable NSError*)error {
    -- self->_loadingCount;
    [self incrementProgress];
    @tweakify(self)
    [self.tWebView runJavascript:@"document.readyState" completion:^(id  _Nonnull obj, NSError * _Nonnull error) {
        @tstrongify(self)
        if ([obj isEqualToString:@"interactive"]) {
            self->_interactive = YES;
            NSString *waitForCompleteJS = [NSString stringWithFormat:@"\
                                           \n window.addEventListener('load',function() { \
                                           \n   var iframe = document.createElement('iframe');\
                                           \n   iframe.style.display = 'none'; \
                                           \n   iframe.src = '%@://%@%@';\
                                           \n   document.body.appendChild(iframe); \
                                           \n }, false);",
                                           self.tWebView.request.mainDocumentURL.scheme,
                                           self.tWebView.request.mainDocumentURL.host,
                                           completeRPCURLPath];
            [self.tWebView runJavascript:waitForCompleteJS completion:nil];
        }
        BOOL isNotRedirect = self->_currentURL && [self->_currentURL isEqual:self.tWebView.request.mainDocumentURL];
        BOOL complete = [obj isEqualToString:@"complete"];
        if ((complete && isNotRedirect) || error) {
            [self completeProgress];
        }
    }];
}


@end

