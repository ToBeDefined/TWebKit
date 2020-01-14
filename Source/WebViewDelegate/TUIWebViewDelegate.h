//
//  TUIWebViewDelegate.h
//  TWebView
//
//  Created by TBD on 2017/7/26.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class TWebView;

@interface TUIWebViewDelegate : NSObject <UIWebViewDelegate>

+ (instancetype)getDelegateWith:(TWebView *)webView;

@end
