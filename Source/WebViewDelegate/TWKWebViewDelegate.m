//
//  TWKWebViewDelegate.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

/**
// WKWebView
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
// 当内容开始返回时调用
-(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation*)navigation;
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
// 在收到响应后，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
// 在发送请求之前，决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
*/

#import "TWKWebViewDelegate.h"
#import "TWebView_Inner.h"
#import "TDefineAndCFunc.h"

@interface TWKWebViewDelegate()

@property(nonatomic, weak) TWebView *tWebView;
@property(nonatomic, weak) NSURL * _Nullable previewingURL;

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
    self.tWebView.request = navigationAction.request;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    if (delegate != nil) {
        BOOL isCanLoad = [delegate webView:self.tWebView shouldStartLoadRequest:navigationAction.request];
        if (!isCanLoad) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self.tWebView didStartLoadRequest:self.tWebView.request];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoading
                title:self.tWebView.loadingDefaultTitle];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self.tWebView
           loadStatus:TWebViewLoadStatusIsLoading
                title:self.tWebView.loadingDefaultTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    // 使用set方法重新注入js
    self.tWebView.canSelectContent = self.tWebView.canSelectContent;
    self.tWebView.canScrollChangeSize = self.tWebView.canScrollChangeSize;
    self.tWebView.blockTouchCallout = self.tWebView.blockTouchCallout;
    
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self.tWebView didFinishLoadRequest:self.tWebView.request];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TLog(@"%@", error);
    if (webView.isLoading) {
        return;
    }
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView didFailedLoadRequest:self.tWebView.request withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [self.tWebView getDocumentTitle:^(NSString * _Nullable title) {
        [delegate webView:self.tWebView
               loadStatus:TWebViewLoadStatusFailed
                    title:isNotEmptyString(title) ? title : self.tWebView.failedDefaultTitle];
    }];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    TLog(@"%@", error);
    if (webView.isLoading) {
        return;
    }
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self.tWebView didFailedLoadRequest:self.tWebView.request withError:error];
    
    delegate = [self.tWebView getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [self.tWebView getDocumentTitle:^(NSString * _Nullable title) {
        [delegate webView:self.tWebView
               loadStatus:TWebViewLoadStatusFailed
                    title:isNotEmptyString(title) ? title : self.tWebView.failedDefaultTitle];
    }];
}


#pragma mark - WKUIDelegate
// 一定是iOS8才会运行到此，使用UIAlertController
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmText
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
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmText
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(YES);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.cancelText
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
    
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.confirmText
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSString *input = ((UITextField *)ac.textFields.firstObject).text;
                                             completionHandler(input);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:self.tWebView.cancelText
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             completionHandler(nil);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}


- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - 3D Touch Peek & Pop; iOS 10+ available

- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo {
    self.previewingURL = nil;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:shouldPreviewURL:)];
    if (delegate != nil) {
        return [delegate webView:self.tWebView shouldPreviewURL:elementInfo.linkURL];
    }
    return YES;
}

- (UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id<WKPreviewActionItem>> *)previewActions {
    self.previewingURL = elementInfo.linkURL;
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:previewingViewControllerForURL:defaultActions:)];
    if (delegate != nil) {
        return [delegate webView:self.tWebView previewingViewControllerForURL:elementInfo.linkURL defaultActions:previewActions];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController {
    id<TWebViewDelegate> delegate = [self.tWebView getDelegateWithSEL:@selector(webView:commitPreviewingURL:controller:)];
    [delegate webView:self.tWebView commitPreviewingURL:self.previewingURL controller:previewingViewController];
    self.previewingURL = nil;
}

@end
