//
//  XibWebViewController.swift
//  Example
//
//  Created by TBD on 2018/8/27.
//  Copyright © 2018 TBD. All rights reserved.
//

import UIKit
import TWebKit

class XibWebViewController: UIViewController {
    var urlString: String?
    @IBOutlet weak var webView: TWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Xib VC"
        if let url = URL.init(string: urlString ?? "") {
            self.webView?.load(URLRequest.init(url: url))
        }
    }
}
