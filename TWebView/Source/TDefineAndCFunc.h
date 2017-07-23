//
//  TDefine.h
//  TWebView
//
//  Created by 邵伟男 on 2017/7/22.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <Foundation/Foundation.h>

#define T_OSVersion ([[UIDevice currentDevice].systemVersion floatValue])
#define T_IS_ABOVE_IOS(v) (T_OSVersion >= v)

#ifdef DEBUG
    #define TLog(fmt, ...) NSLog((@"\n> FILE     : %s \n> FUNCTION : %s \n> LINE     : %d \n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)
    #define tweakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
    #define tstrongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
    #define TLog(...)
    #define tweakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
    #define tstrongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#endif

// 删除空白字符
NSString *removeBlankSpace(NSString *string);

// 判断是否是非nil、非空、非空格字符串
BOOL isNotEmptyString(NSString *string);

