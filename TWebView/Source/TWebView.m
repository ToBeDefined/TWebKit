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
/**
 
 // WKWebView
 // 页面开始加载时调用
 - (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation;
 // 当内容开始返回时调用
 -(void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation*)navigation;
 // 页面加载完成之后调用
 - (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation;
 // 页面加载失败时调用
 - (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation;
 // 接收到服务器跳转请求之后调用
 - (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation;
 // 在收到响应后，决定是否跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;
 // 在发送请求之前，决定是否跳转
 - (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;
 */


#import <WebKit/WebKit.h>
#import <objc/runtime.h>
#import "TWebView.h"
#import "TWebViewConfig.h"

static const NSString * WKWebViewProcessPoolKey = @"WKWebViewProcessPoolKey";


//NSString *self.lodingDefaultTitle       = @"加载中...";
//NSString *self.failedDefaultTitle         = @"加载失败";
//NSString *self.successDefaultTitle = @"详情";

//static const NSString *TWebViewDelegateKey = @"TWebViewDelegateKey";

const float WebViewInitialProgressValue = 0.1f;
const float WebViewInteractiveProgressValue = 0.5f;
const float WebViewFinalProgressValue = 0.9f;

@interface TWebView() <UIWebViewDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *wkWebView NS_AVAILABLE(10_10, 8_0);
@property (nonatomic, strong) WKProcessPool *processPool;

@property (nonatomic, strong) UIWebView *uiWebView;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign, getter=isShowProgress) BOOL showProgress;
@property (nonatomic, readonly) float progress; // 0.0..1.0
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, assign) BOOL forceOverrideCookie;

@property (nonatomic, copy) NSString *confirmTitle;
@property (nonatomic, copy) NSString *cancelTitle;
@property (nonatomic, copy) NSString *lodingDefaultTitle;
@property (nonatomic, copy) NSString *successDefaultTitle;
@property (nonatomic, copy) NSString *failedDefaultTitle;

@end

@implementation TWebView
{
    NSUInteger _loadingCount;
    NSUInteger _maxLoadCount;
    NSURL *_currentURL;
    BOOL _interactive;
}

- (void)dealloc {
    if (T_IS_ABOVE_IOS(8)) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [self.wkWebView removeObserver:self forKeyPath:@"title"];
    }
}

- (instancetype)initWithConfig:(TWebViewConfig *)config {
    self = [super init];
    if (self) {
        self.commonDelegate = config.commonDelegate;
        self.delegate = config.delegate;
        self.forceOverrideCookie = config.forceOverrideCookie;
        self.showProgress = config.showProgressView;
        self.progressTintColor = config.progressTintColor;
        self.confirmTitle = config.confirmTitle;
        self.cancelTitle = config.cancelTitle;
        self.lodingDefaultTitle = config.lodingDefaultTitle;
        self.successDefaultTitle = config.successDefaultTitle;
        self.failedDefaultTitle = config.failedDefaultTitle;
        [self setUI];
    }
    return self;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
        self.commonDelegate = nil;
        self.delegate = nil;
        self.forceOverrideCookie = YES;
        self.showProgress = YES;
        self.progressTintColor = [UIColor blueColor];
        self.confirmTitle = @"OK";
        self.cancelTitle = @"Cancel";
        self.lodingDefaultTitle = @"Loding...";
        self.successDefaultTitle = @"Details";
        self.failedDefaultTitle = @"Failed";
        [self setUI];
    }
    return self;
}

- (void)setUI {
    
    UIView *webView;
    if (T_IS_ABOVE_IOS(8)) {
        self.wkWebView = ({
            // 设置cookie
            WKUserContentController *userContentController = [[WKUserContentController alloc] init];
            NSString *js = [self getSetCookieJSCodeWithForceOverride:_forceOverrideCookie];
            WKUserScript *cookieInScript = [[WKUserScript alloc] initWithSource:js
                                                                  injectionTime:WKUserScriptInjectionTimeAtDocumentStart
                                                               forMainFrameOnly:NO];
            [userContentController addUserScript:cookieInScript];
            WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
            config.userContentController = userContentController;
            config.processPool = self.processPool;
            
            WKWebView * webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
            webView.navigationDelegate = self;
            webView.UIDelegate = self;
            [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
            [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
            webView;
        });
        webView = _wkWebView;
        [self insertSubview:_wkWebView belowSubview:_progressView];
    } else {
        self.uiWebView = ({
            UIWebView *webView = [[UIWebView alloc] init];
            webView.delegate = self;
            webView;
        });
        webView = _uiWebView;
        [self insertSubview:_uiWebView belowSubview:_progressView];
    }
    
    [self addSubview:webView];
    [self layoutWebView:webView];
    
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.progressTintColor = _progressTintColor;
    self.progressView.trackTintColor = [UIColor whiteColor];
    
    [self addSubview:self.progressView];
    [self layoutProgressView:self.progressView];
    
    [self resetCookieForceOverride:_forceOverrideCookie];
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

- (NSString *)getSetCookieJSCodeWithForceOverride:(BOOL)forceOverride {
    
    //取出cookie
    //js函数,如果需要比较，不进行强制覆盖cookie，使用注释掉的js函数
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

- (void)layoutSubviews {
    [super layoutSubviews];
}


#pragma mark - SETTER/GETTER

- (void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    if (showProgress == NO) {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
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
    
    NSMutableURLRequest *request_M = [request mutableCopy];
    //    [request_M setValue:[WRequest getJsessionIDAndPath] forHTTPHeaderField:@"Cookie"];
    //    [request_M setHTTPShouldHandleCookies:YES];
    self.request = request_M;
    
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView stopLoading];
        [_wkWebView loadRequest:request_M];
    } else {
        [_uiWebView stopLoading];
        [_uiWebView loadRequest:request_M];
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
        NSLog(@"iOS8不可使用本方法，支持9.0以上或者8.0以下（不包含8.0）");
    }
}

- (WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    if (T_IS_ABOVE_IOS(9)) {
        return [self.wkWebView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
    } else {
        NSLog(@"支持9.0以上");
        return nil;
    }
}

- (void)resetCookieForceOverride:(BOOL)forceOverride {
    [self runJavascriptString:[self getSetCookieJSCodeWithForceOverride:forceOverride]
            completionHandler:^(id obj, NSError *error) {
                TLog(@"重设cookie成功");
            }];
}

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
                                 //                                 if ( [record.displayName containsString:@"baidu"]) {
                                 ms = [ms stringByAppendingString:[NSString stringWithFormat:@"%@\n", record.displayName]];
                                 [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:record.dataTypes
                                                                           forDataRecords:@[record]
                                                                        completionHandler:^{
                                                                            NSLog(@"Cookies for %@ deleted successfully",record.displayName);
                                                                        }];
                                 //                                 }
                             }
                             [self showPrompt:[NSString stringWithFormat:@"%@:%@", @"清除成功", iosVer]
                                      message:ms];
                         }];
    } else if (T_IS_ABOVE_IOS(8)){
        iosVer = @"iOS 8";
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
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

#pragma mark - Observe & GetDelegate
- (id<TWebViewDelegate>)getDelegateWithSEL:(SEL)sel {
    if ([self.delegate respondsToSelector:sel]) {
        return self.delegate;
    } else if ([self.commonDelegate respondsToSelector:sel]) {
        return self.commonDelegate;
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.wkWebView) {
        if ([keyPath isEqualToString:@"estimatedProgress"]) {
            double newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
            [self setProgressView:self.progressView progress:newprogress animated:YES];
        }
        
        if ([keyPath isEqualToString:@"title"]) {
            NSString *newTitle = [change objectForKey:NSKeyValueChangeNewKey];
            id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
            [delegate webView:self
                   loadStatus:TWebViewLoadStatusSuccess
                        title:isNotEmptyString(newTitle) ? newTitle : self.successDefaultTitle];
        }
    }
}


#pragma mark - ProgressView
- (void)setProgressView:(UIProgressView *)progressView progress:(double)progress animated:(BOOL)animated{
    if (self.isShowProgress == NO) {
        return;
    }
    
    if (progress == 1) {
        self.progressView.hidden = NO;
        [self.progressView setProgress:1 animated:animated];
        @tweakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @tstrongify(self);
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


#pragma mark - UIWebViewProgress
- (void)incrementProgress {
    float progress = self.progress;
    float maxProgress = _interactive ? WebViewFinalProgressValue : WebViewInteractiveProgressValue;
    float remainPercent = (float)_loadingCount / (float)_maxLoadCount;
    float increment = (maxProgress - progress) * remainPercent;
    progress += increment;
    progress = fmin(progress, maxProgress);
    [self setProgress:progress];
}

- (void)reset {
    _maxLoadCount = _loadingCount = 0;
    _interactive = NO;
    [self setProgress:0.0];
}

- (void)completeProgress {
    [self setProgress:1.0];
}

- (void)startProgress {
    if (_progress < WebViewInitialProgressValue) {
        [self setProgress:WebViewInitialProgressValue];
    }
}

- (void)setProgress:(float)progress {
    // progress should be incremental only
    if (progress > _progress || progress == 0) {
        _progress = progress;
        [self setProgressView:_progressView progress:progress animated:YES];
    }
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    self.request = request;
    
    if ([request.URL.absoluteString isEqualToString:@"webviewprogress:///complete"]) {
        [self completeProgress];
        return NO;
    }
    
    BOOL ret = YES;
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    ret = [delegate webView:self shouldStartLoadRequest:self.request];
    
    BOOL isFragmentJump = NO;
    if (request.URL.fragment) {
        NSString *nonFragmentURL = [request.URL.absoluteString stringByReplacingOccurrencesOfString:[@"#" stringByAppendingString:request.URL.fragment] withString:@""];
        isFragmentJump = [nonFragmentURL isEqualToString:webView.request.URL.absoluteString];
    }
    
    BOOL isTopLevelNavigation = [request.mainDocumentURL isEqual:request.URL];
    
    BOOL isHTTP = [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
    if (ret && !isFragmentJump && isHTTP && isTopLevelNavigation) {
        _currentURL = request.URL;
        [self reset];
    }
    return ret;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self didStartLoadRequest:self.request];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self
           loadStatus:TWebViewLoadStatusIsLoding
                title:self.lodingDefaultTitle];
    
    ++ _loadingCount;
    _maxLoadCount = fmax(_maxLoadCount, _loadingCount);
    [self startProgress];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self didFinishLoadRequest:self.request];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    @tweakify(self)
    [self runJavascriptString:@"document.title" completionHandler:^(id _Nullable obj, NSError * _Nullable error) {
        @tstrongify(self)
        NSString *title = obj;
        title = isNotEmptyString(title) ? title : self.successDefaultTitle;
        [delegate webView:self
               loadStatus:TWebViewLoadStatusSuccess
                    title:title];
    }];
    
    [self reduceLoadingCount];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self didFailedLoadRequest:self.request withError:error];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self loadStatus:TWebViewLoadStatusFailed title:self.failedDefaultTitle];
    
    [self reduceLoadingCount];
}

- (void)reduceLoadingCount {
    --_loadingCount;
    [self incrementProgress];
    
    NSString *readyState = [self.uiWebView stringByEvaluatingJavaScriptFromString:@"document.readyState"];
    
    BOOL interactive = [readyState isEqualToString:@"interactive"];
    if (interactive) {
        _interactive = YES;
        NSString *waitForCompleteJS = [NSString stringWithFormat:@"\
                                       \nwindow.addEventListener('load', function() {\
                                       \n    var iframe = document.createElement('iframe');\
                                       \n    iframe.style.display = 'none'; iframe.src = '%@';\
                                       \n    document.body.appendChild(iframe);\
                                       \n}, false);\
                                       \n", @"webviewprogress:///complete"];
        [self.uiWebView stringByEvaluatingJavaScriptFromString:waitForCompleteJS];
    }
    
    BOOL isNotRedirect = _currentURL && [_currentURL isEqual:self.uiWebView.request.mainDocumentURL];
    BOOL complete = [readyState isEqualToString:@"complete"];
    if (complete && isNotRedirect) {
        [self completeProgress];
    }
}


#pragma mark - WKNavigationDelegate

// 相当于 - webView:shouldStartLoadWithRequest:navigationType:
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    self.request = navigationAction.request;
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:shouldStartLoadRequest:)];
    if (delegate != nil) {
        BOOL isCanLoad = [delegate webView:self shouldStartLoadRequest:navigationAction.request];
        if (!isCanLoad) {
            decisionHandler(WKNavigationActionPolicyCancel);
            return;
        }
    }
    
    //    if (!navigationAction.targetFrame.isMainFrame) {
    //        //如果是跳转一个新页面 (防止<a href = "xxx" target = "_black">连接不跳转)
    //        [webView loadRequest:navigationAction.request];
    //    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didStartLoadRequest:)];
    [delegate webView:self didStartLoadRequest:self.request];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self loadStatus:TWebViewLoadStatusIsLoding title:self.lodingDefaultTitle];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didFinishLoadRequest:)];
    [delegate webView:self didFinishLoadRequest:self.request];
}


- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self didFailedLoadRequest:self.request withError:error];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self loadStatus:TWebViewLoadStatusFailed title:self.failedDefaultTitle];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    id<TWebViewDelegate> delegate = [self getDelegateWithSEL:@selector(webView:didFailedLoadRequest:withError:)];
    [delegate webView:self didFailedLoadRequest:self.request withError:error];
    
    delegate = [self getDelegateWithSEL:@selector(webView:loadStatus:title:)];
    [delegate webView:self loadStatus:TWebViewLoadStatusFailed title:self.failedDefaultTitle];
}


#pragma mark - WKUIDelegate
// 一定是iOS8才会运行到此，使用UIAlertController
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler();
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:message
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addAction:[UIAlertAction actionWithTitle:@"确定"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(YES);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"取消"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction * _Nonnull action) {
                                             completionHandler(NO);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:webView.title
                                                                message:prompt
                                                         preferredStyle:UIAlertControllerStyleAlert];
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    
    [ac addAction:[UIAlertAction actionWithTitle: @"确定"
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             NSString *input = ((UITextField *)ac.textFields.firstObject).text;
                                             completionHandler(input);
                                         }]];
    [ac addAction:[UIAlertAction actionWithTitle: @"取消"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             completionHandler(nil);
                                         }]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
}


-(WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

#pragma mark - About Javascript Function

+ (NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data {
    if (function == nil) {
        return nil;
    }
    
    NSString *dataJsonString = @"";
    if (data != nil) {
        if ([NSJSONSerialization isValidJSONObject:data]) {
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
            dataJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        } else if ([data isKindOfClass:[NSString class]]) {
            dataJsonString = [NSString stringWithFormat:@"'%@'", data];
        }
    }
    NSString *jsString = [NSString stringWithFormat:@"%@(%@);", function, dataJsonString];
    return jsString;
}

- (void)runJavascriptString:(NSString *)js completionHandler:(void (^)(id obj, NSError *error))completionHandler {
    if (T_IS_ABOVE_IOS(8)) {
        [_wkWebView evaluateJavaScript:js completionHandler:completionHandler];
    } else {
        NSString *resultString = [_uiWebView stringByEvaluatingJavaScriptFromString:js];
        if (completionHandler != nil) {
            if (resultString) {
                completionHandler(resultString, nil);
            } else {
                NSDictionary *errorDict = @{@"WebViewType":@"UIWebView",
                                            @"WebView":self,
                                            @"ErrorJSString":js};
                NSError *jsError = [NSError errorWithDomain:@"Result_NULL" code:-1 userInfo:errorDict];
                completionHandler(nil, jsError);
            }
            
        }
    }
}


#pragma mark Layout
- (void)layoutWebView:(UIView *)webView {
    
    [NSLayoutConstraint constraintWithItem:webView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:webView
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:webView
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:webView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeBottom
                                multiplier:1.0
                                  constant:0];
}

- (void)layoutProgressView:(UIProgressView *)progressView {
    
    [NSLayoutConstraint constraintWithItem:progressView
                                 attribute:NSLayoutAttributeTop
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeTop
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:progressView
                                 attribute:NSLayoutAttributeLeft
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeLeft
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:progressView
                                 attribute:NSLayoutAttributeRight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:self
                                 attribute:NSLayoutAttributeRight
                                multiplier:1.0
                                  constant:0];
    
    [NSLayoutConstraint constraintWithItem:progressView
                                 attribute:NSLayoutAttributeHeight
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:nil
                                 attribute:NSLayoutAttributeNotAnAttribute
                                multiplier:1.0
                                  constant:2.0];
}

@end

