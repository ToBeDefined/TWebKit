//
//  TWebView_Inner.h
//  TWebView
//
//  Created by TBD on 2017/7/27.
//  Copyright © 2017年 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TWebView.h"

@interface TWebView()

@property (nonatomic, strong) NSURLRequest *request;

- (void)setProgress:(double)progress animated:(BOOL)animated;

@end
