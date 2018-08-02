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


