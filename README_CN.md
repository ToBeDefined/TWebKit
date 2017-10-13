<div align="center">

TWebKit
------

</div>

<div align="center">

![platform](https://img.shields.io/badge/Platform-iOS%E2%89%A56.0-orange.svg?style=flat)&nbsp;
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)&nbsp;
[![CocoaPods](https://img.shields.io/badge/Cocoapods-compatible-brightgreen.svg?style=flat)](http://cocoapods.org/)&nbsp;
[![Build Status](https://travis-ci.org/tobedefined/TWebKit.svg?branch=master)](https://travis-ci.org/tobedefined/TWebKit)&nbsp;
[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://github.com/tobedefined/TWebKit/blob/master/LICENSE)

</div>

<div align="center">

[English Document](README.md)

</div>

### 特点

> 兼容`Objective-C`和`swift`

#### TWebView

- 支持自动根据系统版本选择使用`UIWebView`还是`WKWebView`加载网页
- 使用方法简单，与`UIWebView`的使用方法极其类似，简化`WKWebView`的使用
- 双代理模式，支持使用通用的代理`commonDelegate`（通用代理的类建议使用singleton单例模式），也支持同时设置普通的代理`delegate`
    > 默认情况下普通代理`delegate`里实现的方法会优先于通用代理`commonDelegate`里实现的同名方法；
    > 
    > 在普通代理`delegate`中实现某个方法的情况下不会去调用通用代理`commonDelegate`中的同名方法。（如果需要可以在普通代理`delegate`的该方法中使用[webView.commonDelegate  someFunc..]主动调用通用代理`commonDelegate`的该方法）
- 支持显示`ProgressView`，`UIWebView`的Progress使用了[NJKWebViewProgress](https://github.com/ninjinkun/NJKWebViewProgress)中的部分代码进行模拟进度，支持配置ProgressView的颜色
- 支持配置是否允许滑动返回(`canScrollBack`)
- 支持配置是否可以放大缩小网页(`canScrollChangeSize`)
- 支持配置是否屏蔽长按链接显示ActionSheet(`blockActionSheet`)
- 支持配置是否屏蔽链接的3DTouch预览(`block3DTouch`)

#### TWebViewController

- `TWebViewController`返回键为后退网页，后退到首个网页则popViewController
- `TWebViewController`点击返回键后退网页则会出现关闭controller的按钮
- `TWebViewController`在Debug包中包含清空缓存和输入网址按钮(自动保存最后一次手动输入的网址)，在Release包中自动屏蔽。


#### TWebViewDelegate

- 全是`@optional`的代理方法，更容易使用


### 导入项目

#### CocoaPods

[`CocoaPods`](https://cocoapods.org/)是一个Cocoa项目管理器。你可以使用以下命令去安装`CocoaPods`:

```bash
$ gem install cocoapods
```

要使用CocoaPods将`TWebKit`集成到您的Xcode项目中，请在`Podfile`中加入：

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '6.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'TWebKit'
end
```

然后运行一下命令:

```bash
$ pod install
```

#### Carthage


[`Carthage`](https://github.com/Carthage/Carthage)是一个去中心化的依赖管理器，它构建并提供所使用的库的framework。

你可以使用 [`Homebrew`](https://brew.sh/)并运行下面的命令安装Carthage

```bash
$ brew update
$ brew install carthage
```

要将`TWebKit`集成到使用Carthage的Xcode项目中，请在`Cartfile`中加入：

```ruby
github "tobedefined/TWebKit" ~> 1.1.1
```

运行`carthage update`构建framework，并将编译的`TWebKit.framework`拖入Xcode项目中。


### 使用方法

- swift

在swift的`<Your Target Name>-Bridging-Header.h`中加入

```objc
#import <TWebKit/TWebKit.h>
```

- Objective-C

```objc
#import <TWebKit/TWebKit.h>
```

你可以在demo中看具体的使用方法，下面是具体的介绍

#### TWebView

大部分参数和方法与UIWebView的参数相同，使用方式也相同，下面介绍一些不同的参数和方法。

##### property

- delegate：`id <TWebViewDelegate>`，代理，遵守`TWebViewDelegate`协议的任何对象，若设置，则其实现的方法优先级高于commonDelegate中的方法
- commonDelegate：`id <TWebViewDelegate>`，通用代理，遵守`TWebViewDelegate`协议的任何对象，建议使用singleton的对象作为通用代理
- showProgress：`BOOL`，`getter=isShowProgress`，是否显示进度条
- progressTintColor：`UIColor`，进度条颜色，配置之后会使`showProgress`为`YES/true`
- canScrollBack：`BOOL`，iOS8+支持，是否可以滑动返回上一个网页
- canScrollChangeSize：`BOOL`，iOS8+支持，是否可以拖动改变网页大小
- blockActionSheet：`BOOL`，iOS8+支持，是否屏蔽长按链接出现actionSheet
- block3DTouch：`BOOL`，iOS9+支持，是否屏蔽3DTouch预览链接
- confirmText：`NSString`，网页弹出框的确定按钮文字
- cancelText：`NSString`，网页弹出框的取消按钮文字
- lodingDefaultTitle：`NSString`，网页加载中默认返回的title文字
- successDefaultTitle：`NSString`，网页加载成功默认返回的title文字
- failedDefaultTitle：`NSString`，网页加载失败默认返回的title文字

##### function

- `- (instancetype)init`

    > 创建一个默认的`TWebViewConfig`对象，并调用`- (instancetype)initWithConfig:(TWebViewConfig *)config`

- `- (instancetype)initWithConfig:(TWebViewConfig *)config`

    > 使用`config`中的参数，进行初始化创建`TWebView`

- `- (void)clearCache`

    > 清空cache和cookie

- `- (void)resetCookieForceOverride:(BOOL)forceOverride`

    > 取出`NSHTTPCookieStorage`中的cookies设置TWebView的cookie，`forceOverride`参数控制是否强制使用`NSHTTPCookieStorage`中的cookie值重设TWebView之前存在的同名的cookie

- `+ (nullable NSString *)getJavascriptStringWithFunctionName:(NSString *)function data:(id)data`

    > 类方法提供拼接JavaScript函数功能，`function`参数为要访问的JavaScript的方法名(不需要添加括号)，`data`参数可以为`JSON Object`或者为普通的`NSString`，会自动进行转换拼接；返回拼接后的函数调用字符串。

- `- (void)runJavascript:(NSString *)js completion:(void (^__nullable)(id obj, NSError *error))completion`

    > 运行JavaScript函数，与网页进行交互，`js`参数为运行的JavaScript代码，`completion`参数为回调。


#### TWebViewConfig

为了将配置参数更加清晰，所以添加了这个类，参数与`TWebView`的各个配置参数对应，你可以使用`TWebViewConfig`创建配置，然后使用配置来创建`TWebView`；也可以直接创建`TWebView`，然后对创建的对象进行参数赋值。

| TWebViewConfig参数      | ->  |          TWebView参数 |
|-----------------------|-----|--------------------:|
| webViewCommonDelegate | ->  |      commonDelegate |
| webViewDelegate       | ->  |            delegate |
| forceOverrideCookie   | ->  | forceOverrideCookie |
| showProgressView      | ->  |        showProgress |
| progressTintColor     | ->  |   progressTintColor |
| canScrollChangeSize   | ->  | canScrollChangeSize |
| confirmText           | ->  |         confirmText |
| cancelText            | ->  |          cancelText |
| lodingDefaultTitle    | ->  |  lodingDefaultTitle |
| successDefaultTitle   | ->  | successDefaultTitle |
| failedDefaultTitle    | ->  |  failedDefaultTitle |
| canScrollBack         | ->  |       canScrollBack |
| blockActionSheet      | ->  |    blockActionSheet |
| block3DTouch          | ->  |        block3DTouch |

#### TWebViewDelegate

```objc
typedef NS_ENUM(NSUInteger, TWebViewLoadStatus) {
    TWebViewLoadStatusIsLoding = 1,
    TWebViewLoadStatusSuccess  = 2,
    TWebViewLoadStatusFailed   = 3,
};

@protocol TWebViewDelegate <NSObject>

@optional

// 是否可以加载网页
- (BOOL)webView:(TWebView *)webView shouldStartLoadRequest:(NSURLRequest *)request;

// 开始加载网页
- (void)webView:(TWebView *)webView didStartLoadRequest:(NSURLRequest *)request;

// 加载网页成功
- (void)webView:(TWebView *)webView didFinishLoadRequest:(NSURLRequest *)request;

// 加载网页失败
- (void)webView:(TWebView *)webView didFailedLoadRequest:(NSURLRequest *)request withError:(NSError *)error;

// 当前状态：status，当前默认使用的title，
// 可以选择使用根据状态判断设定ViewController的title。或者可以将title字段设为ViewController的title。
// TWebViewLoadStatusIsLoding => 返回TWebView的lodingDefaultTitle
// TWebViewLoadStatusSuccess  => 获取网页的title，如果不为空返回；为空返回TWebView的successDefaultTitle
// TWebViewLoadStatusFailed   => 返回TWebView的failedDefaultTitle
- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title;

@end

```

#### TWebViewController

> 是否显示清除缓存和输入网址的按钮为自动控制（Debug显示，Release不显示），无需配置

##### property

- webView：`TWebView`，`TWebViewController`中的`TWebView`对象，你可以修改一些属性符合你的配置要求。
- navTitle：`NSString`，默认的navTitle，如果设置，则覆盖`- (void)webView:(TWebView *)webView loadStatus:(TWebViewLoadStatus)status title:(NSString *)title`回调，始终显示`navTitle`。
- backImage：`UIImage`，默认使用`TWebKit.bundle`中的`back.png`，可以自定义设置返回按钮。

##### function

- `- (instancetype)initWithConfig:(TWebViewConfig *)config`

    > 根据`TWebViewConfig`配置来创建`TWebViewController`。

- `- (void)loadURLFromString:(NSString *)urlString`

    > 加载网址`urlString`

- `- (void)loadURLAndAutoConversionFromString:(NSString *)urlString`

    > 加载网址`urlString`，会对urlString进行转码判断等操作，具体详见`NSString *trueURLString(NSString *urlString)`

- `- (void)resetWebViewCookieForceOverride:(BOOL)forceOverride`

    > 调用`TWebView`的`- (void)resetCookieForceOverride:(BOOL)forceOverride`方法，重设cookie




