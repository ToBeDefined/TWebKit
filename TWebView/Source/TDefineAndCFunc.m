//
//  TDefineAndCFunc.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/22.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "TDefineAndCFunc.h"

// 删除空白字符
NSString *removeBlankSpace(NSString *string) {
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 判断是否是非nil、非空、非空格字符串
BOOL isNotEmptyString(NSString *string) {
    if (string != nil && ![removeBlankSpace(string) isEqualToString:@""]) {
        return YES;
    }
    return NO;
}
