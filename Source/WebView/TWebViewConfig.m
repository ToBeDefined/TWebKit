//
//  TWebViewConfig.m
//  TWebView
//
//  Created by TBD on 2017/7/23.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "TWebViewConfig.h"

@implementation TWebViewConfig

+ (instancetype)defaultConfig {
    static TWebViewConfig *_defaultTWebViewConfig = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _defaultTWebViewConfig = [[TWebViewConfig alloc] init];
    });
    return _defaultTWebViewConfig;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _webViewCommonDelegate  = nil;
        _webViewDelegate        = nil;
        _forceOverrideCookie    = YES;
        _showProgressView       = YES;
        _progressTintColor      = [UIColor blueColor];
        _progressViewHeight     = 1.0;
        
        _canSelectContent       = YES;
        _canScrollBack          = YES;
        _canScrollChangeSize    = YES;
        _blockTouchCallout      = NO;
        _block3DTouch           = NO;
        
        _confirmText            = @"OK";
        _cancelText             = @"Cancel";
        _loadingDefaultTitle    = @"Loading...";
        _successDefaultTitle    = @"Details";
        _failedDefaultTitle     = @"Failed";
    }
    return self;
}

@end
