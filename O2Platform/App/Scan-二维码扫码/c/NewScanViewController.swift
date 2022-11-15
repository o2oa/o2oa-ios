//
//  NewScanViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2016/12/22.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack


class NewScanViewController: LBXScanViewController {
    
    
    
    var callbackResult: ((String)->Void)? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        DDLogDebug("viewdid load................................")
        self.title = "扫一扫"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //扫码结果
    override func handleCodeResult(arrayResult: [LBXScanResult]) {
        
        for result:LBXScanResult in arrayResult
        {
            print(result.strScanned ?? "")
        }
        let result:LBXScanResult = arrayResult[0]
        if callbackResult != nil {
            callbackResult?(result.strScanned ?? "")
            self.popVC()
        }else {
            let url = NSURL(string: result.strScanned!)
            //会议签到功能
            var isMeetingCheck = false
            let allU = url?.absoluteString
            if allU != nil && allU!.contains("/checkin") && allU!.contains("x_meeting_assemble_control") {
                isMeetingCheck = true
            }
            if(isMeetingCheck) {//会议签到
                self.meetingCheck(url: allU!)
            }else {
                let query = url?.query
                let querys = query?.split("&")
                var meta = ""
                querys?.forEach { (e) in
                    let name = e.split("=")[0]
                    if name == "meta" {
                        meta = e.split("=")[1]
                    }
                }
                if meta != "" {//登录O2OA
                    let account = O2AuthSDK.shared.myInfo()
                    let loginURL = AppDelegate.o2Collect.generateURLWithAppContextKey(LoginContext.loginContextKey, query: LoginContext.scanCodeAuthActionQuery, parameter: ["##meta##":meta as AnyObject])
                    let tokenName = O2AuthSDK.shared.tokenName()
                    AF.request(loginURL!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: [tokenName:(account?.token)!]).responseJSON(completionHandler: { (response) in
                        switch response.result {
                        case .success(let val):
                            DispatchQueue.main.async {
                                DDLogDebug(String(describing:val))
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
                } else {//其他扫描结果
                    let alertController = UIAlertController(title: "扫描结果", message: result.strScanned!, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "确定", style: .default) {
                        action in
                        self.popVC()
                    }
                    alertController.addAction(okAction)
                    self.presentVC(alertController)
                }
            }
        }
    }
    
    
    //会议签到
    func meetingCheck(url: String) {
        DDLogInfo("会议签到 url： \(url)")
        let account = O2AuthSDK.shared.myInfo()
        let tokenName = O2AuthSDK.shared.tokenName()
        if let meetingId = self.getMeetingIdFromUrl(url: url) {
            DDLogInfo("会议签到 id： \(meetingId)")
            let meetingCheckUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(MeetingContext.meetingContextKey, query: MeetingContext.meetingCheckInQuery, parameter: ["##id##": meetingId as AnyObject])
            DDLogInfo("会议签到 meetingCheckUrl： \(meetingCheckUrl!)")
            AF.request(meetingCheckUrl!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: [tokenName:(account?.token)!]).responseJSON(completionHandler: {(response) in
                switch response.result {
                case .success(let val):
                    DispatchQueue.main.async {
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
        } else {
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
