//
//  TWebViewConfig.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/23.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "TWebViewConfig.h"

@implementation TWebViewConfig

- (instancetype)init
{
    self = [super init];
    if (self) {
        _commonDelegate = nil;
        _delegate = nil;
        _forceOverrideCookie = YES;
        _showProgressView = YES;
        _progressTintColor = [UIColor blueColor];
        _canScrollChangeSize = true;
        _confirmText = @"OK";
        _cancelText = @"Cancel";
        _lodingDefaultTitle = @"Loding...";
        _successDefaultTitle = @"Details";
        _failedDefaultTitle = @"Failed";
    }
    return self;
}

@end
