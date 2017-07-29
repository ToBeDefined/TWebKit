<div align="center">

TWebKit
------

</div>

<div align="center">

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/tobedefined/TWebKit/blob/master/LICENSE)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![CocoaPods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg?style=flat)](http://cocoapods.org/)&nbsp;
![platform](https://img.shields.io/badge/Platform-iOS%E2%89%A56.0-orange.svg?style=flat)

</div>

<div align="center">

[中文文档](README_CN.md)

</div>

### Features

> compatible with `Objective-C` and `swift`

#### TWebView

- Support automatically select whether to use `UIWebView` or `WKWebView` to load web pages based on system version
- Use the method is simple, and `UIWebView` very similar to the use of simplified `WKWebView` use
- Dual delegate mode, support the use of `commonDelegate` (commonDelegate class suggested using singleton mode), also supports the simultaneous set of custom `delegate`
    > By default, the custom `delegate` implementation of the method will take precedence over the `commonDelegate` to achieve the same name method;
    > 
    > In the custom `delegate` to achieve a method in the case will not call the `commonDelegate` in the same name method. (If necessary, you can use the method [webView.commonDelegate someFunc ..] to invoke the `commonDelegate` method in the custom `delegate`)
- supports `ProgressView`, `UIWebView` uses part of the code in [NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress) to simulate the progress of the configuration, support the configuration ProgressView color
- Support the configuration is allowed to slide back (`canScrollBack`)
- Support the configuration can zoom in and out of the page (`canScrollChangeSize`)
- Support configuration is masked long press the link to display ActionSheet (`blockActionSheet`)
- Support configuration for blocking links 3DTouch preview (`block3DTouch`)

#### TWebViewController

- `TWebViewController`'s back button for back web page, if back to first page, click it will pop TWebViewController
- `TWebViewController` click the back button to back web page, will appear the close button in controller
- `TWebViewController` in the Debug model contains the empty cache and enter the URL button (automatically save the last manually entered URL), in the Release model automatically blocked.


#### TWebViewDelegate

- All of the `@optional` proxy methods are easier to use


### Installation

#### CocoaPods

[`CocoaPods`](https://cocoapods.org/) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate `TWebKit` into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '6.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'TWebKit'
end
```

Then, run the following command:

```bash
$ pod install
```

#### Carthage

[`Carthage`](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [`Homebrew`](https://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate `TWebKit` into your Xcode project using Carthage, specify it in your `Cartfile`:

```ruby
github "tobedefined/TWebKit" ~> 1.0.3
```

Run `carthage update` to build the framework and drag the built `TWebKit.framework` into your Xcode project.


### How to use

- swift

in swift, add following code in `<Your Target Name>-Bridging-Header.h` file: 

```swif
#import <TWebKit/TWebKit.h>
```

- Objective-C

```objc
#import <TWebKit/TWebKit.h>
```

You can see the specific use of the demo, the following is a specific introduction

#### TWebView

Most of the parameters and methods are same like UIWebView, the following describes some of the different parameters and methods.

##### property

- delegate: `id <TWebViewDelegate>`, any object that confirm the `TWebViewDelegate` protocol, if set, has a higher priority than the commonDelegate method.
- commonDelegate: `id <TWebViewDelegate>`, any object that obeys the `TWebViewDelegate` protocol, is recommended to use a singleton object as a commonDelegate.
- showProgress: `BOOL`, `getter=isShowProgress`, whether to display the progress view.
- progressTintColor: `UIColor`, progress color, if setting, the `showProgress` become `YES/true` now.
- canScrollBack: `BOOL`, iOS8+ support, whether it can slide back to the previous page.
- canScrollChangeSize: `BOOL`, iOS8+ support, whether you can drag to change the page size.
- blockActionSheet: `BOOL`, iOS8+ support, whether to block the long press link appears actionSheet.
- block3DTouch: `BOOL`, iOS9+ support, whether to block 3DTouch preview links.
- confirmText: `NSString`, the confirm button text of web page pop-up box.
- cancelText: `NSString`, the cancel button text of web page pop-up box.
- lodingDefaultTitle: `NSString`, the title text returned by default in the page loading.
- successDefaultTitle: `NSString`, the title text returned by default in the page load succesed.
- failedDefaultTitle: `NSString`, the title text returned by default in the page load failed.

##### function

- `- (instancetype)init`

    > Create a default `TWebViewConfig` object and call `- (instancetype)initWithConfig:(TWebViewConfig *)config`.

- `- (instancetype)initWithConfig:(TWebViewConfig *)config`

    > Use the parameters in `config` to initialize to create `TWebView`.

- `- (void)clearCache`

    > Clear cache and cookies.

- `- (void)resetCookieForceOverride:(BOOL)forceOverride`

    > Get cookies in `NSHTTPCookieStorage` and set the cookie for TWebView, the `forceOverride` parameter control use the cookie value in `NSHTTPCookieStorage` to reset the cookie of the same name that existed before TWebView, if `forceOverride` is `NO/false`, will don't reset the same name cookie.

- `+ (nullable NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data`

    > Class method to get `JavaScript function`, `function` parameter to access the JavaScript method name (no need to add brackets), `data` parameters can be `JSON Object` or ordinary `NSString`, will automatically convert Stitching; returns a function call string after splicing.

- `- (void)runJavascript:(NSString *)js completion:(void (^__nullable)(id obj, NSError *error))completion`

    > Run the JavaScript function, interact with the web page, `js` parameter for the running javascript code, `complete` parameter for the callback.


#### TWebViewConfig

In order to make the configuration parameters more clear, so add the `TWebViewConfig` class, parameters corresponding to the `TWebView` parameters, you can use `TWebViewConfig` to create the configuration, and then use the configuration to create `TWebView`, assuredly, you can directly create `TWebView` object, and then assign the parameters of the created `TWebView` object.

| TWebViewConfig parameters | ->  | TWebView parameters |
|---------------------------|-----|--------------------:|
| webViewCommonDelegate     | ->  |      commonDelegate |
| webViewDelegate           | ->  |            delegate |
| forceOverrideCookie       | ->  | forceOverrideCookie |
| showProgressView          | ->  |        showProgress |
| progressTintColor         | ->  |   progressTintColor |
| canScrollChangeSize       | ->  | canScrollChangeSize |
| confirmText               | ->  |         confirmText |
| cancelText                | ->  |          cancelText |
| lodingDefaultTitle        | ->  |  lodingDefaultTitle |
| successDefaultTitle       | ->  | successDefaultTitle |
| failedDefaultTitle        | ->  |  failedDefaultTitle |
| canScrollBack             | ->  |       canScrollBack |
| blockActionSheet          | ->  |    blockActionSheet |
| block3DTouch              | ->  |        block3DTouch |

#### TWebViewDelegate

```objc
typedef NS_ENUM(NSUInteger, TWebViewLoadStatus) {
    TWebViewLoadStatusIsLoding = 1,
    TWebViewLoadStatusSuccess  = 2,
    TWebViewLoadStatusFailed   = 3,
};

@protocol TWebViewDelegate <NSObject>

@optional

// Whether you can load web pages
- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

// Start loading page
- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

// Load page successfully
- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

// Loading page failed
- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

// Current status: status, current default use of the title, 
// You can determination title to the ViewController based on the status. Or you can set the title parameter to the title of the ViewController.
// TWebViewLoadStatusIsLoding => return TWebView's lodingDefaultTitle
// TWebViewLoadStatusSuccess  => get web page's title, return it if not empty；if empty, return TWebView's successDefaultTitle
// TWebViewLoadStatusFailed   => return TWebView's failedDefaultTitle
- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;

@end

```

#### TWebViewController

> Whether to display to clear the cache and enter the URL for automatic control (Debug display, Release does not show), no configuration

##### property

- webView: `TWebView`, `TWebViewController`'s `TWebView` object, you can modify some of the properties that match your configuration requirements.
- navTitle: `NSString`, default navgation title, if setting, priority of `- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title` method, will always show `navTitle`.
- backImage: `UIImage`, default use `back.png` in `TWebKit.bundle`, you can customize set the back button image.

##### function

- `- (instancetype)initWithConfig:(TWebViewConfig *)config`

    > Create `TWebViewController` according to the `TWebViewConfig` configuration.

- `- (void)loadURLFromString:(NSString *)urlString`

    > load `urlString`'s web page.

- `- (void)loadURLAndAutoConversionFromString:(NSString *)urlString`

    > load `urlString`'s web page, will be on the urlString transcoding judgments and other operations, see `NSString *trueURLString(NSString *urlString)` method.

- `- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride`

    > call `TWebView`'s `- (void)resetCookieForceOverride:(BOOL)forceOverride` method, reset webView's cookie.




