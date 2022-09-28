//
//  IMChatViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2020/6/8.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

import BSImagePicker
import Photos
import Alamofire
import AlamofireImage

import QuickLook
import SnapKit

class IMChatViewController: UIViewController {

    // MARK: - IBOutlet
    //消息列表
    @IBOutlet weak var tableView: UITableView!
    //消息输入框
    @IBOutlet weak var messageInputView: UITextField!
    //底部工具栏的高度约束
    @IBOutlet weak var bottomBarHeightConstraint: NSLayoutConstraint!
    //底部工具栏
    @IBOutlet weak var bottomBar: UIView!
    
    // 底部工具栏 底部约束 输入法弹出的时候使用
    @IBOutlet weak var bottomBarBottomConstraint: NSLayoutConstraint!
    

    private let emojiBarHeight = 196
    //表情窗口
    private lazy var emojiBar: IMChatEmojiBarView = {
        let view = Bundle.main.loadNibNamed("IMChatEmojiBarView", owner: self, options: nil)?.first as! IMChatEmojiBarView
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: emojiBarHeight.toCGFloat)
        return view
    }()
    //语音录制按钮
    private lazy var audioBtnView: IMChatAudioView = {
        let view = Bundle.main.loadNibNamed("IMChatAudioView", owner: self, options: nil)?.first as! IMChatAudioView
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: emojiBarHeight.toCGFloat)
        view.delegate = self
        return view
    }()
    //录音的时候显示的view
    private var voiceIconImage: UIImageView?
    private var voiceIocnTitleLable: UILabel?
    private var voiceImageSuperView: UIView?
    
    
    //预览文件
    private lazy var previewVC: CloudFilePreviewController = {
        return CloudFilePreviewController()
    }()

    private lazy var viewModel: IMViewModel = {
        return IMViewModel()
    }()

    // MARK: - properties
    var conversation: IMConversationInfo? = nil
    
    //private
    private var chatMessageList: [IMMessageInfo] = []
    private var page = 0
    private var isShowEmoji = false
    private var isShowAudioView = false
    private var bottomBarHeight = 64 //底部输入框 表情按钮 的高度
    private let bottomToolbarHeight = 46 //底部工具栏 麦克风 相册 相机等按钮的位置
    
    private var playingAudioMessageId: String? // 正在播放音频的消息id

    // 当前选中的消息对象 长按菜单需要使用
    private var currentSelectMsg: IMMessageInfo? = nil
    
    private var imConfig = IMConfig()
    
    deinit {
        AudioPlayerManager.shared.delegate = nil
    }

    // MARK: - functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // 配置文件
        if let config = O2UserDefaults.shared.imConfig {
            imConfig = config
        } else {
            imConfig.enableClearMsg = false
            imConfig.enableRevokeMsg = false
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "IMChatMessageViewCell", bundle: nil), forCellReuseIdentifier: "IMChatMessageViewCell")
        self.tableView.register(UINib(nibName: "IMChatMessageSendViewCell", bundle: nil), forCellReuseIdentifier: "IMChatMessageSendViewCell")
        self.tableView.separatorStyle = .none
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 144
        self.tableView.backgroundColor = UIColor(hex: "#f3f3f3")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
           self.loadMsgList()
        })
        
        // 输入框 delegate
        self.messageInputView.delegate = self
        
        // 播放audio delegate
        AudioPlayerManager.shared.delegate = self

        //底部安全距离 老机型没有
        self.bottomBarHeight = Int(iPhoneX ? 64 + IPHONEX_BOTTOM_SAFE_HEIGHT: 64) + self.bottomToolbarHeight
        self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat
        self.bottomBar.topBorder(width: 1, borderColor: base_gray_color.alpha(0.5))
        self.messageInputView.backgroundColor = base_gray_color

        //标题
        if self.conversation?.type == o2_im_conversation_type_single {
            if let c = self.conversation {
                var person = ""
                c.personList?.forEach({ (p) in
                    if p != O2AuthSDK.shared.myInfo()?.distinguishedName {
                        person = p
                    }
                })
                if !person.isEmpty {
                    self.title = person.split("@").first ?? ""
                }
            }
        } else {
            self.title = self.conversation?.title
        }
        //群会话 添加修改标题的按钮
        if self.conversation?.type == o2_im_conversation_type_group &&
            O2AuthSDK.shared.myInfo()?.distinguishedName == self.conversation?.adminPerson {

            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "修改", style: .plain, target: self, action: #selector(clickUpdate))
        } else if self.conversation?.type == o2_im_conversation_type_single {
            if imConfig.enableClearMsg == true {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "清除聊天记录", style: .plain, target: self, action: #selector(clearAllChatMsg))
            }
        }
        
        //获取聊天数据
        self.loadMsgList()
        //阅读
        self.viewModel.readConversation(conversationId: self.conversation?.id)
    }

    override func viewWillAppear(_ animated: Bool) {
        // websocket 消息监听
        NotificationCenter.default.addObserver(self, selector: #selector(receiveMessageFromWs(notice:)), name: OONotification.imCreate.notificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveRevokeMsgFromWs(notice:)), name: OONotification.imRevoke.notificationName, object: nil)
        // 监听 键盘打开
        NotificationCenter.default.addObserver(self, selector: #selector(openKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // 监听 键盘大小变化
//        NotificationCenter.default.addObserver(self, selector: #selector(openKeyboard(notification:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        // 监听 键盘关闭
        NotificationCenter.default.addObserver(self, selector: #selector(closeKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    
    // 打开键盘的时候
    @objc private func openKeyboard(notification: Notification) {
        if let userInfo = notification.userInfo {
            let v = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            let y = v?.cgRectValue.origin.y ?? 0
            DDLogDebug("当前键盘高度： \(y)")
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
            UIView.animate(withDuration: duration?.doubleValue ?? 0.3, animations: {
                self.bottomBarBottomConstraint.constant = y
            })
            
        }
    }
    // 关闭键盘
    @objc private func closeKeyboard(notification: Notification) {
        UIView.animate(withDuration:  0.3, animations: {
            self.bottomBarBottomConstraint.constant = 0
        })
    }
    // 新消息
    @objc private func receiveMessageFromWs(notice: Notification) {
        DDLogDebug("接收到websocket im 消息")
        if let message = notice.object as? IMMessageInfo {
            if message.conversationId == self.conversation?.id {
                self.chatMessageList.append(message)
                self.scrollMessageToBottom()
                self.viewModel.readConversation(conversationId: self.conversation?.id)
            }
        }
    }
    // 撤回消息
    @objc private func receiveRevokeMsgFromWs(notice: Notification) {
        DDLogDebug("接收到websocket im 撤回消息")
        if let message = notice.object as? IMMessageInfo {
            if message.conversationId == self.conversation?.id {
                if let index = self.chatMessageList.firstIndex(where: { $0.id == message.id }) {
                    self.chatMessageList.remove(at: index)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .none)
                        self.tableView.endUpdates()
                    }
                }
            }
        }
    }
    
    @objc private func clickUpdate() {
        var arr = [
            UIAlertAction(title: "修改群名", style: .default, handler: { (action) in
                self.updateTitle()
            }),
            UIAlertAction(title: "修改成员", style: .default, handler: { (action) in
                self.updatePeople()
            })
        ]
        if imConfig.enableClearMsg == true {
            arr.append(UIAlertAction(title: "清除聊天记录", style: .default, handler: { (action) in
                self.clearAllChatMsg()
            }))
        }
        self.showSheetAction(title: "", message: "选择要修改的项", actions: arr)
    }
    
    @objc private func clearAllChatMsg() {
        self.showDefaultConfirm(title: "提示", message: "确定要清空聊天记录吗，清空后当前会话所有人都将看不到这些聊天记录？") { action in
            // 清空聊天记录
            if let id = self.conversation?.id {
                self.viewModel.clearAllChatMsg(conversationId:  id).then { result in
                    if result {
                        self.showMessage(msg: "清空聊天记录成功！")
                        self.chatMessageList.removeAll()
                        self.tableView.reloadData()
                        self.page = 0
                        self.loadMsgList()
                    } else {
                        self.showError(title: "清空失败！")
                    }
                }
            }
        }
    }
    
    private func updateTitle() {
        self.showPromptAlert(title: "", message: "修改群名", inputText: "") { (action, result) in
            if result.isEmpty {
                self.showError(title: "请输入群名")
            }else {
                self.showLoading()
                self.viewModel.updateConversationTitle(id: (self.conversation?.id!)!, title: result)
                    .then { (c) in
                        self.title = result
                        self.conversation?.title = result
                        self.showSuccess(title: "修改成功")
                }.catch { (err) in
                    DDLogError(err.localizedDescription)
                    self.showError(title: "修改失败")
                }
            }
        }
    }
    
    private func updatePeople() {
        //选择人员 反选已经存在的成员
        if let users = self.conversation?.personList  {
            self.showContactPicker(modes: [.person], callback: { (result) in
                if let people = result.users  {
                    if people.count >= 3 {
                        var peopleDNs: [String] = []
                        var containMe = false
                        people.forEach { (item) in
                            peopleDNs.append(item.distinguishedName!)
                            if O2AuthSDK.shared.myInfo()?.distinguishedName == item.distinguishedName {
                                containMe = true
                            }
                        }
                        if !containMe {
                            peopleDNs.append((O2AuthSDK.shared.myInfo()?.distinguishedName)!)
                        }
                        self.showLoading()
                        self.viewModel.updateConversationPeople(id: (self.conversation?.id!)!, users: peopleDNs)
                            .then { (c)  in
                                self.conversation?.personList = peopleDNs
                                self.showSuccess(title: "修改成功")
                        }.catch { (err) in
                            DDLogError(err.localizedDescription)
                            self.showError(title: "修改失败")
                        }
                    }else {
                        self.showError(title: "选择人数不足3人")
                    }
                }else {
                    self.showError(title: "请选择人员")
                }
            }, initUserPickedArray: users)
        }else {
            self.showError(title: "成员列表数据错误！")
        }
    }

    //获取消息
    private func loadMsgList() {
        if let c = self.conversation, let id = c.id {
            self.viewModel.myMsgPageList(page: self.page + 1, conversationId: id).then { (list) in
                if !list.isEmpty {
                    self.page += 1
                    self.chatMessageList.insert(contentsOf: list, at: 0)
                    if self.page ==  1 {
                        self.scrollMessageToBottom()
                    }else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
                if self.tableView.mj_header.isRefreshing(){
                    self.tableView.mj_header.endRefreshing()
                }
                
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                if self.tableView.mj_header.isRefreshing(){
                    self.tableView.mj_header.endRefreshing()
                }
            }
        } else {
            self.showError(title: "参数错误！！！")
        }
    }
    //刷新tableview 滚动到底部
    private func scrollMessageToBottom() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.chatMessageList.count > 0 {
                self.tableView.scrollToRow(at: IndexPath(row: self.chatMessageList.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }

    //发送文本消息
    private func sendTextMessage() {
        guard let msg = self.messageInputView.text else {
            return
        }
        self.messageInputView.text = ""
        let body = IMMessageBodyInfo()
        body.type = o2_im_msg_type_text
        body.body = msg
        sendMessage(body: body)
    }
    //发送表情消息
    private func sendEmojiMessage(emoji: String) {
        let body = IMMessageBodyInfo()
        body.type = o2_im_msg_type_emoji
        body.body = emoji
        sendMessage(body: body)
    }

    //发送地图消息消息
    private func sendLocationMessage(loc: O2LocationData) {
        let body = IMMessageBodyInfo()
        body.type = o2_im_msg_type_location
        body.body = o2_im_msg_body_location
        body.address = loc.address
        body.addressDetail = loc.addressDetail
        body.longitude = loc.longitude
        body.latitude = loc.latitude
        sendMessage(body: body)
    }

    //发送消息到服务器
    private func sendMessage(body: IMMessageBodyInfo) {
        let message = IMMessageInfo()
        message.body = body.toJSONString()
        message.id = UUID().uuidString
        message.conversationId = self.conversation?.id
        message.createPerson = O2AuthSDK.shared.myInfo()?.distinguishedName
        message.createTime = Date().formatterDate(formatter: "yyyy-MM-dd HH:mm:ss")
        //添加到界面
        self.chatMessageList.append(message)
        self.scrollMessageToBottom()
        //发送消息到服务器
        self.viewModel.sendMsg(msg: message)
            .then { (result) in
                DDLogDebug("发送消息成功 \(result)")
                self.viewModel.readConversation(conversationId: self.conversation?.id)
            }.catch { (error) in
                DDLogError(error.localizedDescription)
                self.showError(title: "发送消息失败!")
        }
    }

    //选择照片
    private func chooseImage() {
        self.choosePhotoWithImagePicker { (fileName, newData) in
            let localFilePath = self.storageLocalImage(imageData: newData, fileName: fileName)
            let msgId = self.prepareForSendImageMsg(filePath: localFilePath)
            self.uploadFileAndSendMsg(messageId: msgId, data: newData, fileName: fileName, type: o2_im_msg_type_image)
        }         
    }
    //临时存储本地
    private func storageLocalImage(imageData: Data, fileName: String) -> String {
        let fileTempPath = FileUtil.share.cacheDir().appendingPathComponent(fileName)
        do {
            try imageData.write(to: fileTempPath)
            return fileTempPath.path
        } catch {
            print(error.localizedDescription)
            return fileTempPath.path
        }
    }
    //发送消息前 先载入界面
    private func prepareForSendImageMsg(filePath: String) -> String {
        let body = IMMessageBodyInfo()
        body.type = o2_im_msg_type_image
        body.body = o2_im_msg_body_image
        body.fileTempPath = filePath
        let message = IMMessageInfo()
        let msgId = UUID().uuidString
        message.body = body.toJSONString()
        message.id = msgId
        message.conversationId = self.conversation?.id
        message.createPerson = O2AuthSDK.shared.myInfo()?.distinguishedName
        message.createTime = Date().formatterDate(formatter: "yyyy-MM-dd HH:mm:ss")
        //添加到界面
        self.chatMessageList.append(message)
        self.scrollMessageToBottom()
        return msgId
    }
    
    private func prepareForSendFileMsg(filePath: String) ->  String {
        let body = IMMessageBodyInfo()
        body.type = o2_im_msg_type_file
        body.body = o2_im_msg_body_file
        body.fileTempPath = filePath
        let message = IMMessageInfo()
        let msgId = UUID().uuidString
        message.body = body.toJSONString()
        message.id = msgId
        message.conversationId = self.conversation?.id
        message.createPerson = O2AuthSDK.shared.myInfo()?.distinguishedName
        message.createTime = Date().formatterDate(formatter: "yyyy-MM-dd HH:mm:ss")
        //添加到界面
        self.chatMessageList.append(message)
        self.scrollMessageToBottom()
        return msgId
    }

    //发送消息前 先载入界面
    private func prepareForSendAudioMsg(tempMessage: IMMessageBodyInfo) -> String {
        let message = IMMessageInfo()
        let msgId = UUID().uuidString
        message.body = tempMessage.toJSONString()
        message.id = msgId
        message.conversationId = self.conversation?.id
        message.createPerson = O2AuthSDK.shared.myInfo()?.distinguishedName
        message.createTime = Date().formatterDate(formatter: "yyyy-MM-dd HH:mm:ss")
        //添加到界面
        self.chatMessageList.append(message)
        self.scrollMessageToBottom()
        return msgId
    }

     

    //上传图片 音频 文档 等文件到服务器并发送消息
    private func uploadFileAndSendMsg(messageId: String, data: Data, fileName: String, type: String) {
        guard let cId = self.conversation?.id else {
            return
        }
        self.viewModel.uploadFile(conversationId: cId, type: type, fileName: fileName, file: data).then { back in
            DDLogDebug("上传文件成功")
            guard let message = self.chatMessageList.first (where: { (info) -> Bool in
                return info.id == messageId
            }) else {
                DDLogDebug("没有找到对应的消息")
                return
            }
            let body = IMMessageBodyInfo.deserialize(from: message.body)
            body?.fileId = back.id
            body?.fileExtension = back.fileExtension
            body?.fileName = back.fileName
            body?.fileTempPath = nil
            message.body = body?.toJSONString()
            //发送消息到服务器
            self.viewModel.sendMsg(msg: message)
                .then { (result) in
                    DDLogDebug("消息 发送成功 \(result)")
                    self.viewModel.readConversation(conversationId: self.conversation?.id)
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "发送消息失败!")
            }
        }.catch { err in
            self.showError(title: "上传错误，\(err.localizedDescription)")
        }
    }
    
    // 选择外部文件
    private func chooseFile() {
        let documentTypes = ["public.content",
                                 "public.text",
                                 "public.source-code",
                                 "public.image",
                                 "public.audiovisual-content",
                                 "com.adobe.pdf",
                                 "com.apple.keynote.key",
                                 "com.microsoft.word.doc",
                                 "com.microsoft.excel.xls",
                                 "com.microsoft.powerpoint.ppt"]
        let picker = UIDocumentPickerViewController(documentTypes: documentTypes, in: .open)
        picker.delegate = self
        self.present(picker, animated: true, completion: nil)
    }
    
    private func playAudioGif(id: String?) {
        self.playingAudioMessageId = id
        self.tableView.reloadData()
    }
    
    private func stopPlayAudioGif() {
        self.playingAudioMessageId = nil
        self.tableView.reloadData()
    }
    
    // 播放audio
    private func playAudio(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            AudioPlayerManager.shared.managerAudioWithData(data, toplay: true)
        } catch {
            DDLogError(error.localizedDescription)
        }
    }


    // MARK: - IBAction
    //点击表情按钮
    @IBAction func clickEmojiBtn(_ sender: UIButton) {
        self.isShowEmoji.toggle()
        self.view.endEditing(true)
        if self.isShowEmoji {
            //audio view 先关闭
            self.isShowAudioView = false
            self.audioBtnView.removeFromSuperview()
            //开始添加emojiBar
            self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat + self.emojiBarHeight.toCGFloat
            self.emojiBar.delegate = self
            self.emojiBar.translatesAutoresizingMaskIntoConstraints = false
            self.bottomBar.addSubview(self.emojiBar)
            let top = NSLayoutConstraint(item: self.emojiBar, attribute: .top, relatedBy: .equal, toItem: self.emojiBar.superview!, attribute: .top, multiplier: 1, constant: CGFloat(self.bottomBarHeight))
            let width = NSLayoutConstraint(item: self.emojiBar, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SCREEN_WIDTH)
            let height = NSLayoutConstraint(item: self.emojiBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.emojiBarHeight.toCGFloat)
            NSLayoutConstraint.activate([top, width, height])
        } else {
            self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat
            self.emojiBar.removeFromSuperview()
        }
        self.view.layoutIfNeeded()
    }

    @IBAction func micBtnClick(_ sender: UIButton) {
        DDLogDebug("点击了麦克风按钮")
        self.isShowAudioView.toggle()
        self.view.endEditing(true)
        if self.isShowAudioView {
            //emoji view 先关闭
            self.isShowEmoji = false
            self.emojiBar.removeFromSuperview()
            //开始添加emojiBar
            self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat + self.emojiBarHeight.toCGFloat
            self.audioBtnView.translatesAutoresizingMaskIntoConstraints = false
            self.bottomBar.addSubview(self.audioBtnView)
            let top = NSLayoutConstraint(item: self.audioBtnView, attribute: .top, relatedBy: .equal, toItem: self.audioBtnView.superview!, attribute: .top, multiplier: 1, constant: CGFloat(self.bottomBarHeight))
            let width = NSLayoutConstraint(item: self.audioBtnView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SCREEN_WIDTH)
            let height = NSLayoutConstraint(item: self.audioBtnView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.emojiBarHeight.toCGFloat)
            NSLayoutConstraint.activate([top, width, height])
        } else {
            self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat
            self.audioBtnView.removeFromSuperview()
        }
        self.view.layoutIfNeeded()
    }

    @IBAction func imgBtnClick(_ sender: UIButton) {
        DDLogDebug("点击了图片按钮")
        self.chooseImage()
    }
    @IBAction func cameraBtnClick(_ sender: UIButton) {
        DDLogDebug("点击了相机按钮")
        self.takePhoto(delegate: self)
    }
    @IBAction func locationBtnClick(_ sender: UIButton) {
        DDLogDebug("点击了位置按钮")
        let vc = IMLocationChooseController.openChooseLocation { (data) in
            self.sendLocationMessage(loc: data)
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }

    @IBAction func fileBtnClick(_ sender: UIButton) {
        DDLogDebug("点击了文件按钮")
        self.chooseFile()
    }
    
    // MARK: - UIMenuController 消息操作
    
    /// 长按事件
    @objc private func longpressEvent(gestureRecognizer: UILongPressGestureRecognizer) {
        if (gestureRecognizer.state == .began) {
            if let cell = gestureRecognizer.view {
                if cell.isKind(of: IMChatMessageSendViewCell.self), let myCell = cell as? IMChatMessageSendViewCell {
                    myCell.becomeFirstResponder()
                    self.showMenu(frame: myCell.frame, msg: myCell.msgInfo)
                }
                if cell.isKind(of: IMChatMessageViewCell.self), let myCell = cell as? IMChatMessageViewCell {
                    myCell.becomeFirstResponder()
                    self.showMenu(frame: myCell.frame, msg: myCell.msgInfo)
                }
            }
        }
    }
    
   
    /// 展现菜单
    private func showMenu(frame: CGRect, msg: IMMessageInfo?) {
        //定义菜单
        var menus:[UIMenuItem] = []
        if self.imConfig.enableRevokeMsg == true, let cp = msg?.createPerson {
            if cp == O2AuthSDK.shared.myInfo()?.distinguishedName {
                //发送者
                menus.append(UIMenuItem(title: "撤回", action: #selector(revokeMsg)))
            } else if self.conversation?.type == o2_im_conversation_type_group &&
                    O2AuthSDK.shared.myInfo()?.distinguishedName == self.conversation?.adminPerson {
                // 群主
                menus.append(UIMenuItem(title: "撤回成员消息", action: #selector(revokeMsg)))
            }
        }
        // 文字消息 添加复制按钮
        if let body = msg?.body, let bodyInfo = IMMessageBodyInfo.deserialize(from: body) {
            if bodyInfo.type == o2_im_msg_type_text {
                menus.append(UIMenuItem(title: "复制", action: #selector(copyTextMsg)))
            }
        }
        if menus.count > 0 {
            self.currentSelectMsg = msg
            UIMenuController.shared.setTargetRect(frame, in: self.tableView)
            UIMenuController.shared.menuItems = menus
            UIMenuController.shared.update()
            UIMenuController.shared.setMenuVisible(true, animated: true)
            DDLogDebug("showMenu")
        }
    }
    
    /// 撤回菜单
    @objc private func revokeMsg() {
        DDLogDebug("点击了撤回消息")
        if let msg = self.currentSelectMsg, let id = msg.id {
            DDLogDebug("撤回消息，id: \(id)")
            self.viewModel.revokeChatMsg(msgId:  id).then { result in
                if result {
                    self.showMessage(msg: "撤回成功！")
                    var newList: [IMMessageInfo] = []
                    for item in self.chatMessageList {
                        if item.id != id {
                            newList.append(item)
                        }
                    }
                    self.chatMessageList = newList
                    self.tableView.reloadData()
                } else {
                    self.showError(title: "撤回失败！")
                }
            }
        }
    }
    
    // 复制文字消息
    @objc private func copyTextMsg() {
        DDLogDebug("复制文字消息")
        if let msg = self.currentSelectMsg, let body = msg.body, let bodyInfo = IMMessageBodyInfo.deserialize(from: body) {
            UIPasteboard.general.string = bodyInfo.body
            self.showSuccess(title: "复制成功！")
        }
    }
    
}

// MARK: - 外部文件选择代理
extension IMChatViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if urls.count > 0 {
            let file = urls[0]
            if file.startAccessingSecurityScopedResource() { //访问权限
                let fileName = file.lastPathComponent
                if let data = try? Data(contentsOf: file) {
                    let fileext = file.pathExtension
                    if O2.isImageExt(fileext) { // 图片消息
                        let localFilePath = self.storageLocalImage(imageData: data, fileName: fileName)
                        let msgId = self.prepareForSendImageMsg(filePath: localFilePath)
                        self.uploadFileAndSendMsg(messageId: msgId, data: data, fileName: fileName, type: o2_im_msg_type_image)
                    }else { // 文件消息
                        let localFilePath = self.storageLocalImage(imageData: data, fileName: fileName)
                        let msgId = self.prepareForSendFileMsg(filePath: localFilePath)
                        self.uploadFileAndSendMsg(messageId: msgId, data: data, fileName: fileName, type: o2_im_msg_type_file)
                    }
                } else {
                    self.showError(title: "读取文件失败")
                }
            } else {
                self.showError(title: "没有获取文件的权限")
            }
        }
        
    }

}

// MARK: - 录音delegate
extension IMChatViewController: IMChatAudioViewDelegate {
    func clickCloseBtn() {
        // 不需要
    }
    
    func clickDoneBtn() {
        // 不需要
    }
    
    
    private func audioRecordingGif() -> UIImage? {
        let url: URL? = Bundle.main.url(forResource: "listener08_anim", withExtension: "gif")
        guard let u = url else {
            return nil
        }
        guard let data = try? Data.init(contentsOf: u) else {
            return nil
        }
        return UIImage.sd_animatedGIF(with: data)
    }
    
    func showAudioRecordingView() {
        if self.voiceIconImage == nil {
            self.voiceImageSuperView = UIView()
            self.view.addSubview(self.voiceImageSuperView!)
            self.voiceImageSuperView?.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6)
             
            self.voiceImageSuperView?.snp_makeConstraints { (make) in
                make.center.equalTo(self.view)
                make.size.equalTo(CGSize(width:140, height:140))
            }
        
            self.voiceIconImage = UIImageView()
            self.voiceImageSuperView?.addSubview(self.voiceIconImage!)
            self.voiceIconImage?.snp_makeConstraints { (make) in
                make.top.left.equalTo(self.voiceImageSuperView!).inset(UIEdgeInsets(top: 20, left: 35, bottom: 0, right: 0))
                make.size.equalTo(CGSize(width: 70, height: 70))
            }
            let voiceIconTitleLabel = UILabel()
            self.voiceIocnTitleLable = voiceIconTitleLabel
            self.voiceIconImage?.addSubview(voiceIconTitleLabel)
            voiceIconTitleLabel.textColor = UIColor.white
            voiceIconTitleLabel.font = .systemFont(ofSize: 12)
            voiceIconTitleLabel.text = "松开发送，上滑取消"
            voiceIconTitleLabel.snp_makeConstraints { (make) in
                make.bottom.equalTo(self.voiceImageSuperView!).offset(-15)
                make.centerX.equalTo(self.voiceImageSuperView!)
            }
        }
        self.voiceImageSuperView?.isHidden = false
        if let gifImage = self.audioRecordingGif() {
            self.voiceIconImage?.image = gifImage
        }else {
            self.voiceIconImage?.image = UIImage(named: "chat_audio_voice")
        }
        self.voiceIocnTitleLable?.text = "松开发送，上滑取消";
       
    }
    
    func hideAudioRecordingView() {
        self.voiceImageSuperView?.isHidden = true
    }
    
    func changeRecordingView2uplide() {
        self.voiceIocnTitleLable?.text = "松开手指，取消发送";
        self.voiceIconImage?.image = UIImage(named: "chat_audio_cancel")
    }
    
    func changeRecordingView2down() {
        if let gifImage = self.audioRecordingGif() {
            self.voiceIconImage?.image = gifImage
        }else {
            self.voiceIconImage?.image = UIImage(named: "chat_audio_voice")
        }
        self.voiceIocnTitleLable?.text = "松开发送，上滑取消";
    }
    
    func sendVoice(path: String, voice: Data, duration: String) {
        let msg = IMMessageBodyInfo()
        msg.fileTempPath = path
        msg.body = o2_im_msg_body_audio
        msg.type = o2_im_msg_type_audio
        msg.audioDuration = duration
        let msgId = self.prepareForSendAudioMsg(tempMessage: msg)
        let fileName = path.split("/").last ?? "MySound.ilbc"
        DDLogDebug("音频文件：\(fileName)")
        self.uploadFileAndSendMsg(messageId: msgId, data: voice, fileName: fileName, type: o2_im_msg_type_audio)
    }
    
}

// MARK: - 拍照delegate
extension IMChatViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage {
            let fileName = "\(UUID().uuidString).png"
            let newData = image.pngData()!
            let localFilePath = self.storageLocalImage(imageData: newData, fileName: fileName)
            let msgId = self.prepareForSendImageMsg(filePath: localFilePath)
            self.uploadFileAndSendMsg(messageId: msgId, data: newData, fileName: fileName, type: o2_im_msg_type_image)
        } else {
            DDLogError("没有选择到图片！")
        }
        picker.dismiss(animated: true, completion: nil)
//        var newData = data
//        //处理图片旋转的问题
//        if imageOrientation != UIImage.Orientation.up {
//            let newImage = UIImage(data: data)?.fixOrientation()
//            if newImage != nil {
//                newData = newImage!.pngData()!
//            }
//        }
//        var fileName = ""
//        if dict?["PHImageFileURLKey"] != nil {
//            let fileURL = dict?["PHImageFileURLKey"] as! URL
//            fileName = fileURL.lastPathComponent
//        } else {
//            fileName = "\(UUID().uuidString).png"
//        }
    }

}

// MARK: - audio 播放 delegate
extension IMChatViewController: AudioPlayerManagerDelegate {
    func didAudioPlayerBeginPlay(_ AudioPlayer: AVAudioPlayer) {
        DDLogDebug("播放开始")
    }
    
    func didAudioPlayerStopPlay(_ AudioPlayer: AVAudioPlayer) {
        DDLogDebug("播放结束")
        self.stopPlayAudioGif()
    }
    
    func didAudioPlayerPausePlay(_ AudioPlayer: AVAudioPlayer) {
        DDLogDebug("播放暂停")
    }
    
    
}

// MARK: - 消息点击 delegate
extension IMChatViewController: IMChatMessageDelegate {
    
    func openApplication(storyboard: String) {
        if storyboard == "mind" {
//            let flutterViewController = O2FlutterViewController()
//            flutterViewController.setInitialRoute("mindMap")
//            flutterViewController.modalPresentationStyle = .fullScreen
//            self.present(flutterViewController, animated: false, completion: nil)
        }else {
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
    
    
    func openLocatinMap(info: IMMessageBodyInfo) {
        IMShowLocationViewController.pushShowLocation(vc: self, latitude: info.latitude, longitude: info.longitude,
                                                      address: info.address, addressDetail: info.addressDetail)
    }
    
    func openImageOrFileMessage(info: IMMessageBodyInfo) {
        if let id = info.fileId {
            self.showLoading()
            var ext = info.fileExtension ?? "png"
            if ext.isEmpty {
                ext = "png"
            }
            O2IMFileManager.shared
                .getFileLocalUrl(fileId: id, fileExtension: ext)
                .always {
                    self.hideLoading()
                }.then { (path) in
                    let currentURL = NSURL(fileURLWithPath: path.path)
                    DDLogDebug(currentURL.description)
                    DDLogDebug(path.path)
                    if QLPreviewController.canPreview(currentURL) {
                        self.previewVC.currentFileURLS.removeAll()
                        self.previewVC.currentFileURLS.append(currentURL)
                        self.previewVC.reloadData()
                        self.pushVC(self.previewVC)
                    } else {
                        self.showError(title: "当前文件类型不支持预览！")
                    }
                }
                .catch { (error) in
                    DDLogError(error.localizedDescription)
                    self.showError(title: "获取文件异常！")
            }
        } else if let temp = info.fileTempPath {
            let currentURL = NSURL(fileURLWithPath: temp)
            DDLogDebug(currentURL.description)
            DDLogDebug(temp)
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
        if self.playingAudioMessageId != nil && self.playingAudioMessageId == id {
            DDLogError("正在播放中。。。。。")
            return
        }
        if let fileId = info.fileId {
            var ext = info.fileExtension ?? "mp3"
            if ext.isEmpty {
                ext = "mp3"
            }
            O2IMFileManager.shared.getFileLocalUrl(fileId: fileId, fileExtension: ext)
                .then { (url) in
                    self.playAudio(url: url)
            }.catch { (e) in
                DDLogError(e.localizedDescription)
            }
        } else if let filePath = info.fileTempPath {
            self.playAudio(url: URL(fileURLWithPath: filePath))
        }
        self.playAudioGif(id: id)
    }
    
    
}

// MARK: - 表情点击 delegate
extension IMChatViewController: IMChatEmojiBarClickDelegate {
    func clickEmoji(emoji: String) {
        DDLogDebug("发送表情消息 \(emoji)")
        self.sendEmojiMessage(emoji: emoji)
    }
}

// MARK: - tableview delegate
extension IMChatViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatMessageList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = self.chatMessageList[indexPath.row]
        let isPlaying = self.playingAudioMessageId == nil ? false : (self.playingAudioMessageId == msg.id)
        if msg.createPerson == O2AuthSDK.shared.myInfo()?.distinguishedName { //发送者
            if let cell = tableView.dequeueReusableCell(withIdentifier: "IMChatMessageSendViewCell", for: indexPath) as? IMChatMessageSendViewCell {
                cell.setContent(item: self.chatMessageList[indexPath.row], isPlayingAudio: isPlaying)
                cell.delegate = self
                let longpress = UILongPressGestureRecognizer()
                longpress.addTarget(self, action: #selector(longpressEvent))
                cell.addGestureRecognizer(longpress)
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "IMChatMessageViewCell", for: indexPath) as? IMChatMessageViewCell {
                cell.setContent(item: self.chatMessageList[indexPath.row], isPlayingAudio: isPlaying)
                cell.delegate = self
                let longpress = UILongPressGestureRecognizer()
                longpress.addTarget(self, action: #selector(longpressEvent))
                cell.addGestureRecognizer(longpress)
                return cell
            }
        }
        return UITableViewCell()
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let msg = self.chatMessageList[indexPath.row]
        return cellHeight(item: msg)
    }
    
    func cellHeight(item: IMMessageInfo) -> CGFloat {
        if let jsonBody = item.body, let body = IMMessageBodyInfo.deserialize(from: jsonBody){
            if body.type == o2_im_msg_type_emoji {
                 // 上边距 69 + emoji高度 + 内边距 + 底部空白高度
                 return 69 + 36 + 20 + 10
            } else if body.type == o2_im_msg_type_image {
                 // 上边距 69 + 图片高度 + 内边距 + 底部空白高度
                 return 69 + 192 + 20 + 10
            } else if o2_im_msg_type_audio == body.type {
                 // 上边距 69 + audio高度 + 内边距 + 底部空白高度
                 return 69 + IMAudioView.IMAudioView_height + 20 + 10
            } else if o2_im_msg_type_location == body.type {
                 // 上边距 69 + 位置图高度 + 内边距 + 底部空白高度
                 return 69 + IMLocationView.IMLocationViewHeight + 20 + 10
            }  else if o2_im_msg_type_file == body.type {
                
                return 69 + IMFileView.IMFileView_height + 20 + 10
            }   else if o2_im_msg_type_process == body.type {
               
                return 69 + IMProcessCardView.IMProcessCardView_height + 20 + 10
            } else {
                if let bodyText = body.body {
                    let size = bodyText.getSizeWithMaxWidth(fontSize: 16, maxWidth: messageWidth)
                    // 上边距 69 + 文字高度 + 内边距 + 底部空白高度
                    return 69 + size.height + 28 + 10
                }
            }
        }
        return 132
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}

// MARK: - textField delegate
extension IMChatViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        DDLogDebug("准备开始输入......")
        closeOtherView()
        return true
    }

    private func closeOtherView() {
        self.isShowEmoji = false
        self.isShowAudioView = false
        self.bottomBarHeightConstraint.constant = self.bottomBarHeight.toCGFloat
        self.view.layoutIfNeeded()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        DDLogDebug("回车。。。。")
        self.sendTextMessage()
        return true
    }
}
