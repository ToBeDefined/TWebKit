#
#  Be sure to run `pod spec lint TWebKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name                  = 'TWebKit'
  s.version               = '1.2.1'
  s.summary               = 'TWebKit unified the UIWebView and WKWebView'
  s.description           = <<-DESC
TWebKit unified the UIWebView and WKWebView, 
you can use TWebView instead, 
and you can set whether can slide back, change web size , block action sheet or 3D touch and so on.
github : https://github.com/tobedefined/TWebKit
                              DESC
  s.homepage              = 'https://github.com/tobedefined/TWebKit'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'ToBeDefined' => 'weinanshao@163.com' }
  s.social_media_url      = 'http://tbd.tech/'
  s.ios.deployment_target = '6.0'
  s.source                = { :git => 'https://github.com/tobedefined/TWebKit.git', :tag => s.version}
  s.public_header_files   = 'TWebKit/TWebKit.h'
  s.source_files          = 'TWebKit/TWebKit.h'
  s.frameworks            = 'Foundation', 'UIKit'
  s.weak_framework        = 'WebKit'
  s.resource              = 'Source/TWebKit.bundle'
  s.requires_arc = true

  s.subspec 'Setting' do |ss|
    ss.public_header_files = 'Source/TWebKitSetting.h'
    ss.source_files = 'Source/TWebKitSetting.{h,m}'
  end

  s.subspec 'Dependence' do |ss|
    ss.source_files = 'Source/Dependence/'
    ss.private_header_files = 'Source/Dependence/*.h'
    ss.dependency 'TWebKit/Setting'
  end

  s.subspec 'WebView' do |ss|
    ss.source_files         = 'Source/WebView/', 'Source/WebViewDelegate/'
    ss.private_header_files = 'Source/WebView/TWebView_Inner.h', 'Source/WebViewDelegate/*.h'
    ss.dependency 'TWebKit/Setting'
    ss.dependency 'TWebKit/Dependence'
  end

end
