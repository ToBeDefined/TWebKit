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
        _webViewCommonDelegate  = nil;
        _webViewDelegate        = nil;
        _forceOverrideCookie    = YES;
        _showProgressView       = YES;
        _progressTintColor      = [UIColor blueColor];
        
        _canScrollBack          = YES;
        _canScrollChangeSize    = YES;
        _blockActionSheet       = NO;
        _block3DTouch           = NO;
        
        _confirmText            = @"OK";
        _cancelText             = @"Cancel";
        _lodingDefaultTitle     = @"Loding...";
        _successDefaultTitle    = @"Details";
        _failedDefaultTitle     = @"Failed";
    }
    return self;
}

@end
