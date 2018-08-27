//
//  ViewController.swift
//  Example
//
//  Created by 邵伟男 on 2017/7/27.
//  Copyright © 2017年 邵伟男. All rights reserved.
//

import UIKit
import TWebKit

struct TableViewData {
    var title: String
    var sel: Selector
}

class ViewController: UITableViewController {
    var filePath: String?
    var datas: [TableViewData]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Example"
        
        self.datas = [TableViewData.init(title: "打开TWebViewController",
                                         sel: #selector(pushTWebViewController)),
                      TableViewData.init(title: "自定义TWebView",
                                         sel: #selector(pushCustomViewController)),
                      TableViewData.init(title: "打开 xib 创建的 Controller",
                                         sel: #selector(pushXibWebViewController)),
                      TableViewData.init(title: "打开本地文件",
                                         sel: #selector(pushOpenLocalFile)),]
        self.tableView.backgroundColor = UIColor.white
        self.tableView.reloadData()
        self.tableView.tableFooterView = UIView()
        
        self.copyFileToDocumentDir()
    }
    
    func copyFileToDocumentDir() {
        // imitate file in document directory (document directory need read access)
        let fm = FileManager.default
        let documentURL = try? fm.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        guard let fileURL = documentURL?.appendingPathComponent("AlphaGoZero.pdf") else {
            return
        }
        if fm.fileExists(atPath: fileURL.path) {
            try? fm.removeItem(at: fileURL)
        }
        let originFilePath = (Bundle.main.bundlePath as NSString).appendingPathComponent("AlphaGoZero.pdf")
        try? fm.copyItem(at: URL.init(fileURLWithPath: originFilePath), to: fileURL)
        if fm.fileExists(atPath: fileURL.path) {
            print("copy success")
            self.filePath = fileURL.path
        }
    }
}

extension ViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.datas?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell()
        cell.textLabel?.text = self.datas?[indexPath.row].title
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.perform(self.datas?[indexPath.row].sel ?? #selector(pushTWebViewController))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ViewController {
    @objc
    func pushTWebViewController() {
        let vc = TWebViewController()
        vc.loadURL(from: "http://www.baidu.com")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func pushCustomViewController() {
        let vc = CustomWebViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func pushXibWebViewController() {
        let vc = XibWebViewController.init(nibName: "XibWebViewController", bundle: nil)
        vc.urlString = "http://www.qq.com"
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func pushOpenLocalFile() {
        let vc = TWebViewController()
        vc.loadLocalFile(inPath: self.filePath ?? "")
        vc.navgationTitle = "Alpha Go Zero"
        vc.navgationTitleLevel = .always
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

