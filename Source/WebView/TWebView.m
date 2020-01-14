//
//  TWebView.m
//  TWebView
//
//  Created by TBD on 2017/7/22.
//  Copyright © 2017年 TBD. All rights reserved.
//


#import "TDefineAndCFunc.h"
#import "TWebView.h"
#import <objc/runtime.h>

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

@interface TWebView()

@property (nonatomic, strong) WKProcessPool *processPool;

@property (nonatomic, strong) TWKWebViewDelegate *wkWebViewDelegate;
@property (nonatomic, strong) TUIWebViewDelegate *uiWebViewDelegate;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, weak) NSLayoutConstraint *progressViewTopConstraint;
@property (nonatomic, weak) NSLayoutConstraint *progressViewHeightConstraint;

@end

@implementation TWebView

#pragma mark - Memory
- (void)dealloc {
    if (@available(iOS 8, *)) {
        [_wkWebView stopLoading];
        _wkWebView.UIDelegate = nil;
        _wkWebView.navigationDelegate = nil;
        [_wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_wkWebView removeObserver:self forKeyPath:@"title"];
        [_wkWebView removeObserver:self forKeyPath:@"scrollView.contentInset"];
    } else {
        [_uiWebView stopLoading];
        _uiWebView.delegate = nil;
        [_uiWebView removeObserver:self forKeyPath:@"scrollView.contentInset"];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

#pragma mark - Init
- (instancetype)initWithConfig:(TWebViewConfig *)config
                         frame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _commonDelegate         = config.webViewCommonDelegate;
        _delegate               = config.webViewDelegate;
        _forceOverrideCookie    = config.forceOverrideCookie;
        _showProgress           = config.showProgressView;
        _progressTintColor      = config.progressTintColor;
        _progressViewHeight     = config.progressViewHeight;
        
        _canSelectContent       = config.canSelectContent;
        _canScrollChangeSize    = config.canScrollChangeSize;
        _blockTouchCallout      = config.blockTouchCallout;
        _canScrollBack          = config.canScrollBack;
        if (@available(iOS 9, *)) {
            _block3DTouch       = config.block3DTouch;
        }
        _confirmText            = config.confirmText;
        _cancelText             = config.cancelText;
        _loadingDefaultTitle    = config.loadingDefaultTitle;
        _successDefaultTitle    = config.successDefaultTitle;
        _failedDefaultTitle     = config.failedDefaultTitle;
        
        [self setUI];
    }
    return self;
}

- (instancetype)initWithConfig:(TWebViewConfig *)config {
    return [self initWithConfig:config frame:CGRectZero];
}

- (instancetype)init {
    TWebViewConfig *config = [TWebViewConfig defaultConfig];
    return [self initWithConfig:config frame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    TWebViewConfig *config = [TWebViewConfig defaultConfig];
    return [self initWithConfig:config frame:frame];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self != nil) {
        TWebViewConfig *config  = [TWebViewConfig defaultConfig];
        _commonDelegate         = config.webViewCommonDelegate;
        _delegate               = config.webViewDelegate;
        _forceOverrideCookie    = config.forceOverrideCookie;
        _showProgress           = config.showProgressView;
        _progressTintColor      = config.progressTintColor;
        _progressViewHeight     = config.progressViewHeight;
        
        _canSelectContent       = config.canSelectContent;
        _canScrollChangeSize    = config.canScrollChangeSize;
        _blockTouchCallout      = config.blockTouchCallout;
        _canScrollBack          = config.canScrollBack;
        if (@available(iOS 9.0, *)) {
            _block3DTouch           = config.block3DTouch;
        }
        
        _confirmText            = config.confirmText;
        _cancelText             = config.cancelText;
        _loadingDefaultTitle    = config.loadingDefaultTitle;
        _successDefaultTitle    = config.successDefaultTitle;
        _failedDefaultTitle     = config.failedDefaultTitle;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setUI];
}


#if TARGET_INTERFACE_BUILDER
- (void)drawRect:(CGRect)rect {
    UIColor *backgroundColor = self.backgroundColor;
    if (CGColorEqualToColor([UIColor whiteColor].CGColor, backgroundColor.CGColor)) {
        backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    }
    CALayer *backgroundLayer = [[CALayer alloc] init];
    backgroundLayer.backgroundColor = backgroundColor.CGColor;
    backgroundLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    [self.layer addSublayer:backgroundLayer];
    
    CATextLayer *textLayer = [[CATextLayer alloc] init];
    [textLayer setFont:@"Helvetica-Bold"];
    [textLayer setFontSize:40];
    textLayer.contentsScale = 3;
    CGFloat fontSize = textLayer.fontSize;
    CGFloat height = rect.size.height;
    CGFloat deltaY = (height-fontSize)/2 - fontSize/10;
    CGRect textLayerFrame = CGRectMake(0, deltaY, rect.size.width, fontSize * 1.5);
    textLayer.frame = textLayerFrame;
    textLayer.string = @"TWebView";
    textLayer.alignmentMode = kCAAlignmentCenter;
    UIColor *foregroundColor = [UIColor lightGrayColor];
    if (CGColorEqualToColor(foregroundColor.CGColor, backgroundColor.CGColor)) {
        foregroundColor = [UIColor darkGrayColor];
    }
    textLayer.foregroundColor = foregroundColor.CGColor;
    textLayer.backgroundColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:textLayer];
    
    if (_showProgress) {
        CALayer *progressLayer = [[CALayer alloc] init];
        progressLayer.frame = CGRectMake(0, 0, rect.size.width*0.6, self.progressViewHeight);
        progressLayer.backgroundColor = self.progressTintColor.CGColor;
        [self.layer addSublayer:progressLayer];
    }
    
    [super drawRect:rect];
}
#endif



#pragma mark - Setter/Getter
- (void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    self.progressView.hidden = !showProgress;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    _progressTintColor = progressTintColor;
    self.progressView.progressTintColor = progressTintColor;
}

- (void)setProgressViewHeight:(CGFloat)progressViewHeight {
    _progressViewHeight = progressViewHeight;
    self.progressViewHeightConstraint.constant = progressViewHeight;
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
    if (@available(iOS 8, *)) {
        _wkWebView.allowsBackForwardNavigationGestures = _canScrollBack;
    } else {
        TLog(" canScrollBack 不支持iOS8以下机型");
    }
    
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
    if (@available(iOS 9, *)) {
        // 不会走到UIWebView的allowsLinkPreview属性
        _wkWebView.allowsLinkPreview = !block3DTouch;
    } else {
        TLog(" block3DTouch 不支持iOS9以下机型");
    }
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

- (UIView *)contentWebView {
    if (@available(iOS 8, *)) {
        return _wkWebView;
    } else {
        return _uiWebView;
    }
}

- (UIScrollView *)scrollView {
    if (@available(iOS 8, *)) {
        return [_wkWebView scrollView];
    } else {
        return [_uiWebView scrollView];
    }
}

- (BOOL)canGoBack {
    if (@available(iOS 8, *)) {
        return [_wkWebView canGoBack];
    } else {
        return [_uiWebView canGoBack];
    }
}

- (BOOL)canGoForward {
    if (@available(iOS 8, *)) {
        return [_wkWebView canGoForward];
    } else {
        return [_uiWebView canGoForward];
    }
}

- (BOOL)isLoading {
    if (@available(iOS 8, *)) {
        return [_wkWebView isLoading];
    } else {
        return [_uiWebView isLoading];
    }
}


#pragma mark - Create UI
- (void)setUI {
    UIView *webView;
    if (@available(iOS 8, *)) {
        [self setupWKWebView];
        webView = _wkWebView;
    } else {
        [self setupUIWebView];
        webView = _uiWebView;
    }
    self.layer.masksToBounds = YES;
    
    [self addSubview:webView];
    [webView twv_makeConstraint:Top equealTo:self];
    [webView twv_makeConstraint:Left equealTo:self];
    [webView twv_makeConstraint:Right equealTo:self];
    [webView twv_makeConstraint:Bottom equealTo:self];
    
    [self setupProgressView];
    
    [self resetCookieForceOverride:_forceOverrideCookie];
}

- (void)setupWKWebView {
    _wkWebView = ({
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
        if (@available(iOS 9, *)) {
            webView.allowsLinkPreview = !_block3DTouch;
        }
        self.wkWebViewDelegate = [TWKWebViewDelegate getDelegateWith:self];
        webView.navigationDelegate = self.wkWebViewDelegate;
        webView.UIDelegate = self.wkWebViewDelegate;
        webView.layer.masksToBounds = NO;
        webView.scrollView.layer.masksToBounds = NO;
        [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
        [webView addObserver:self forKeyPath:@"scrollView.contentInset" options:NSKeyValueObservingOptionNew context:nil];
        webView;
    });
}

- (void)setupUIWebView {
    _uiWebView = ({
        UIWebView *webView = [[UIWebView alloc] init];
        self.uiWebViewDelegate = [TUIWebViewDelegate getDelegateWith:self];
        webView.delegate = self.uiWebViewDelegate;
        webView.layer.masksToBounds = NO;
        webView.scrollView.layer.masksToBounds = NO;
        [webView addObserver:self forKeyPath:@"scrollView.contentInset" options:NSKeyValueObservingOptionNew context:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        webView;
    });
}

- (void)setupProgressView {
    if (self.progressView != nil) {
        return;
    }
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.progressTintColor = _progressTintColor;
    self.progressView.trackTintColor = [UIColor whiteColor];
    
    [self addSubview:self.progressView];
    
    self.progressViewTopConstraint =
    [self.progressView twv_makeConstraint:Top equealTo:self];
    [self.progressView twv_makeConstraint:Left equealTo:self];
    [self.progressView twv_makeConstraint:Right equealTo:self];
    self.progressViewHeightConstraint =
    [self.progressView twv_makeConstraint:Height is:self.progressViewHeight];
    self.progressView.hidden = !self.isShowProgress;
}

- (void)safeAreaInsetsDidChange {
    [self resetProgressViewTopInsert];
}

- (CGFloat)getTopInset {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets.top;
    } else if (@available(iOS 8, *)) {
        return _wkWebView.scrollView.contentInset.top;
    } else {
        return _uiWebView.scrollView.contentInset.top;
    }
}

- (void)resetProgressViewTopInsert {
    CGFloat constant = [self getTopInset];
    self.progressViewTopConstraint.constant = constant;
}


#pragma mark - OpenGL ES Crash
// OpenGL ES Crash: https://forums.developer.apple.com/thread/30896
- (void)appWillResignActive:(NSNotification *)notification {
    [self enableUIWebViewOpenGL:NO];
}

- (void)appDidBecomeActive:(NSNotification *)notification {
    [self enableUIWebViewOpenGL:YES];
}

typedef void (*CallFuc)(id, SEL, BOOL);
typedef BOOL (*GetFuc)(id, SEL);
- (BOOL)enableUIWebViewOpenGL:(BOOL)enableOpenGL {
    if (@available(iOS 8, *)) {
        return NO;
    } else {
        BOOL bRet = NO;
        do {
            Ivar internalVar = class_getInstanceVariable([_uiWebView class], "_internal");
            if (!internalVar) {
                TLog(@"enable GL _internal invalid!");
                break;
            }
            
            UIWebViewInternal *internalObj = object_getIvar(_uiWebView, internalVar);
            Ivar browserVar = class_getInstanceVariable(object_getClass(internalObj), "browserView");
            if (!browserVar) {
                TLog(@"enable GL browserView invalid!");
                break;
            }
            
            id webbrowser = object_getIvar(internalObj, browserVar);
            Ivar webViewVar = class_getInstanceVariable(object_getClass(webbrowser), "_webView");
            if (!webViewVar) {
                TLog(@"enable GL _webView invalid!");
                break;
            }
            
            id webView = object_getIvar(webbrowser, webViewVar);
            if (!webView) {
                TLog(@"enable GL webView obj nil!");
            }
            
            if(object_getClass(webView) != NSClassFromString(@"WebView")) {
                NSLog(@"enable GL webView not WebView!");
                break;
            }
            
            SEL selectorSet = NSSelectorFromString(@"_setWebGLEnabled:");
            IMP impSet = [webView methodForSelector:selectorSet];
            CallFuc funcSet = (CallFuc)impSet;
            funcSet(webView, selectorSet, enableOpenGL);
            
            SEL selectorGet = NSSelectorFromString(@"_webGLEnabled");
            IMP impGet = [webView methodForSelector:selectorGet];
            GetFuc funcGet = (GetFuc)impGet;
            BOOL val = funcGet(webView, selectorGet);
            
            bRet = (val == enableOpenGL);
            
        } while(NO);
        TLog(@"set: %@,  success: %@", enableOpenGL ? @"YES" : @"NO", bRet ? @"YES" : @"NO");
        return bRet;
    }
}


#pragma mark - Function
- (void)reload {
    if (@available(iOS 8, *)) {
        [_wkWebView reload];
    } else {
        [_uiWebView reload];
    }
}

- (void)stopLoading {
    if (@available(iOS 8, *)) {
        [_wkWebView stopLoading];
    } else {
        [_uiWebView stopLoading];
    }
}

- (void)goBack {
    if (@available(iOS 8, *)) {
        [_wkWebView goBack];
    } else {
        [_uiWebView goBack];
    }
}

- (void)goForward {
    if (@available(iOS 8, *)) {
        [_wkWebView goForward];
    } else {
        [_uiWebView goForward];
    }
}

- (void)loadRequest:(NSURLRequest *)request {
    if (@available(iOS 8, *)) {
        [_wkWebView loadRequest:request];
    } else {
        [_uiWebView loadRequest:request];
    }
}

- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL {
    if (@available(iOS 8, *)) {
        [_wkWebView loadHTMLString:string baseURL:baseURL];
    } else {
        [_uiWebView loadHTMLString:string baseURL:baseURL];
    }
}

- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL {
    if (@available(iOS 9, *)) {
        [_wkWebView loadData:data MIMEType:MIMEType characterEncodingName:textEncodingName baseURL:baseURL];
    } else if (@available(iOS 8, *)) {
        TLog(@"iOS8不可使用本方法，支持9.0以上或者8.0以下（不包含8.0）");
    } else {
        [_uiWebView loadData:data MIMEType:MIMEType textEncodingName:textEncodingName baseURL:baseURL];
    }
}

- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL {
    if (@available(iOS 9, *)) {
        return [_wkWebView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
    } else {
        TLog(@"支持9.0以上");
        return nil;
    }
}

- (void)loadLocalFileInPath:(NSString *)filePath {
    [self loadLocalFileInBasePath:filePath relativeFilePath:nil];
}

- (void)loadLocalFileInBasePath:(NSString *)basePath
               relativeFilePath:(nullable NSString *)relativeFilePath {
    NSString *realFilePath = basePath ?: @"";
    if (relativeFilePath) {
        realFilePath = [realFilePath stringByAppendingPathComponent:relativeFilePath];
    }
    NSURL *realFileURL = [NSURL fileURLWithPath:realFilePath];
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    if (!realFileURL) {
        return;
    }
    if (@available(iOS 9, *)) {
        [_wkWebView loadFileURL:realFileURL allowingReadAccessToURL:baseURL ?: realFileURL];
    } else if (@available(iOS 8, *)) {
        NSString *tmpBasePath = [self copyFilesFromBasePath:basePath ?: realFilePath];
        NSURL *tmpFileURL = [NSURL fileURLWithPath:tmpBasePath];
        if (relativeFilePath) {
            NSString *tmpFilePath = [tmpBasePath ?: @"" stringByAppendingPathComponent:relativeFilePath];
            tmpFileURL = [NSURL fileURLWithPath:tmpFilePath];
        }
        if (tmpFileURL) {
            [_wkWebView loadRequest:[NSURLRequest requestWithURL:tmpFileURL]];
        }
    } else {
        // is UIWebView
        [_uiWebView loadRequest:[NSURLRequest requestWithURL:realFileURL]];
    }
}

- (nullable NSString *)copyFilesFromBasePath:(NSString *)originBasePath {
    NSURL *originBaseURL = [NSURL fileURLWithPath:originBasePath];
    if (![originBaseURL isFileURL]) {
        NSAssert(NO, @"Its must a file url");
    }
    NSError *error;
    [originBaseURL checkResourceIsReachableAndReturnError:&error];
    if (error) {
        NSAssert(NO, @"Resource Is Unreachable");
    }
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tmpDirPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"wkWebViewTmpLocalFile"];
    NSURL *tmpDirURL = [NSURL fileURLWithPath:tmpDirPath];
    [fm createDirectoryAtURL:tmpDirURL withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSAssert(NO, @"Create Tmp Dir Error");
    }
    
    NSURL *dstURL = [tmpDirURL URLByAppendingPathComponent:originBaseURL.lastPathComponent];
    if ([fm fileExistsAtPath:dstURL.path]) {
        [fm removeItemAtURL:dstURL error:nil];
    }
    [fm copyItemAtURL:originBaseURL toURL:dstURL error:&error];
    if (error) {
        NSAssert(NO, @"Create Tmp Dir Error");
    }
    return dstURL.path;
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
    
    if (object == _wkWebView) {
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
    if (@available(iOS 9, *)) {
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
    } else if (@available(iOS 8, *)) {
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
        if (@available(iOS 8, *)) {
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
            if (jsonData) {
                dataJsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            }
        } else if ([data isKindOfClass:[NSString class]]) {
            dataJsonString = [NSString stringWithFormat:@"'%@'", data];
        }
    }
    NSString *jsString = [NSString stringWithFormat:@"%@(%@);", function, dataJsonString];
    return jsString;
}

- (void)runJavascript:(NSString *)js completion:(void (^ _Nullable)(id _Nullable, NSError * _Nullable))completion {
    if (@available(iOS 8, *)) {
        void (^completionBlock)(id _Nullable, NSError * _Nullable) = ^(id _Nullable obj, NSError * _Nullable error) {
            if (completion == nil) {
                return;
            }
            
            if (error != nil) {
                NSMutableDictionary *errorDict = [@{@"WebView":self,
                                                    @"WebViewType":@"WKWebView",
                                                    @"ErrorJSString":js} mutableCopy];
                [errorDict addEntriesFromDictionary:error.userInfo];
                
                NSError *jsError = [NSError errorWithDomain:error.domain
                                                       code:error.code
                                                   userInfo:errorDict];
                TLog(@"%@", jsError);
                completion(obj, jsError);
            } else {
                completion(obj, nil);
            }
        };
        
        [_wkWebView evaluateJavaScript:js
                     completionHandler:completionBlock];
    } else {
        NSString *resultString = [_uiWebView stringByEvaluatingJavaScriptFromString:js];
        if (completion == nil) {
            return;
        }
        
        if (resultString) {
            completion(resultString, nil);
        } else {
            NSDictionary *errorDict = @{@"WebView":self,
                                        @"WebViewType":@"UIWebView",
                                        @"ErrorJSString":js};
            NSError *jsError = [NSError errorWithDomain:@"Result_NULL"
                                                   code:-1
                                               userInfo:errorDict];
            TLog(@"%@", jsError);
            completion(nil, jsError);
        }
    }
}

@end

