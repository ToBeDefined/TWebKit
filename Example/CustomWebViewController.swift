//
//  CustomWebViewController.swift
//  Example
//
//  Created by 邵伟男 on 2017/7/28.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

class CustomWebViewController: UIViewController {
    var webView: TWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        TWebKitSetting.showAllErrorLog(false)
        let config = TWebViewConfig.init()
        config.cancelText = "取消"
        config.confirmText = "确定"
        config.progressTintColor = UIColor.orange
        config.forceOverrideCookie = false
        config.canScrollChangeSize = false
        config.webViewCommonDelegate = TWebViewCommonDelegate.init()
        config.webViewDelegate = self
        config.failedDefaultTitle = "加载失败"
        config.loadingDefaultTitle = "加载中..."
        config.successDefaultTitle = "加载成功"
        webView = TWebView.init(config: config)
        self.view.addSubview(webView);
        self.layoutWebView()
        if let url = URL.init(string: "http://www.qq.com/") {
            webView.load(URLRequest.init(url: url))
        }
    }
    
    func layoutWebView() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        let array: [NSLayoutAttribute] = [.left, .right, .top, .bottom]
        for attr in array {
            let constraint = NSLayoutConstraint.init(item: webView,
                                                     attribute: attr,
                                                     relatedBy: .equal,
                                                     toItem: self.view,
                                                     attribute: attr,
                                                     multiplier: 1.0,
                                                     constant: 0)
            self.view.addConstraint(constraint);
        }
    }
}

extension CustomWebViewController: TWebViewDelegate {
    func webView(_ webView: TWebView, loadStatus status: TWebViewLoadStatus, title: String) {
        self.navigationItem.title = title
    }
}



