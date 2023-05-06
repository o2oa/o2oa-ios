//
//  MailViewController.swift
//  O2Platform
//
//  Created by 林玲 on 2017/10/20.
//  Copyright © 2017年 zoneland. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import AlamofireObjectMapper

import ObjectMapper
import CocoaLumberjack

class MailViewController: BaseWebViewUIViewController {
    
    var openUrl: String? // 网页地址
    var app:O2App?
    // 首页显示门户 默认没有NavigationBar
    var isIndexShow:Bool = false
    // 门户内部是否有显示NavigationBar
    var hasInnerBar:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        //监听清除缓存之后需要重载
        NotificationCenter.default.addObserver(self, selector: #selector(loadDetailSubject), name: OONotification.reloadPortal.notificationName, object: nil)
        if self.isIndexShow {
            self.navigationItem.leftBarButtonItems = []
        }else {
            self.title = self.app?.title ?? ""
            let closeBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            closeBtn.setImage(UIImage(named: "icon_off_white2"), for: .normal)
            closeBtn.addTapGesture { (tap) in
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
            let closeItem = UIBarButtonItem(customView: closeBtn)
            
            let backBtn = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            backBtn.setImage(UIImage(named: "icon_fanhui"), for: .normal)
            backBtn.addTapGesture { (tap) in
                self.goBack(isBackBtn: true)
            }
            let backItem = UIBarButtonItem(customView: backBtn)
            
            self.navigationItem.leftBarButtonItems = [backItem, closeItem]
        }
        self.theWebView()
        self.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        
        if self.isIndexShow || self.hasInnerBar {
            if #available(iOS 13.0, *) {
                if let frame = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame {
                    let statusBar = UIView(frame: frame)
                   statusBar.backgroundColor = base_color
                   UIApplication.shared.keyWindow?.addSubview(statusBar)
                }
            }else {
              let statusBarWindow : UIView = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
                let statusBar : UIView = statusBarWindow.value(forKey: "statusBar") as! UIView
                if statusBar.responds(to:#selector(setter: UIView.backgroundColor)) {
                    statusBar.backgroundColor = base_color
                }
            }
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
        //回刷用的
        DDLogDebug("开始回刷。。")
        self.webView.evaluateJavaScript("window.o2Reload()", completionHandler: { (data, err) in
            DDLogDebug("已经完成o2Reload回刷。。")
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func theWebView(){
        super.theWebView()
        self.view = webView
        self.webView.allowsBackForwardNavigationGestures = true
        loadDetailSubject()
    }
  
    @objc func loadDetailSubject(){
        if let url = self.app?.vcName?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.loadUrl(url: url)
        } else {
            if let url = self.openUrl {
                self.loadUrl(url: url)
            } else {
                self.showError(title: L10n.applicationsUrlIsEmpty)
            }
        }
    }
    
    private func loadUrl(url: String) {
        DDLogDebug("url: " + url)
        if let urlR = URL(string: url) {
            let req = URLRequest(url: urlR)
            self.webView?.load(req)
        }else {
            self.showError(title: L10n.applicationsUrlRequestError)
        }
    }
    
    func goBack(isBackBtn: Bool) {
        if self.webView?.canGoBack ?? false {
            self.webView?.goBack()
        }else {
            if isBackBtn {
                self.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MailViewController: BaseWebViewUIViewControllerJSDelegate {
    func closeUIViewWindow() {
        DDLogDebug("关闭啦。。。。。。。。。。。。。。")
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    func actionBarLoaded(show: Bool) {
        DDLogDebug("actionBar 显示了。。。。\(show)。")
        if(show) {
            self.hasInnerBar = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
}
