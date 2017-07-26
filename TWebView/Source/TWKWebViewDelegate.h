//
//  TWKWebViewDelegate.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/26.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@class TWebView;

@interface TWKWebViewDelegate : NSObject <WKNavigationDelegate, WKUIDelegate>

+ (instancetype)getDelegateWith:(TWebView *)webView;

@end
