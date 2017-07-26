//
//  ViewController.swift
//  TWebView
//
//  Created by 邵伟男 on 2017/7/22.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: TWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.view.backgroundColor = UIColor.red
        let webView = TWebView.init()
        self.webView = webView
        webView.delegate = self
        webView.frame = CGRect.init(x: 0, y: 64,
                                    width: UIScreen.main.bounds.width,
                                    height: UIScreen.main.bounds.height-64)
        self.view.addSubview(webView)
        webView.load(URLRequest.init(url: URL.init(string: "https://c.163.com")!))
        webView.canScrollBack = true
        webView.blockActionSheet = true
        webView.block3DTouch = true
        webView.progressViewTopConstraint?.constant = 0
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: TWebViewDelegate {
    func webView(_ webView: TWebView, shouldStartLoad request: URLRequest) -> Bool {
        print(request)
        return true
    }
}


