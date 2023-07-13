//
//  QRCodeResultViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/8/26.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack


class QRCodeResultViewController: UIViewController {
    
    ///打开扫码结果
    static func openQRResult(result: String, vc: UIViewController) {
        DDLogDebug("openQRResult result \(result)")
        let resultVC = QRCodeResultViewController()
        resultVC.scanResult = result
        vc.navigationController?.pushViewController(resultVC, animated: false)
    }
    
    /// 扫码结果是否会议签到、扫码登录
    static func checkResultIsO2(result: String) -> (Bool, String) {
        let url = NSURL(string: result)
       //会议签到功能
       var isMeetingCheck = false
       let allU = url?.absoluteString
       if allU != nil && allU!.contains("/checkin") && allU!.contains("x_meeting_assemble_control") {
           isMeetingCheck = true
       }
        let query = url?.query
        let querys = query?.split("&")
        var meta = ""
        querys?.forEach { (e) in
            let name = e.split("=")[0]
            if name == "meta" {
                meta = e.split("=")[1]
            }
        }
        return (isMeetingCheck, meta)
    }
    
    @IBOutlet weak var loginStackView: UIStackView!
    @IBOutlet weak var loginImage: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var resultLabel: O2CanCopyUILabel!
    
    //扫码结果
    var scanResult: String?
    
    //登录url
    private var loginURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let result = scanResult {
            //self.showLoading()
            //开始解析结果
            self.resolveResult(result: result)
        }else {
            self.title = "扫码结果"
            self.resultLabel.isHidden = false
            self.resultLabel.text = "扫码结果为空"
        }
    }

    @IBAction func tap2Login(_ sender: UIButton) {
        //点击登陆
        if let login = self.loginURL {
            self.showLoading()
            let account = O2AuthSDK.shared.myInfo()
            let tokenName = O2AuthSDK.shared.tokenName()
            AF.request(login, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [tokenName:(account?.token)!]).responseJSON(completionHandler: { (response) in
                switch response.result {
                case .success(let val):
                    DispatchQueue.main.async {
                        DDLogDebug(String(describing:val))
                        self.hideLoading()
                        let alertController = UIAlertController(title: "扫描结果", message: "PC端登录成功", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "确定", style: .default) {
                            action in
                            self.popVC()
                        }
                        alertController.addAction(okAction)
                        self.presentVC(alertController)
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.hideLoading()
                        DDLogError(err.localizedDescription)
                        let alertController = UIAlertController(title: "扫描结果", message: "PC端登录失败", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "确定", style: .destructive) {
                            action in
                            self.popVC()
                        }
                        alertController.addAction(okAction)
                        self.presentVC(alertController)
                    }
                }
            })
        }
    }
    
    ///解析扫码结果
    private func resolveResult(result: String) {
        DDLogDebug("result \(result)" )
        var resultUrl: URL? = nil
        if let url = URL(string: result) {
            resultUrl = url
        } else if let urlEscapedString = result.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) , let escapedURL = URL(string: urlEscapedString){
            resultUrl = escapedURL
        }
        guard let realUrl = resultUrl else {
            self.resultLabel.isHidden = false
            self.resultLabel.text = result
            return
        }
        
        let querys = realUrl.query?.split("&")  ?? []
        // 内部 url
        if let host = O2AuthSDK.shared.bindUnit()?.centerHost, result.contains(host) {
            // 会议签到
            if result.contains("/checkin") && result.contains("x_meeting_assemble_control") {
                self.meetingCheck(url: result)
                return
            }
            // cms 文档
            if (result.contains("x_desktop/cmspreview.html")
                            || result.contains("x_desktop/cmsdoc.html")
                            || result.contains("x_desktop/cmsdocMobile.html")
                || result.contains("x_desktop/cmsdocmobilewithaction.html")) {
                var docId = self.getQuery(querys: querys, queryName: "documentId")
                if docId.isEmpty {
                    docId = self.getQuery(querys: querys, queryName: "id")
                }
                let title = self.getQuery(querys: querys, queryName: "title")
                let readonly = self.getQuery(querys: querys, queryName: "readonly")
                let readonlyBool = readonly == "true"
                if !docId.isEmpty {
                    self.openCmsDocument(docId: docId, docTitle: title, readonly: readonlyBool)
                    return
                }
            }
            // work
            if (result.contains("x_desktop/work.html")
                           || result.contains("x_desktop/workmobile.html")
                || result.contains("x_desktop/workmobilewithaction.html")) {
                var workId = self.getQuery(querys: querys, queryName: "workId")
                if workId.isEmpty {
                    workId = self.getQuery(querys: querys, queryName: "workid")
                }
                if workId.isEmpty {
                    workId = self.getQuery(querys: querys, queryName: "work")
                }
                if workId.isEmpty {
                    workId = self.getQuery(querys: querys, queryName: "workcompletedid")
                }
                if workId.isEmpty {
                    workId = self.getQuery(querys: querys, queryName: "workcompletedId")
                }
                if workId.isEmpty {
                    workId = self.getQuery(querys: querys, queryName: "id")
                }
                let title = self.getQuery(querys: querys, queryName: "title")
                if !workId.isEmpty {
                    self.openWork(work: workId, title: title)
                    return
                }
            }
            // app
            if (result.contains("x_desktop/app.html")
                || result.contains("x_desktop/appMobile.html")) {
                let app = self.getQuery(querys: querys, queryName: "app")
                let status = self.getQuery(querys: querys, queryName: "status")
                DDLogDebug("app \(app)" )
                DDLogDebug("status \(status)")
                if let statusMap = self.getAppStatusMap(status: status) {
                    var workId = (statusMap["workId"] as? String) ?? ""
                    if workId.isEmpty {
                        workId =  (statusMap["workCompletedId"]  as? String) ?? ""
                    }
                    if app == "process.Work" && !workId.isEmpty {
                        self.openWork(work: workId, title: "")
                        return
                    }
                    let documentId = (statusMap["documentId"] as? String) ?? ""
                    DDLogDebug("documentId \(documentId)" )
                    let readonly = (statusMap["readonly"] as? Bool) ?? false
                    DDLogDebug("readonly \(readonly)" )
                    if app == "cms.Document" && !documentId.isEmpty {
                        self.openCmsDocument(docId: documentId, docTitle: "", readonly: readonly)
                        return
                    }
                }
            }
        }
        
        self.title = "扫码登录"
        let meta = self.getQuery(querys: querys, queryName: "meta")
        if meta != "" {//登录O2OA
            self.loginURL = AppDelegate.o2Collect.generateURLWithAppContextKey(LoginContext.loginContextKey, query: LoginContext.scanCodeAuthActionQuery, parameter: ["##meta##":meta as AnyObject])
            self.loginStackView.isHidden = false
            self.loginBtn.isHidden = false
            
        }else {//其他扫描结果
            self.resultLabel.isHidden = false
            self.resultLabel.text = result
        }
         
    }
    
    private func getAppStatusMap(status: String) -> Dictionary<String, Any>? {
        if !status.isBlank {
            if let jsonData = status.removingPercentEncoding?.data(using: .utf8) {
                do {
                    let dc = try JSONSerialization.jsonObject(with: jsonData, options: .mutableContainers)
                    return dc as? Dictionary<String, Any>
                } catch _ {
                    // 解码两次
                    if let json2Data = status.removingPercentEncoding?.removingPercentEncoding?.data(using: .utf8) {
                        do {
                            let dc2 = try JSONSerialization.jsonObject(with: json2Data, options: .mutableContainers)
                            return dc2 as? Dictionary<String, Any>
                        } catch _ {
                            DDLogError("json 转化 出错")
                        }
                    }
                }
            }
        }
        return nil
    }
    
    /// 获取query 参数的值
    private func getQuery(querys:[String], queryName: String) -> String {
        var v = ""
        querys.forEach { (e) in
            let name = e.split("=")[0]
            if name == queryName {
                v = e.split("=")[1]
            }
        }
        return v
    }
    /// 打开工作
    private func openWork(work: String, title: String) {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
        let json = """
        {"work":"\(work)", "title":"\(title)"}
        """
        DDLogDebug("openWork json: \(json)")
        let todo = TodoTask(JSONString: json)
        destVC.todoTask = todo
        destVC.backFlag = 3 //隐藏就行
        self.closeSelfAndOpen(newVC: destVC)
    }
    /// 打开cms文档
    private func openCmsDocument(docId: String, docTitle: String, readonly: Bool) {
        DDLogInfo("打开文档， docId：\(docId) , docTitle:\(docTitle) , readonly: \(readonly)")
        let storyBoard = UIStoryboard(name: "information", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "CMSSubjectDetailVC") as! CMSItemDetailViewController
        let json = """
        {"title":"\(docTitle)", "id":"\(docId)", "readonly": \(readonly)}
        """
        destVC.itemData =  CMSCategoryItemData(JSONString: json)
        self.closeSelfAndOpen(newVC: destVC)
    }
    
    private func closeSelfAndOpen(newVC: UIViewController) {
        newVC.modalPresentationStyle = .fullScreen
        self.navigationController?.pushViewController(newVC, animated: true)
        self.navigationController?.viewControllers.remove(at: self.navigationController!.viewControllers.count - 1)
    }
    
    
    //会议签到
    private func meetingCheck(url: String) {
        self.title = "会议签到"
        DDLogInfo("会议签到 url： \(url)")
        let account = O2AuthSDK.shared.myInfo()
        let tokenName = O2AuthSDK.shared.tokenName()
        if let meetingId = self.getMeetingIdFromUrl(url: url) {
            DDLogInfo("会议签到 id： \(meetingId)")
            let meetingCheckUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(MeetingContext.meetingContextKey, query: MeetingContext.meetingCheckInQuery, parameter: ["##id##": meetingId as AnyObject])
            DDLogInfo("会议签到 meetingCheckUrl： \(meetingCheckUrl!)")
            self.showLoading()
            AF.request(meetingCheckUrl!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [tokenName:(account?.token)!]).responseJSON(completionHandler: {(response) in
                switch response.result {
                case .success(let val):
                    DispatchQueue.main.async {
                        self.hideLoading()
                        DDLogDebug(String(describing:val))
                        let alertController = UIAlertController(title: "提示", message: "签到成功", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "确定", style: .default) {
                            action in
                            self.popVC()
                        }
                        alertController.addAction(okAction)
                        self.presentVC(alertController)
                    }
                case .failure(let err):
                    DispatchQueue.main.async {
                        self.hideLoading()
                        DDLogError(err.localizedDescription)
                        let alertController = UIAlertController(title: "提示", message: "签到失败", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "确定", style: .destructive) {
                            action in
                            self.popVC()
                        }
                        alertController.addAction(okAction)
                        self.presentVC(alertController)
                    }
                }
            })
        }else {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "提示", message: "参数获取异常！", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "确定", style: .destructive) {
                    action in
                    self.popVC()
                }
                alertController.addAction(okAction)
                self.presentVC(alertController)
            }
        }
        
    }
    
    private func getMeetingIdFromUrl(url: String) -> String? {
        do {
            let re = try NSRegularExpression(pattern: "x_meeting_assemble_control\\/jaxrs\\/meeting\\/(.*?)\\/checkin", options: [])
            let matches = re.matches(in: url, range: NSRange(location: 0, length: url.count))
            if !matches.isEmpty {
                let m = matches[0]
                if m.numberOfRanges == 2 {
                    let range = m.range(at: 1)
                    if let r = Range(range, in: url) {
                        return  url.substring(with: r)
                    }
                }
//                for n in 0..<m.numberOfRanges {
//                   let range = m.range(at: n)
//                   if let r = Range(range, in: url) {
//                       let a = url.substring(with: r)
//                       print(a)
//                   }
//                }
            }
        }catch {
            DDLogError(error.localizedDescription)
        }
        return nil
    }
    

}
