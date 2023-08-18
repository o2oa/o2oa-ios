//
//  IMInstantMessageViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/6/12.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack
import QuickLook

class IMInstantMessageViewController: UITableViewController {
        
    private lazy var viewModel: IMViewModel = {
           return IMViewModel()
       }()
    private lazy var meetingViewModel: OOMeetingMainViewModel = {
        return OOMeetingMainViewModel()
    }()
    //预览文件
    private lazy var previewVC: CloudFilePreviewController = {
        return CloudFilePreviewController()
    }()
    
    var instantMsgList: [InstantMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "通知消息"
        self.tableView.register(UINib(nibName: "IMChatMessageViewCell", bundle: nil), forCellReuseIdentifier: "IMChatMessageViewCell")
        self.tableView.separatorStyle = .none
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 144
        self.tableView.backgroundColor = UIColor(hex: "#f3f3f3")
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.scrollMessageToBottom()
    }
    
    //刷新tableview 滚动到底部
    private func scrollMessageToBottom() {
        DispatchQueue.main.async {
            if self.instantMsgList.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.instantMsgList.count-1, section: 0), at: .bottom, animated: false)
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.instantMsgList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "IMChatMessageViewCell", for: indexPath) as? IMChatMessageViewCell {
            cell.setInstantContent(item: self.instantMsgList[indexPath.row])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeightForInstant(item: self.instantMsgList[indexPath.row])
    }
    
    func cellHeightForInstant(item: InstantMessage) -> CGFloat {
        var content = ""
        if let appMsg = item.customO2AppMsg(), item.isCustomType() {
            if appMsg.msgType() == CustomO2AppMsgType.text {
                content = appMsg.text?.content ?? ""
            }
            if appMsg.msgType() == CustomO2AppMsgType.image {
                return 69 + 192 + 20 + 10
            }
            if appMsg.msgType() == CustomO2AppMsgType.textcard {
                return 69 + IMTextCardView.IMTextCardView_height + 20 + 10
            }
        }
        if content == "" {
            content = item.title ?? ""
        }
        if content != "" {
            let size = content.getSizeWithMaxWidth(fontSize: 16, maxWidth: messageWidth)
            // 上边距 69 + 文字高度 + 内边距 + 底部空白高度
            return 69 + size.height + 28 + 10
        }
        return 132
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    // MARK: - private
    
    private func getMeetingInfo(id: String) {
        self.showLoading()
        self.meetingViewModel.getMeetingById(id: id).then { meeting in
            self.hideLoading()
            // 打开在线会议
            if let link = meeting.roomLink, let mode = meeting.mode, !link.isEmpty, mode == "online" {
                self.openUrlBySafari(link: link)
            } else {
                // 打开会议详情
                let storyBoard = UIStoryboard(name: "meeting", bundle: nil)
                guard let destVC = storyBoard.instantiateViewController(withIdentifier: "meetingDetailVC") as? OOMeetingDetailViewController else {
                    return
                }
                destVC.meetingInfo = meeting
                destVC.modalPresentationStyle = .fullScreen
                if destVC.isKind(of: ZLNavigationController.self) {
                    self.show(destVC, sender: nil)
                }else{
                    self.navigationController?.pushViewController(destVC, animated: true)
                }
            }
        }.catch { error in
            self.showError(title: "\(error.localizedDescription)")
        }
    }
    
    private func openUrlBySafari(link: String) {
        guard let url = URL(string: link) else {
            DDLogError("url地址不正确，\(link)")
            return
        }
        if #available(iOS 10, *) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                DDLogError("无法打开url，\(link)")
            }
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}

extension IMInstantMessageViewController : IMChatMessageDelegate {
    func openWebview(url: String, openExternally: Bool?) {
        if let out = openExternally, out == true {
            self.openUrlBySafari(link: url)
        } else {
            let destVC = OOTabBarHelper.getVC(storyboardName: "apps", vcName: "OOMainWebVC")
            if let mail = destVC as? MailViewController {
                mail.openUrl = url
                let nav = ZLNavigationController(rootViewController: mail)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func openHttpImage(imageUrl: String) {
        let md5FileName = imageUrl.MD5Filename()
        var imagePath =  FileUtil.share.cacheDir()
        imagePath.appendPathComponent("netImage") // 在线图片目录 netImage
        //目录不存在就创建
        FileUtil.share.createDirectory(path: imagePath.path)
        imagePath.appendPathComponent(md5FileName)
        DDLogDebug("文件路径：\(imagePath.path)")
        if FileManager.default.fileExists(atPath: imagePath.path) {
            self.openPreview(path: imagePath)
        } else {
            let request = URLRequest(url: URL(string: imageUrl)!)
            let downloadTask = URLSession.shared.downloadTask(with: request,
                   completionHandler: { (location:URL?, response:URLResponse?, error:Error?)
                    -> Void in
                if let loc = location {
                    print("location:\(loc)")
                    let locationPath = loc.path
                    let fileManager = FileManager.default
                    try! fileManager.moveItem(atPath: locationPath, toPath: imagePath.path)
                    self.openPreview(path: imagePath)
                }
            })
            downloadTask.resume()
        }
    }
    
    private func openPreview(path: URL) {
        let currentURL = NSURL(fileURLWithPath: path.path)
        DDLogDebug(path.path)
        DispatchQueue.main.async {
            if QLPreviewController.canPreview(currentURL) {
                self.previewVC.currentFileURLS.removeAll()
                self.previewVC.currentFileURLS.append(currentURL)
                self.previewVC.reloadData()
                self.pushVC(self.previewVC)
            } else {
                self.showError(title: "当前文件类型不支持预览！")
            }
        }
    }
    
    
    func playAudio(info: IMMessageBodyInfo, id: String?) {
        //无需实现
    }
    func openImageOrFileMessage(info: IMMessageBodyInfo) {
        //无需实现
    }
    
    func openLocatinMap(info: IMMessageBodyInfo) {
        //无需实现
    }
    
    func openApplication(storyboard: String, msgBody: String?) {
        // 会议管理特殊处理
        if storyboard == "meeting", let body = msgBody, let jsonData = String(body).data(using: .utf8), let dicArr = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String:AnyObject], let id = dicArr["id"] as? String {
            self.getMeetingInfo(id: id)
            return
        }
        // 信息中心的消息 特殊处理 这里消息一般都是文档消息
        if storyboard == "information",let body = msgBody, let jsonData = String(body).data(using: .utf8), let dicArr = try? JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String:AnyObject], let id = dicArr["id"] as? String {
            let title = dicArr["title"] as? String
            self.openCmsDocument(docId: id, docTitle: title ?? "", readonly: true)
            return
        }
        
        let storyBoard = UIStoryboard(name: storyboard, bundle: nil)
        guard let destVC = storyBoard.instantiateInitialViewController() else {
            return
        }
        destVC.modalPresentationStyle = .fullScreen
        if destVC.isKind(of: ZLNavigationController.self) {
            self.show(destVC, sender: nil)
        }else{
            self.navigationController?.pushViewController(destVC, animated: true)
        }
        
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
        self.show(destVC, sender: nil)
    }
    
    func openWork(workId: String) {
        self.openWorkPage(work: workId)
        
        // 已经支持 未结束和结束的工作打开
//        self.showLoading()
//        self.viewModel.isWorkCompleted(work: workId).always {
//            self.hideLoading()
//        }.then{ result in
//            if result {
//                self.showMessage(msg: "工作已经完成了！")
//            }else {
//                self.openWorkPage(work: workId)
//            }
//        }.catch {_ in
//            self.showMessage(msg: "工作已经完成了！")
//        }
        
        
    }
    
    private func openWorkPage(work: String) {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
        let json = """
        {"work":"\(work)", "workCompleted":"", "title":""}
        """
        let todo = TodoTask(JSONString: json)
        destVC.todoTask = todo
        destVC.backFlag = 3 //隐藏就行
        self.show(destVC, sender: nil)
    }
    
    func openPersonInfo(person: String) {
        //
    }
}
