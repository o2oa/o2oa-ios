//
//  BBSSubjectDetailViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2016/11/8.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import AlamofireObjectMapper

import ObjectMapper
import CocoaLumberjack

class BBSSubjectDetailViewController: BaseWebViewUIViewController {
    
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var attachmentBtn: UIButton!
    
    @IBOutlet weak var replyBtn: UIButton!
    
    
    var loadUrl:String?
    
    var subject:BBSSubjectData? {
        didSet {
            loadUrl = AppDelegate.o2Collect.genrateURLWithWebContextKey(DesktopContext.DesktopContextKey, query: DesktopContext.bbsItemDetailQuery, parameter: ["##subjectId##":subject?.id as AnyObject])
        }
    }
    
    private lazy var viewModel: BBSViewModel = {
        return BBSViewModel()
    }()
    private var attachmentList: [O2BBSSubjectAttachmentInfo] = []
    
    override func viewWillAppear(_ animated: Bool) {
        //监控进度
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if keyPath == "estimatedPrgress" {
           progressView.isHidden = webView.estimatedProgress == 1
           progressView.setProgress(Float(webView.estimatedProgress), animated: true)
       }
   }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attachmentBtn.isHidden = true
        if let subjectId = self.subject?.id {
            self.viewModel.getSubjectAttachmentList(subjectId: subjectId)
                .then { attachments  in
                    if attachments.count > 0 {
                        self.attachmentList = attachments
                        self.attachmentBtn.isHidden = false
                    }
            }.catch { (error) in
                DDLogError(error.localizedDescription)
            }
        }
        
        self.theWebView()
        
        if O2AuthSDK.shared.isBBSMute() {
            self.replyBtn.isHidden = true
        }
    }
    
    
    @IBAction func clickAttachmentBtn(_ sender: UIButton) {
        DDLogDebug("点击附件列表")
        if self.attachmentList.count > 0 {
            self.performSegue(withIdentifier: "showSubAttachmentActionSegue", sender: nil)
        }else {
            self.showError(title: "没有附件！")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReplyActionSegue" {
            let navVC = segue.destination as! ZLNavigationController
            let destVC = navVC.topViewController as! BBSReplySubjectViewController
            destVC.subject = self.subject
            if let parentId = sender {
                destVC.parentId = parentId as? String
            }
        }else if segue.identifier == "showSubAttachmentActionSegue" {
            let navVC = segue.destination as! ZLNavigationController
            let destVC = navVC.topViewController as! BBSSubjectAttachmentViewController
            destVC.attachmentList = self.attachmentList
        }
    }
    
    override func theWebView(){
        super.theWebView()
        self.webViewContainer.addSubview(self.webView)
        self.webView.translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.webViewContainer, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1, constant: 0)
        let bottom = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.webViewContainer, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.webViewContainer, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let leading = NSLayoutConstraint(item: self.webView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.webViewContainer, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        self.webViewContainer.addConstraints([top, bottom, trailing, leading])
        
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        webView.allowsBackForwardNavigationGestures = true
        
        loadDetailSubject()
    }
    
    func loadDetailSubject(){
        if let itemUrl = loadUrl, let urlR = URL(string: itemUrl) {
            let req = URLRequest(url: urlR)
            webView.load(req)
        }else {
            webView.loadHTMLString("<h2>没有获取到正确的URL！</h2>", baseURL: nil)
        }
    }
    
    @IBAction func unFromReplyBackSubject(_ segue:UIStoryboardSegue){
        loadDetailSubject()
    }

    //写评论
    @IBAction func replaySubject(_ sender: UIButton) {
        if O2AuthSDK.shared.isBBSMute() {
            DDLogInfo("当前用户被禁言")
            return
        }
        self.performSegue(withIdentifier:"showReplyActionSegue", sender: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    

}



extension BBSSubjectDetailViewController:WKNavigationDelegate,WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        DDLogDebug("didFailProvisionalNavigation \(String(describing: navigation))  error = \(error)")
    }

    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        DDLogDebug("didStartProvisionalNavigation \(String(describing: navigation))")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        DDLogDebug("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        DDLogDebug("didFinish")
        //self.setupData()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        DDLogDebug("didFail")
        DDLogError(error.localizedDescription)
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        DDLogInfo("h5执行了window.close()")
        self.dismissVC(completion: nil)
    }
    
}
