//
//  TWebView.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/22.
//  Copyright © 2017年 邵伟男. All rights reserved.
//


#import "TDefineAndCFunc.h"
#import "TWebView.h"

/**
 // 准备加载页面
 UIWebViewDelegate       - webView:shouldStartLoadWithRequest:navigationType
 WKNavigationDelegate    - webView:didStartProvisionalNavigation:
 
 
 // 已开始加载页面，可以在这一步向view中添加一个过渡动画
 UIWebViewDelegate       - webViewDidStartLoad:
 WKNavigationDelegate    - webView:didCommitNavigation:
 
 
 // 页面已全部加载，可以在这一步把过渡动画去掉
 UIWebViewDelegate       - webViewDidFinishLoad:
 WKNavigationDelegate    - webView:didFinishNavigation:
 
 
 // 加载页面失败
 UIWebViewDelegate       - webView:didFailLoadWithError:
 WKNavigationDelegate    - webView:didFailNavigation:withError:
 WKNavigationDelegate    - webView:didFailProvisionalNavigation:withError:
 
 
 // 是否允许加载页面
 UIWebViewDelegate       - webView:shouldStartLoadWithRequest:navigationType:
 WKNavigationDelegate    - webView:decidePolicyForNavigationAction:decisionHandler:
 */

#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "TWebView_Inner.h"
#import "TWebViewConfig.h"
#import "UIView+TWVLayout.h"
#import "TWKWebViewDelegate.h"
#import "TUIWebViewDelegate.h"

static const NSString * WKWebViewProcessPoolKey = @"WKWebViewProcessPoolKey";

@implementation TWebView

#pragma mark - Memory
- (void)dealloc {
    if (T_IS_ABOVE_IOS(8)) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
        [self.wkWebView removeObserver:self forKeyPath:@"scrollView.contentInset"];
    } else {
        [self.uiWebView removeObserver:self forKeyPath:@"scrollView.contentInset"];
    }
}

- (instancetype)initWithConfig:(TWebViewConfig *)config {
    self = [super init];
    if (self) {
        _commonDelegate         = config.webViewCommonDelegate;
        _delegate               = config.webViewDelegate;
        _forceOverrideCookie    = config.forceOverrideCookie;
        _showProgress           = config.showProgressView;
        _progressTintColor      = config.progressTintColor;
        
        _canSelectContent       = config.canSelectContent;
        _canScrollChangeSize    = config.canScrollChangeSize;
        _blockTouchCallout      = config.blockTouchCallout;
        _canScrollBack          = config.canScrollBack;
        _block3DTouch           = config.block3DTouch;
        
        _confirmText            = config.confirmText;
        _cancelText             = config.cancelText;
        _lodingDefaultTitle     = config.lodingDefaultTitle;
        _successDefaultTitle    = config.successDefaultTitle;
        _failedDefaultTitle     = config.failedDefaultTitle;
        
        [self setUI];
    }
    return self;
}

- (instancetype)init {
    TWebViewConfig *config = [[TWebViewConfig alloc] init];
    return [self initWithConfig:config];
}


#pragma mark - Setter/Getter

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.showProgress = YES;
    self.progressView.progressTintColor = progressTintColor;
}

- (void)setCanSelectContent:(BOOL)canSelectContent {
    _canSelectContent = canSelectContent;
    if (canSelectContent) {
        [self runJavascript:@"\
         \n document.documentElement.style.webkitUserSelect='all'; \
         \n document.documentElement.style.khtmlUserSelect='all'; \
         \n document.documentElement.style.mozUserSelect='all'; \
         \n document.documentElement.style.msUserSelect='all'; \
         \n document.documentElement.style.userSelect='all'; \
         \n"
                 completion:nil];
    } else {
        [self runJavascript:@"\
         \n document.documentElement.style.webkitUserSelect='none'; \
         \n document.documentElement.style.khtmlUserSelect='none'; \
         \n document.documentElement.style.mozUserSelect='none'; \
         \n document.documentElement.style.msUserSelect='none'; \
         \n document.documentElement.style.userSelect='none'; \
         \n"
                 completion:nil];
    }
}

- (void)setCanScrollBack:(BOOL)canScrollBack {
    _canScrollBack = canScrollBack;
    if (!T_IS_ABOVE_IOS(8)) {
        TLog(" canScrollBack 不支持iOS8以下机型");
        return;
    }
    
    self.wkWebView.allowsBackForwardNavigationGestures = _canScrollBack;
}

- (void)setCanScrollChangeSize:(BOOL)canScrollChangeSize {
    _canScrollChangeSize = canScrollChangeSize;
    
    NSString *injectionJSString;
    if (self.canScrollChangeSize) {
        injectionJSString = @"\
        \n var script = document.createElement('meta');\
        \n script.name = 'viewport';\
        \n script.content=\"width=device-width, initial-scale=1.0,maximum-scale=10.0, minimum-scale=0.0, user-scalable=no\";\
        \n document.getElementsByTagName('head')[0].appendChild(script);\
        \n ";
    } else {
        injectionJSString = @"\
        \n var script = document.createElement('meta');\
        \n script.name = 'viewport';\
        \n script.content=\"width=device-width, initial-scale=1.0,maximum-scale=1.0, minimum-scale=1.0, user-scalable=no\";\
        \n document.getElementsByTagName('head')[0].appendChild(script);\
        \n ";
    }
    [self runJavascript:injectionJSString
             completion:nil];
}

- (void)setBlock3DTouch:(BOOL)block3DTouch {
    _block3DTouch = block3DTouch;
    if (!T_IS_ABOVE_IOS(9)) {
        TLog(" block3DTouch 不支持iOS9以下机型");
        return;
    }
    self.wkWebView.allowsLinkPreview = !block3DTouch;
    // 不会走到UIWebView的allowsLinkPreview属性
}

- (void)setBlockTouchCallout:(BOOL)blockTouchCallout {
    _blockTouchCallout = blockTouchCallout;
    if (blockTouchCallout) {
        [self runJavascript:@"document.documentElement.style.webkitTouchCallout='none';"
                 completion:nil];
    } else {
        [self runJavascript:@"document.documentElement.style.webkitTouchCallout='inherit';"
                 completion:nil];
    }
}

- (WKProcessPool *)processPool {
    WKProcessPool *processPool = objc_getAssociatedObject([UIApplication sharedApplication], &WKWebViewProcessPoolKey);
    if (!processPool) {
        processPool = [[WKProcessPool alloc] init];
        objc_setAssociatedObject([UIApplication sharedApplication], &WKWebViewProcessPoolKey, processPool, OBJC_ASSOCIATION_RETAIN);
    }
    _processPool = processPool;
    return _processPool;
}

- (void)setShowProgress:(BOOL)showProgress {
    if (_showProgress == showProgress) {
        return;
    }
    
    if (showProgress == NO) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
        self.progressViewTopConstraint = nil;
        _showProgress = showProgress;
        return;
    }
    
    if (showProgress == YES && self.progressView == nil) {
        [self setUpProgressView];
        _showProgress = showProgress;
        return;
    }
}

- (BOOL)canGoBack {
    if (T_IS_ABOVE_IOS(8)) {
        return [_wkWebView canGoBack];
    } else {
        return [_uiWebView canGoBack];
    }
}

- (BOOL)canGoForward {
    if (T_IS_ABOVE_IOS(8)) {
        return [_wkWebView canGoForward];
    } else {
        return [_uiWebView canGoForward];
    }
}

- (BOOL)isLoading {
    if (T_IS_ABOVE_IOS(8)) {
        return [_wkWebView isLoading];
    } else {
        return [_uiWebView isLoading];
    }
}


#pragma mark - Create UI
- (void)setUI {
    UIView *webView;
    if (T_IS_ABOVE_IOS(8)) {
        [self setUpWKWebView];
        webView = _wkWebView;
    } else {
        [self setUpUIWebView];
        webView = _uiWebView;
    }
    
    [self addSubview:webView];
    [webView twv_makeConstraint:Top equealTo:self];
    [webView twv_makeConstraint:Left equealTo:self];
    [webView twv_makeConstraint:Right equealTo:self];
    [webView twv_makeConstraint:Bottom equealTo:self];
    
    [self setUpProgressView];
    
    [self resetCookieForceOverride:_forceOverrideCookie];
}

- (void)setUpWKWebView {
    self.wkWebView = ({
        // 设置cookie
        WKUserContentController *userContentController = [[WKUserContentController alloc] init];
        NSString *cookieJS = [self getSetCookieJSCodeWithForceOverride:_forceOverrideCookie];
        WKUserScript *cookieInScript = [[WKUserScript alloc] initWithSource:cookieJS
                                                              injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                           forMainFrameOnly:NO];
        [userContentController addUserScript:cookieInScript];
        
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = userContentController;
        config.processPool = self.processPool;
        WKWebView * webView = [[WKWebView alloc] initWithFrame:CGRectZero
                                                 configuration:config];
        webView.allowsBackForwardNavigationGestures = _canScrollBack;
        webView.allowsLinkPreview = !_block3DTouch;
        
        self.wkWebViewDelegate = [TWKWebViewDelegate getDelegateWith:self];
        webView.navigationDelegate = self.wkWebViewDelegate;
        webView.UIDelegate = self.wkWebViewDelegate;
        [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [webView addObserver:self forKeyPath:@"scrollView.contentInset" options:NSKeyValueObservingOptionNew context:nil];
        webView;
    });
    [self insertSubview:_wkWebView atIndex:0];
}

- (void)setUpUIWebView {
    self.uiWebView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        self.uiWebViewDelegate = [TUIWebViewDelegate getDelegateWith:self];
        webView.delegate = self.uiWebViewDelegate;
        [webView addObserver:self forKeyPath:@"scrollView.contentInset" options:NSKeyValueObservingOptionNew context:nil];
        webView;
    });
    [self insertSubview:_uiWebView atIndex:0];
}

- (void)setUpProgressView {
    if (self.progressView != nil) {
        return;
    }
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.progressTintColor = _progressTintColor;
    self.progressView.trackTintColor = [UIColor whiteColor];
    
    [self addSubview:self.progressView];
    self.progressViewTopConstraint = [self.progressView twv_makeConstraint:Top equealTo:self];
    [self.progressView twv_makeConstraint:Left equealTo:self];
    [self.progressView twv_makeConstraint:Right equealTo:self];
    [self.progressView twv_makeConstraint:Height is:2];
}

- (void)safeAreaInsetsDidChange {
    [self resetProgressViewTopInsert];
}

- (CGFloat)getTopInset {
#ifdef __IPHONE_11_0
    if (@available(iOS 11.0, *)) {
        CGFloat safeTop = self.safeAreaInsets.top;
        CGFloat scrollViewContentTop = self.wkWebView.scrollView.contentInset.top;
        return (safeTop + scrollViewContentTop);
    }
#endif
    if (T_IS_ABOVE_IOS(8)) {
        return self.wkWebView.scrollView.contentInset.top;
    } else {
        return self.uiWebView.scrollView.contentInset.top;
    }
}

- (void)resetProgressViewTopInsert {
    CGFloat constant = [self getTopInset];
    self.progressViewTopConstraint.constant = constant;
}


#pragma mark - Function
- (void)reload {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView reload];
    } else {
        [_uiWebView reload];
    }
}

- (void)stopLoading {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView stopLoading];
    } else {
        [_uiWebView stopLoading];
    }
}

- (void)goBack {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView goBack];
    } else {
        [_uiWebView goBack];
    }
}

- (void)goForward {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView goForward];
    } else {
        [_uiWebView goForward];
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView loadRequest:request];
    } else {
        [_uiWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView loadHTMLString:string baseURL:baseURL];
    } else {
        [_uiWebView loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL {
    if (T_IS_ABOVE_IOS(9)) {
        [_wkWebView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    } else if (!T_IS_ABOVE_IOS(8)){
        [_uiWebView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    } else {
        TLog(@"iOS8不可使用本方法，支持9.0以上或者8.0以下（不包含8.0）");
    }
}

- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    if (T_IS_ABOVE_IOS(9)) {
        return [self.wkWebView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
    } else {
        TLog(@"支持9.0以上");
        return nil;
    }
}

- (void)resetCookieForceOverride:(BOOL)forceOverride {
    [self runJavascript:[self getSetCookieJSCodeWithForceOverride:forceOverride]
             completion:^(id obj, NSError *error) {
                 TLog(@"重设cookie成功");
             }];
}


- (void)getDocumentTitle:(void (^)(NSString * _Nullable))completion {
    [self runJavascript:@"document.title" completion:^(id _Nullable obj, NSError * _Nullable error) {
        if (error != nil) {
            TLog(@"%@", error);
        }
        if ([obj isKindOfClass:[NSString class]]) {
            completion((NSString *)obj);
        } else {
            completion(nil);
        }
    }];
}
#pragma mark - Get Delegate
- (nullable id<TWebViewDelegate>)getDelegateWithSEL:(SEL)sel {
    if ([self.delegate respondsToSelector:sel]) {
        return self.delegate;
    } else if ([self.commonDelegate respondsToSelector:sel]) {
        return self.commonDelegate;
    }
    return nil;
}

#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"scrollView.contentInset"]) {
        [self resetProgressViewTopInsert];
    }
    
    if (object == self.wkWebView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            double newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            [self setProgress:newprogress animated:YES];
        }
        
        if ([keyPath isEqualToString:@"title"]) {
            NSString *newTitle = [change objectForKey:NSKeyValueChangeNewKey];
            id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
            [delegate webView:self
                   loadStatus:TWebViewLoadStatusSuccess
                        title:isEmptyString(newTitle) ? self.successDefaultTitle : newTitle];
        }
    }
}


#pragma mark - ProgressView
- (void)setProgress:(double)progress
           animated:(BOOL)animated {
    if (!self.isShowProgress) {
        return;
    }
    
    if (progress == 1) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:1 animated:animated];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        });
    } else if (progress == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    } else {
        self.progressView.hidden = NO;
        [self.progressView setProgress:progress animated:animated];
    }
}


#pragma mark - Cookie & JS
- (void)clearCache {
    NSString *iosVer;
    __block NSString *ms = @"清除列表:\n";
    if (T_IS_ABOVE_IOS(9)) {
        iosVer = @"iOS 9+";
        @tweakify(self);
        WKWebsiteDataStore *dateStore = [WKWebsiteDataStore defaultDataStore];
        [dateStore fetchDataRecordsOfTypes:[WKWebsiteDataStore allWebsiteDataTypes]
                         completionHandler:^(NSArray<WKWebsiteDataRecord *> * __nonnull records) {
                             @tstrongify(self);
                             for (WKWebsiteDataRecord *record  in records) {
                                 //取消备注，可以针对某域名清除，否则是全清
                                 //if (![record.displayName containsString:@"baidu"]) {
                                 //    continue;
                                 //}
                                 ms = [ms stringByAppendingString:[NSString stringWithFormat:@"%@\n", record.displayName]];
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                           forDataRecords:@[record]
                                                                        completionHandler:^{
                                                                            TLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                        }];
                             }
                             [self showPrompt:[NSString stringWithFormat:@"%@:%@", @"清除成功", iosVer]
                                      message:ms];
                         }];
    } else if (T_IS_ABOVE_IOS(8)){
        iosVer = @"iOS 8";
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath
                                                   error:&error];
        if (error != nil) {
            TLog(@"%@", error);
        }
        ms = [ms stringByAppendingString:cookiesFolderPath];
        [self showPrompt:[NSString stringWithFormat:@"%@:%@", @"清除成功", iosVer]
                 message:ms];
    } else {
        // ios 7
        iosVer = @"iOS 7";
        ms = [ms stringByAppendingString:[NSString stringWithFormat:@"[[NSURLCache sharedURLCache] removeAllCachedResponses]\ncookies:\n"]];
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]) {
            ms = [ms stringByAppendingString:[NSString stringWithFormat:@"%@\n", cookie.name]];
            [storage deleteCookie:cookie];
        }
        [[NSURLCache sharedURLCache] removeAllCachedResponses];//清除缓存
        [self showPrompt:[NSString stringWithFormat:@"%@:%@", @"清除成功", iosVer]
                 message:ms];
    }
}

- (void)showPrompt:(NSString *)title message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        // 弹出提示
        if (T_IS_ABOVE_IOS(8)) {
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:title
                                                                        message:message
                                                                 preferredStyle:UIAlertControllerStyleAlert];
            [ac addAction:[UIAlertAction actionWithTitle:@"确定"
                                                   style:UIAlertActionStyleCancel
                                                 handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                            message:message
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    });
}

- (NSString *)getSetCookieJSCodeWithForceOverride:(BOOL)forceOverride {
    // 取出cookie
    // js函数,如果需要比较，不进行强制覆盖cookie，使用注释掉的js函数
    NSString *JSFuncString;
    if (forceOverride) {
        JSFuncString = @"";
    } else {
        JSFuncString =
        @"\
        \n var cookieNames = document.cookie.split('; ').map(function(cookie) {\
        \n     return cookie.split('=')[0] \
        \n });\
        \n";
    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [cookieStorage cookies];//ForURL:[NSURL URLWithString:domain]];
    //拼凑js字符串
    NSMutableString *JSCode = [JSFuncString mutableCopy];
    for (NSHTTPCookie *cookie in cookies) {
        NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                            cookie.name,
                            cookie.value,
                            cookie.domain,
                            cookie.path ?: @"/"];
        
        if (cookie.secure) {
            string = [string stringByAppendingString:@";secure=true"];
        }
        NSString *setCookieString = nil;
        if (forceOverride) {
            setCookieString = [NSString stringWithFormat:
                               @"\
                               \n document.cookie='%@';\
                               \n", string];
        } else {
            setCookieString = [NSString stringWithFormat:
                               @"\
                               \n if (cookieNames.indexOf('%@') == -1) {\
                               \n     document.cookie='%@';\
                               \n };\
                               \n", cookie.name, string];
        }
        [JSCode appendString:setCookieString];
    }
    return JSCode;
}

+ (nullable NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data {
    if (function == nil) {
        return nil;
    }
    
    NSString *dataJsonString = @"";
    if (data != nil) {
        if ([NSJSONSerialization isValidJSONObject:data]) {
            NSError *error;
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                               options:0
                                                                 error: &error];
            if (error != nil) {
                TLog(@"%@", error);
            }
            dataJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else if ([data isKindOfClass:[NSString class]]) {
            dataJsonString = [NSString stringWithFormat:@"'%@'", data];
        }
    }
    NSString *jsString = [NSString stringWithFormat:@"%@(%@);", function, dataJsonString];
    return jsString;
}

- (void)runJavascript:(NSString *)js completion:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completion {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView evaluateJavaScript:js completionHandler:completion];
    } else {
        NSString *resultString = [_uiWebView stringByEvaluatingJavaScriptFromString:js];
        if (completion != nil) {
            if (resultString) {
                completion(resultString, nil);
            } else {
                NSDictionary *errorDict = @{@"WebViewType":@"UIWebView",
                                            @"WebView":self,
                                            @"ErrorJSString":js};
                NSError *jsError = [NSError errorWithDomain:@"Result_NULL" code:-1 userInfo:errorDict];
                if (jsError != nil) {
                    TLog(@"%@", jsError);
                }
                completion(nil, jsError);
            }
        }
    }
}

@end

