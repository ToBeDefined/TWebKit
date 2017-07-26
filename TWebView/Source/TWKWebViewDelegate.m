//
//  TWKWebViewDelegate.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "TWKWebViewDelegate.h"
#import <WebKit/WebKit.h>
#import "TWebView.h"
#import "TDefineAndCFunc.h"

@interface TWKWebViewDelegate()

@property(nonatomic, weak) TWebView *tWebView;
@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation TWKWebViewDelegate

+ (instancetype)getDelegateWith:(TWebView *)webView {
    TWKWebViewDelegate *delegate = [[self.class alloc] init];
    delegate.tWebView = webView;
    return delegate;
}


#pragma mark - WKNavigationDelegate

// 相当于 - webView:shouldStartLoadWithRequest:navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    self.request = navigationAction.request;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    if (delegate != nil) {
        BOOL isCanLoad = [delegate webView:self.tWebView shouldStartLoadRequest:navigationAction.request];
        if (!isCanLoad) {
            decisionHandler(WKNavigationActionPolicyCancel);
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self.tWebView didStartLoadRequest:self.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoding
                title:self.tWebView.lodingDefaultTitle];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoding
                title:self.tWebView.lodingDefaultTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 禁止放大缩小
    if (!self.tWebView.canScrollChangeSize) {
        NSString *injectionJSString = @"\
        \n var script = document.createElement('meta');\
        \n script.name = 'viewport';\
        \n script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";\
        \n document.getElementsByTagName('head')[0].appendChild(script);\
        \n ";
        [webView evaluateJavaScript:injectionJSString
                  completionHandler:nil];
    }
    
    if (self.tWebView.blockActionSheet) {
        [webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';"
                  completionHandler:nil];
    } else {
        [webView evaluateJavaScript:@"document.body.style.webkitTouchCallout='inherit';"
                  completionHandler:nil];
    }
    
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self.tWebView didFinishLoadRequest:self.request];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TLog(@"%@", error);
    if (webView.isLoading) {
        return;
    }
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView didFailedLoadRequest:self.request withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusFailed
                title:self.tWebView.failedDefaultTitle];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TLog(@"%@", error);
    if (webView.isLoading) {
        return;
    }
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView didFailedLoadRequest:self.request withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusFailed
                title:self.tWebView.failedDefaultTitle];
}


#pragma mark - WKUIDelegate
// 一定是iOS8才会运行到此，使用UIAlertController
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmTitle
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler();
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmTitle
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(YES);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.cancelTitle
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(NO);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:prompt
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmTitle
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSString *input = ((UITextField *)ac.textFields.firstObject).text;
                                             completionHandler(input);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.cancelTitle
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             completionHandler(nil);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}


-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

@end
