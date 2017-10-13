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
    // 半角空格
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    // 全角空格
    string = [string stringByReplacingOccurrencesOfString:@"　" withString:@""];
    return string;
}

BOOL isEmptyString(NSString *string) {
    if (string == nil || [removeBlankSpace(string) isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

// 判断是否是非nil、非空、非空格字符串
BOOL isNotEmptyString(NSString *string) {
    return !isEmptyString(string);
}

NSString *trueURLString(NSString *urlString) {
    TLog(@"absoluteString : %@", urlString);
    TLog(@"pathExtension  : %@", [urlString pathExtension]);
    
    // 将%编码转换为UTF-8字符
    urlString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // 去除urlString中前后空格字符（全角以及半角空格）
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" 　"]];
    
    // 检查urlString是否包含协议头，如果不包含默认使用http协议
    if ([urlString rangeOfString:@"://"].location == NSNotFound) {
        urlString = [NSString stringWithFormat:@"%@%@", @"http://", urlString];
    }
    
    // 检查urlString不包含扩展名并且不是访问servlet，此时在末尾需要有 '/'
    NSString *pathExtension = [[urlString pathExtension] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ( !isNotEmptyString(pathExtension) && [urlString rangeOfString:@"?"].location == NSNotFound ) {
        if (![urlString hasSuffix:@"/"]) {
            urlString = [urlString stringByAppendingString:@"/"];
        }
    }
    
    // 添加随机后缀参数
    if ([urlString rangeOfString:@"_reloadWebViewData_sign_"].location == NSNotFound) {
        // 生成随机后缀
        NSString *randomString;
        if ([urlString rangeOfString:@"?"].location == NSNotFound) {
            randomString = [NSString stringWithFormat:@"?%@=%.8u", @"_reloadWebViewData_sign_", arc4random_uniform(100000000)];
        } else {
            randomString = [NSString stringWithFormat:@"&%@=%.8u", @"_reloadWebViewData_sign_", arc4random_uniform(100000000)];
        }
        
        // 插入随机后缀的位置
        NSUInteger numberSignLocation = [urlString rangeOfString:@"#" options:NSBackwardsSearch].location;
        if (numberSignLocation != NSNotFound) {
            NSMutableString *url_s = [urlString mutableCopy];
            [url_s insertString:randomString
                        atIndex:numberSignLocation];
            urlString = url_s;
        } else {
            urlString = [urlString stringByAppendingString:randomString];
        }
    }
    
    // 将UTF-8字符转换为%编码
    urlString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                          (CFStringRef)urlString,
                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                          NULL,
                                                                          kCFStringEncodingUTF8));;
    TLog(@"new urlString  : %@", urlString);
    return urlString;
}

UIViewController *findShowingViewController(UIViewController *controller) {
    if (controller.presentedViewController) {
        return findShowingViewController(controller.presentedViewController);
    } else if ([controller isKindOfClass:[UISplitViewController class]]) {
        UISplitViewController *svc = (UISplitViewController*)controller;
        if (svc.viewControllers.count > 0)
            return findShowingViewController(svc.viewControllers.lastObject);
        else
            return controller;
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nvc = (UINavigationController*)controller;
        if (nvc.viewControllers.count > 0)
            return findShowingViewController(nvc.topViewController);
        else
            return controller;
    } else if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tvc = (UITabBarController*)controller;
        if (tvc.viewControllers.count > 0)
            return findShowingViewController(tvc.selectedViewController);
        else
            return controller;
    } else {
        return controller;
    }
}

UIViewController *getCurrentViewController() {
    return findShowingViewController([UIApplication sharedApplication].delegate.window.rootViewController);
}


