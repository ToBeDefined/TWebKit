//
//  TWebKitSetting.m
//  TWebKit
//
//  Created by TBD on 2017/7/28.
//  Copyright © 2017年 TBD. All rights reserved.
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
