//
//  ViewController.swift
//  Example
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit

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
        return 2
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        switch indexPath.row {
        case 0:
            cell.textLabel?.text = "打开TWebViewController"
        default:
            cell.textLabel?.text = "自定义TWebView"
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.pushTWebViewController()
        default:
            self.pushCustomViewController()
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
}

