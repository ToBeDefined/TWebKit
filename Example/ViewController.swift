//
//  ViewController.swift
//  Example
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import TWebKit

class ViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.white
        self.tableView.reloadData()
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "打开TWebViewController"
        case 1:
            cell.textLabel?.text = "自定义TWebView"
        default:
            cell.textLabel?.text = "打开 xib 创建的 Controller"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.pushTWebViewController()
        case 1:
            self.pushCustomViewController()
        default:
            self.pushXibWebViewController()
        }
    }
}

extension ViewController {
    func pushTWebViewController() {
        let vc = TWebViewController()
        vc.loadURL(from: "http://www.baidu.com")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushCustomViewController() {
        let vc = CustomWebViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushXibWebViewController() {
        let vc = XibWebViewController()
        vc.urlString = "http://www.qq.com"
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

