//
//  TWebView_Inner.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebView.h"

@interface TWebView()

@property (nonatomic, strong) NSURLRequest *request;

- (void)setProgress:(double)progress animated:(BOOL)animated;

@end
