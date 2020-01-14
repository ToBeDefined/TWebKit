//
//  TWebViewCommonDelegate.m
//  TWebView
//
//  Created by TBD on 2017/7/27.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "TWebViewCommonDelegate.h"
#import "TDefineAndCFunc.h"
#import "TWebViewController.h"
#import <UIKit/UIKit.h>

static TWebViewCommonDelegate *__staticInstance;

@interface TWebViewCommonDelegate() <NSCopying>

@end

@implementation TWebViewCommonDelegate


#pragma mark: Shared Instance
+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __staticInstance = [[self.class alloc] init];
    });
    return __staticInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __staticInstance = [super allocWithZone:zone];
    });
    return __staticInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSLog(@"shared TWebViewCommonDelegate");
        });
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return __staticInstance;
}


- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request {
    NSURL *url = request.URL;
    if ([url.absoluteString isEqualToString:@"about:blank"]) {
        return NO;
    }
    if ([url.absoluteString rangeOfString:@"://itunes.apple.com"].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:url];
        return NO;
    }
    
    if ([url.scheme isEqualToString:@"tel"] || [url.scheme isEqualToString:@"sms"]) {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            NSString *message = @"You device dosen't support this link";
            if (@available(iOS 8, *)) {
                UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                [ac addAction:[UIAlertAction actionWithTitle:webView.confirmText
                                                       style:UIAlertActionStyleCancel
                                                     handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                message:message
                                                               delegate:nil
                                                      cancelButtonTitle:webView.confirmText
                                                      otherButtonTitles:nil];
                [alert show];
            }
        }
        return NO;
    }
    return YES;
}

- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request {
    
}

- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request {
    
}

- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error {
    
}

- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title {
    
}

#pragma mark - 3D Touch Peek & Pop; iOS 10+ available

- (BOOL)webView:(TWebView *)webView shouldPreviewURL:(NSURL *)url {
    return true;
}

- (UIViewController *)webView:(TWebView *)webView previewingViewControllerForURL:(NSURL *)url defaultActions:(NSArray<id<WKPreviewActionItem>> *)actions {
    TWebViewController *previewViewController = [[TWebViewController alloc] init];
    previewViewController.view.backgroundColor = [UIColor whiteColor];
    if (previewViewController.previewActions == nil) {
        previewViewController.previewActions = (NSArray<id<UIPreviewActionItem>> *)actions;
        [previewViewController loadURLFromString:url.absoluteString];
    }
    return previewViewController;
}

- (void)webView:(TWebView *)webView commitPreviewingURL:(NSURL *)url controller:(UIViewController *)controller {
    // Test
    UIViewController *currentVC = getCurrentViewController();
    if (currentVC.navigationController != nil) {
        [currentVC.navigationController pushViewController:controller animated:true];
    } else {
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
        [currentVC presentViewController:nav animated:YES completion:nil];
    }
}


@end



