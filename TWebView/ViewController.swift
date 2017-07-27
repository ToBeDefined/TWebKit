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
        self.view.backgroundColor = UIColor.white
        let btn = UIButton.init(type: .system)
        btn.setTitle("push", for: .normal)
        btn.frame = CGRect.init(x: 30, y: 100, width: 100, height: 100)
        btn.addTarget(self, action: #selector(self.push), for: .touchUpInside)
        self.view.addSubview(btn)
        
    }
    
    func push() {
        let vc = TWebViewController()
        vc.loadURL(from: "http://www.baidu.com")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}



