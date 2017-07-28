//
//  TWebKitSetting.m
//  TWebKit
//
//  Created by 邵伟男 on 2017/7/28.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import "TWebKitSetting.h"

BOOL TWebKitIsShowLog = YES;

@implementation TWebKitSetting

+ (void)showAllErrorLog:(BOOL)isShowLog {
    TWebKitIsShowLog = isShowLog;
}

+ (BOOL)isShowLog {
    return TWebKitIsShowLog;
}

@end
