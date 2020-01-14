//
//  TWebViewConfig.m
//  TWebView
//
//  Created by TBD on 2017/7/23.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import "TWebViewConfig.h"
#import "TWebViewCommonDelegate.h"

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
        self->_webViewCommonDelegate  = TWebViewCommonDelegate.shared;
        self->_webViewDelegate        = nil;
        self->_forceOverrideCookie    = YES;
        self->_showProgressView       = YES;
        self->_progressTintColor      = [UIColor orangeColor];
        self->_progressViewHeight     = 2.0/[UIScreen mainScreen].scale;
        
        self->_selectContentType      = IBCWebViewConfigBlockTypeNotSet;
        self->_scrollChangeSizeType   = IBCWebViewConfigBlockTypeNotSet;
        self->_touchCalloutType       = IBCWebViewConfigBlockTypeNotSet;
        self->_scrollBackType         = IBCWebViewConfigBlockTypeNotSet;
        self->_webView3DTouchType     = IBCWebViewConfigBlockTypeNotSet;
        
        self->_confirmText            = @"OK";
        self->_cancelText             = @"Cancel";
        self->_loadingDefaultTitle    = @"Loading...";
        self->_successDefaultTitle    = @"Details";
        self->_failedDefaultTitle     = @"Failed";
    }
    return self;
}

@end
