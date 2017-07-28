//
//  TWebViewController.m
//  TWebView
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

#import <objc/runtime.h>
#import "TDefineAndCFunc.h"
#import "TWebViewController.h"
#import "TWebViewConfig.h"
#import "UIView+TWVLayout.h"
#import "TWebViewCommonDelegate.h"

static int AlertTagConfirmClearCache = 10001;
static int AlertTagInputURL          = 10002;
static int TextFieldTagInputURL      = 20002;

static NSString *T_TESTURL_LASTINPUTURL = @"T_TESTURL_LASTINPUTURL";
static NSString *TInputURLAlertView = @"TInputURLAlertView";

@interface TWebViewController () <TWebViewDelegate, UITextFieldDelegate>

@end

@implementation TWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        TWebViewConfig *config = [[TWebViewConfig alloc] init];
        config.commonDelegate = [TWebViewCommonDelegate sharedInstance];
        config.delegate = self;
        self.webView = [[TWebView alloc] initWithConfig:config];
    }
    return self;
}

- (instancetype)initWithConfig:(TWebViewConfig *)config {
    self = [super init];
    if (self) {
        self.webView = [[TWebView alloc] initWithConfig:config];
    }
    return self;
}

- (void)dealloc {
    objc_removeAssociatedObjects(self);
}

- (UIImage *)backImage {
    if (_backImage == nil) {
        NSString *path = [[NSBundle bundleForClass:[TWebViewController class]] pathForResource:@"TWebKit"
                                                                                        ofType:@".bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        UIImage *image = [UIImage imageWithContentsOfFile:[bundle pathForResource:@"back" ofType:@"png"]];
        UIImage *backImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _backImage = backImage;
    }
    return _backImage;
}

#pragma mark - LifeCyle Methods
- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:self.backImage
                                                                 style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(back)];
    self.navigationItem.leftBarButtonItems = @[backItem];
    
    [self.view addSubview:self.webView];
    self.navigationItem.title = self.navTitle;
    [self.webView twv_makeConstraint:Top equealTo:self.view];
    [self.webView twv_makeConstraint:Left equealTo:self.view];
    [self.webView twv_makeConstraint:Right equealTo:self.view];
    [self.webView twv_makeConstraint:Bottom equealTo:self.view];
    [self setupRightItems];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)loadURLFromString:(NSString *)urlString {
    urlString = trueURLString(urlString);
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
}

- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride {
    [self.webView resetCookieForceOverride:forceOverride];
}

- (void)back {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
        if (self.navigationItem.leftBarButtonItems.count < 2) {
            UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:self.backImage
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(back)];
            
            UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                       target:self
                                                                                       action:@selector(close)];;
            
            self.navigationItem.leftBarButtonItems = @[backItem, closeItem];
        }
        return;
    } else {
        [self close];
    }
}

- (void)close {
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}





#pragma mark - CommonWebViewDelegate
- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title {
    TLog(@"%@", title);
    if (!isNotEmptyString(self.navTitle)) {
        self.navigationItem.title = title;
    }
}


#pragma mark - DevTool

- (void)setupRightItems {
    NSMutableArray *item_array = [NSMutableArray array];
    #ifdef DEBUG
    UIBarButtonItem *itemCompose = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                 target:self
                                                                                 action:@selector(inputURL)];
    [item_array addObject:itemCompose];
    
    UIBarButtonItem *itemTrash = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:self
                                                                               action:@selector(confirmClearCache)];
    [item_array addObject:itemTrash];
    #endif
    
    [self.navigationItem setRightBarButtonItems:item_array animated:YES];
}


#pragma mark - Input URL & Clean
- (void)inputURL {
    if (T_IS_ABOVE_IOS(8)) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Input URL"
                                                                    message:@"Please Input URL:"
                                                             preferredStyle:UIAlertControllerStyleAlert];
        @tweakify(self);
        [ac addAction:[UIAlertAction actionWithTitle:@"Go"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 @tstrongify(self);
                                                 NSString *url = [ac.textFields objectAtIndex:0].text;
                                                 if (isNotEmptyString(url)) {
                                                     [[NSUserDefaults standardUserDefaults] setObject:url forKey:T_TESTURL_LASTINPUTURL];
                                                     [self loadURLFromString:url];
                                                 }
                                             }]];
        [ac addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                               style:UIAlertActionStyleCancel
                                             handler:nil]];
        
        [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:T_TESTURL_LASTINPUTURL];
            textField.text = url;
            textField.placeholder = @"Please Input URL.";
            textField.keyboardType = UIKeyboardTypeURL;
            textField.returnKeyType  = UIReturnKeyGo;
            textField.clearButtonMode = UITextFieldViewModeAlways;
        }];
        [self presentViewController:ac animated:YES completion:nil];
        
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Input URL"
                                                        message:@"Please Input URL:"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Go", nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = AlertTagInputURL;
        NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:T_TESTURL_LASTINPUTURL];
        UITextField *textField = [alert textFieldAtIndex:0];
        textField.tag = TextFieldTagInputURL;
        textField.text = url;
        textField.placeholder = @"Please Input URL:";
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType  = UIReturnKeyGo;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        textField.delegate = self;
        objc_setAssociatedObject(self, &TInputURLAlertView, alert, OBJC_ASSOCIATION_RETAIN);
        [alert show];
        
    }
}

- (void)confirmClearCache {
    if (T_IS_ABOVE_IOS(8)) {
        UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"Delete All Cache & Cookie？"
                                                                    message:nil
                                                             preferredStyle:UIAlertControllerStyleAlert];
        [ac addAction:[UIAlertAction actionWithTitle:@"NO"
                                               style:UIAlertActionStyleCancel
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 return;
                                             }]];
        
        @tweakify(self);
        [ac addAction:[UIAlertAction actionWithTitle:@"YES"
                                               style:UIAlertActionStyleDestructive
                                             handler:^(UIAlertAction * _Nonnull action) {
                                                 @tstrongify(self);
                                                 [self.webView clearCache];
                                             }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ac animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Delete All Cache & Cookie？"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"NO"
                                              otherButtonTitles:@"YES", nil];
        alert.tag = AlertTagConfirmClearCache;
        [alert show];
    }
}

#pragma mark - AlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView resignFirstResponder];
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    } else {
        if (alertView.tag == AlertTagInputURL) {
            NSString *url = [alertView textFieldAtIndex:0].text;
            if (isNotEmptyString(url)) {
                [[NSUserDefaults standardUserDefaults] setObject:url forKey:T_TESTURL_LASTINPUTURL];
                [self loadURLFromString:url];
            }
            objc_setAssociatedObject(self, &TInputURLAlertView, nil, OBJC_ASSOCIATION_RETAIN);
            return;
        }
        
        if (alertView.tag == AlertTagConfirmClearCache) {
            [self.webView clearCache];
            return;
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.tag == TextFieldTagInputURL) {
        if (!T_IS_ABOVE_IOS(8)) {
            UIAlertView *alert = objc_getAssociatedObject(self, &TInputURLAlertView);
            [self alertView:alert clickedButtonAtIndex:alert.firstOtherButtonIndex];
            [alert dismissWithClickedButtonIndex:alert.firstOtherButtonIndex animated:YES];
        }
    }
    return YES;
}

@end
