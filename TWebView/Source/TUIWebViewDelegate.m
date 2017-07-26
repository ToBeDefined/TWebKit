//
//  TUIWebViewDelegate.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "TUIWebViewDelegate.h"
#import <WebKit/WebKit.h>
#import "TWebView.h"
#import "TDefineAndCFunc.h"

const float WebViewInitialProgressValue = 0.1f;
const float WebViewInteractiveProgressValue = 0.5f;
const float WebViewFinalProgressValue = 0.9f;

@interface TUIWebViewDelegate()

@property(nonatomic, weak) TWebView *tWebView;
@property (nonatomic, strong) NSURLRequest *request;

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
    self.request = request;
    
    if ([request.URL.absoluteString isEqualToString:@"webviewprogress:///complete"]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    if (delegate != nil) {
        ret = [delegate webView:self.tWebView
         shouldStartLoadRequest:self.request];
    }
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self.tWebView
  didStartLoadRequest:self.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoding
                title:self.tWebView.lodingDefaultTitle];
    
    ++ _loadingCount;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self.tWebView didFinishLoadRequest:self.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [self.tWebView runJavascriptString:@"document.title"
                     completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
                         NSString *title = obj;
                         title = isNotEmptyString(title) ? title : self.tWebView.successDefaultTitle;
                         [delegate webView:self.tWebView
                                loadStatus:TWebViewLoadStatusSuccess
                                     title:title];
                         if (error != nil) {
                             TLog(@"%@", error);
                         }
                     }];
    
    if (self.tWebView.blockActionSheet) {
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    } else {
        [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='inherit';"];
    }
    
    [self reduceLoadingCount];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    TLog(@"%@", error);
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView
 didFailedLoadRequest:self.request
            withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusFailed
                title:self.tWebView.failedDefaultTitle];
    
    [self reduceLoadingCount];
}

#pragma mark - Calculate Progress
- (void)completeProgress {
    [self setProgress:1.0];
}

- (void)startProgress {
    if (_progress < WebViewInitialProgressValue) {
        [self setProgress:WebViewInitialProgressValue];
    }
}

- (void)setProgress:(float)progress {
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        [self.tWebView setProgress:progress animated:YES];
    }
}

- (void)incrementProgress {
    float progress = self.progress;
    float maxProgress = _interactive ? WebViewFinalProgressValue : WebViewInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)reset {
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

// UIWebView Calculate Progress Func
- (void)reduceLoadingCount {
    --_loadingCount;
    [self incrementProgress];
    @tweakify(self)
    [self.tWebView runJavascriptString:@"document.readyState"
                     completionHandler:^(id  _Nonnull obj, NSError * _Nonnull error) {
                         @tstrongify(self)
                         NSString *readyString;
                         if (obj != nil) {
                             readyString = (NSString *)obj;
                             BOOL interactive = [readyString isEqualToString:@"interactive"];
                             if (interactive) {
                                 _interactive = YES;
                                 NSString *waitForCompleteJS = [NSString stringWithFormat:@"\
                                                                \nwindow.addEventListener('load', function() {\
                                                                \n    var iframe = document.createElement('iframe');\
                                                                \n    iframe.style.display = 'none'; iframe.src = '%@';\
                                                                \n    document.body.appendChild(iframe);\
                                                                \n}, false);\
                                                                \n", @"webviewprogress:///complete"];
                                 [self.tWebView runJavascriptString:waitForCompleteJS
                                                  completionHandler:nil];
                             }
                         }
                         BOOL isNotRedirect = _currentURL && [_currentURL isEqual:self.request.mainDocumentURL];
                         BOOL complete = [readyString isEqualToString:@"complete"];
                         if (complete && isNotRedirect) {
                             [self completeProgress];
                         }
                         
                     }];
}


@end

