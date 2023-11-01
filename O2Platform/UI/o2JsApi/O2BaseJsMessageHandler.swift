//
//  O2BaseJsMessageHandler.swift
//  O2Platform
//
//  Created by FancyLou on 2019/4/26.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit
import WebKit
import Alamofire
import ObjectMapper
import CocoaLumberjack
import BSImagePicker
import Photos



class O2BaseJsMessageHandler: NSObject, O2WKScriptMessageHandlerImplement {
    
    let viewController: BaseWebViewUIViewController
    
    var uploadImageData: O2WebViewUploadImage? = nil
    
    init(viewController: BaseWebViewUIViewController) {
        self.viewController = viewController
    }
    
    
    func userController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let name = message.name
        switch name {
        case "o2mLog":
            if message.body is NSString {
                let log = message.body as! NSString
                DDLogDebug("console.log: \(log)")
            }else {
                DDLogDebug("console.log: unkown type \(message.body)")
            }
            break
        case "ReplyAction":
            DDLogDebug("回复 帖子 message.body = \(message.body)")
            if !O2AuthSDK.shared.isBBSMute() {
                let pId : String?
                if message.body is NSDictionary {
                    let parentId:NSDictionary = message.body as! NSDictionary
                    pId = parentId["body"] as? String
                }else if message.body is NSString {
                    pId = String(message.body as! NSString)
                }else {
                    pId = nil
                }
                self.viewController.performSegue(withIdentifier: "showReplyActionSegue", sender: pId)
            } else {
                DDLogError("当前用户已被禁言！")
            }
            break
        case "openO2Work":
            DDLogDebug("打开工作界面。。。。。")
            let body = message.body
            if body is NSDictionary {
                let dic = body as! NSDictionary
                let work = dic["work"] as? String
                let workCompleted = dic["workCompleted"] as? String
                let title = dic["title"] as? String
                self.openWork(work: (work ?? ""), workCompleted: (workCompleted ?? ""), title: (title ?? ""))
            }else {
                DDLogError("message body 不是一个字典。。。。。。")
            }
            break
        case "openO2WorkSpace":
            DDLogDebug("打开工作列表。。。。。")
            if message.body is NSString {
                let type = message.body as! NSString
                self.openO2WorkSpace(type: String(type))
            }else {
                DDLogError("打开工作列表失败， type不存在！！！！！")
            }
            break
        case "openO2CmsApplication":
            DDLogDebug("打开cms栏目。。。。。")
            if message.body is NSString {
                let appId = message.body as! NSString
                self.openCmsApplication(appId: String(appId))
            }else if message.body is NSDictionary {
                let appBody = message.body as! NSDictionary
                if let appId = appBody["appId"] {
                    self.openCmsApplication(appId: (appId as! String))
                }
            }else {
                DDLogError("打开cms栏目失败， appId不存在！！！！！")
            }
            break
        case "createO2CmsDocument":
            DDLogDebug("创建cms文档。。。。。")
            if message.body is NSDictionary {
               let appBody = message.body as! NSDictionary
               let appId = appBody["column"] as? String
               let categoryId = appBody["category"] as? String
                if appId != nil && !appId!.isBlank {
                    self.createO2CmsDocument(appId: appId!, categoryId: categoryId)
                } else {
                    self.viewController.showError(title: "缺少 column 参数，目前移动端必须传入 column 参数")
                }
                
            }else {
               DDLogError("创建cms文档失败， appId不存在！！！！！")
                self.viewController.showError(title: "缺少 column 参数，目前移动端必须传入 column 参数")
            }
            break
        case "openO2CmsDocument":
            DDLogDebug("打开cms 文档。。。。。")
            if message.body is NSDictionary {
                let appBody = message.body as! NSDictionary
                let docId = appBody["docId"] as? String
                let docTitle = appBody["docTitle"] as? String
                var readonly = true
                if let options = appBody["options"] as? String {
                    DDLogDebug("options json: \(options)")
                    let optionJson = JSON(parseJSON: options)
                    if let re = optionJson["readonly"].bool {
                        readonly = re
                    }
                }
                self.openCmsDocument(docId: (docId ?? "" ), docTitle: (docTitle ?? ""), readonly: readonly)
            }else {
                DDLogError("打开cms文档失败， 参数不存在！！！！！")
            }
            break
        case "openO2Meeting":
            DDLogDebug("打开会议管理。。。。。")
            self.openO2Meeting()
            break
        case "openO2Calendar":
            DDLogDebug("打开日程管理。。。。。")
            self.openO2Calendar()
            break
        case "openScan":
            self.openScan()
            break
        case "openO2Alert":
            if message.body is NSString {
                let msg = message.body as! NSString
                self.openO2Alert(message: String(msg))
            }
            break
        case "closeNativeWindow":
            DDLogDebug("关闭窗口！！！！")
            self.viewController.delegate?.closeUIViewWindow()
            break
        case "openDingtalk":
            self.openDingtalk()
            break
        case "actionBarLoaded":
            self.viewController.delegate?.actionBarLoaded(show: true)
            break
        case "uploadImage2FileStorage":
            DDLogDebug("这里进入了上传图片控件。。。。。。。。。。。。。。。")
            if message.body is NSString {
                let json = message.body as! NSString
                DDLogDebug("上传图片:\(json)")
                if let uploadImage = O2WebViewUploadImage.deserialize(from: String(json)) {
                    self.uploadImageData = uploadImage
                    self.uploadImageData?.scale = 800
                    // 显示菜单 选择拍照或相册
                    DispatchQueue.main.async {
                        self.viewController.showSheetAction(title: "提示", message: "请选择方式", actions: [
                            UIAlertAction(title: "从相册选择", style: .default, handler: { (action) in
                                self.chooseFromAlbum()
                            }),
                            UIAlertAction(title: "拍照", style: .default, handler: { (action) in
                                self.takePhoto()
                            })
                        ])
                    }
                }else {
                    DDLogError("解析json失败")
                    self.viewController.showError(title: "参数不正确！")
                }
            }else {
                DDLogError("传入参数类型不正确！")
                self.viewController.showError(title: "参数不正确！")
            }
            break
        default:
            DDLogError("传入js变量名称不正确，name:\(name)")
            if message.body is NSString {
                let json = message.body as! NSString
                DDLogDebug("console.log: \(json)")
            }
            break
        }
        
        
    }
    
    
    private func openO2Alert(message: String) {
        DDLogDebug("O2 alert msg:\(message)")
        self.viewController.showSystemAlert(title: "", message: message) { (action) in
            DDLogDebug("O2 alert ok button clicked! ")
        }
    }
    
    
    private func openWork(work: String, workCompleted: String, title: String) {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
//        let json = """
//        {"work":"\(work)", "workCompleted":"\(workCompleted)", "title":"\(title)"}
//        """
//        DDLogDebug("openWork json: \(json)")
        let todo = TodoTask(JSONString: "{}")
        todo?.work = work
        todo?.workCompleted = workCompleted
        todo?.title = title
        destVC.todoTask = todo
        destVC.backFlag = 3 //隐藏就行
        self.viewController.show(destVC, sender: nil)
    }
    
    // task taskCompleted read readCompleted
    private func openO2WorkSpace(type: String) {
        let storyBoard = UIStoryboard(name: "task", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "todoTask")
        let nsType = NSString(string: type).lowercased
        DDLogDebug("打开工作区， type：\(nsType)")
        if "taskcompleted" == nsType {
            AppConfigSettings.shared.taskIndex = 2
        }else if "read" == nsType {
            AppConfigSettings.shared.taskIndex = 1
        }else if "readcompleted" == nsType {
            AppConfigSettings.shared.taskIndex = 3
        }else {
            AppConfigSettings.shared.taskIndex = 0
        }
        self.viewController.show(destVC, sender: nil)
    }
    
    /// 打开cms栏目
    private func openCmsApplication(appId: String) {
        DDLogInfo("打开栏目， appId：\(appId)")
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(CMSContext.cmsContextKey, query: CMSContext.cmsCategoryQuery, parameter: nil)
        self.viewController.showLoading(title: "Loading...")
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let val):
                let result = Mapper<CMSApplication>().map(JSONObject: val)
                let appList = result?.data ?? []
                let app = appList.first { data in
                    return data.id == appId
                }
                if app != nil {
                    let storyBoard = UIStoryboard(name: "information", bundle: nil)
                    let destVC = storyBoard.instantiateViewController(withIdentifier: "CMSCategoryListController") as! CMSCategoryListViewController
                    destVC.title = app?.appName ?? ""
                    destVC.cmsData = app
                    self.viewController.show(destVC, sender: nil)
                }
                self.viewController.hideLoading()
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.viewController.hideLoading()
            }
        }
        
    }
    
    /// 创建cms文档
    private var cmsData: CMSData?
    private var cmsCategoryList: [CMSWrapOutCategoryList] = []
    private var selectedCategory: CMSWrapOutCategoryList?
    private func createO2CmsDocument(appId: String, categoryId:String?) {
        DDLogInfo("打开文档， appId：\(appId) , categoryId:\(String(describing: categoryId)) ")
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(CMSContext.cmsContextKey, query: CMSContext.cmsCanPublishCategoryQuery, parameter: ["##appId##": appId as AnyObject])
        DDLogDebug("查询cms栏目 url： \(String(describing: url))")
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let val):
                DDLogDebug(JSON(val).description)
                let res = Mapper<CMSSingleApplication>().map(JSONObject: val)
                self.cmsData = res?.data
                if self.cmsData != nil && self.cmsData?.wrapOutCategoryList != nil && (self.cmsData?.wrapOutCategoryList?.count ?? 0) > 0 {
                    self.cmsCategoryList = self.cmsData!.wrapOutCategoryList!
                    if categoryId != nil && categoryId != "" {
                        for item in self.cmsCategoryList {
                            if item.id == categoryId || item.categoryName == categoryId || item.categoryAlias == categoryId {
                                self.selectedCategory = item
                                break
                            }
                        }
                        if self.selectedCategory != nil {
                            self.checkDraftThenJump(categoryId: self.selectedCategory!.id)
                        }
                    } else {
                        self.showChooseCategroyList()
                    }
                } else {
                    self.viewController.showError(title: "当前栏目没有分类信息，无法创建文档！")
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.viewController.showError(title: "没有栏目信息，无法创建文档！")
            }
        }
    }
    
    // 点击新建按钮显示需要发布的分类列表
    private func showChooseCategroyList() {
        var actions: [UIAlertAction] = []
        self.cmsCategoryList.forEach { (category) in
            let item = UIAlertAction(title: "\(category.categoryName ?? "")", style: .default, handler: { (action) in
                self.selectedCategory = category
                self.checkDraftThenJump(categoryId: category.id)
            })
            actions.append(item)
        }
        self.viewController.showSheetAction(title: "分类", message: "请选择发布的分类", actions: actions)
    }
    
    //检查选择的分类下是否有未完成的草稿， 有草稿就直接跳转到编辑页面，没有就到新建页面
    private func checkDraftThenJump(categoryId: String?) {
        let model = CommonPageModel().toDictionary()
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(CMSContext.cmsContextKey, query: CMSContext.cmsDocumentDraftQuery, parameter: model as [String : AnyObject]?)
        var params:[String: Any] = [:]
        params["categoryIdList"] = [categoryId]
        if let distinguishedName = O2AuthSDK.shared.myInfo()?.distinguishedName {
            params["creatorList"] = [distinguishedName]
        }
        params["documentType"] = "全部"
        AF.request(url!, method: .put, parameters: params, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
            case .success(let val):
                DDLogDebug(JSON(val).description)
                var needLatest = false
                if let configJson = self.cmsData?.config, !configJson.isEmpty {
                    if let config = try? CMSAppConfig(configJson) {
                        if let latest = config.latest, latest == false {
                            needLatest = true
                        }
                    }
                }
                if needLatest {
                    self.gotoNewDocController()
                }else {
                    let res = Mapper<CMSCategory>().map(JSONObject: val)
                    if let docList = res?.data, docList.count > 0 {
//                        self.performSegue(withIdentifier: "showDetailContentSegue", sender: docList[0])
                        self.openCmsDocument(docId: docList[0].id!, docTitle: docList[0].title ?? "", readonly: false)
                    }else {
                        self.gotoNewDocController()
                    }
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.gotoNewDocController()
            }
        }
    }
    
    private func gotoNewDocController() {
        let storyBoard = UIStoryboard(name: "information", bundle: nil)
        let destVC = storyBoard.instantiateViewController(withIdentifier: "CMSDocumentCreateVC") as! CMSCreateDocViewController
        if let configJson = self.cmsData?.config, !configJson.isEmpty {
            if let config = try? CMSAppConfig(configJson) {
                destVC.config = config
            }
        }
        destVC.category = self.selectedCategory
        self.viewController.show(destVC, sender: nil)
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
        self.viewController.show(destVC, sender: nil)
    }
    
    private func openO2Meeting() {
        let storyBoard = UIStoryboard(name: "meeting", bundle: nil)
        if let destVC = storyBoard.instantiateInitialViewController() {
            self.viewController.show(destVC, sender: nil)
        }else {
            DDLogError("会议 模块打开失败，没有找到vc")
        }
    }
    
    private func openO2Calendar() {
        let storyBoard = UIStoryboard(name: "calendar", bundle: nil)
        if let destVC = storyBoard.instantiateInitialViewController() {
            self.viewController.show(destVC, sender: nil)
        }else {
            DDLogError("calendar 模块打开失败，没有找到vc")
        }
    }
    
    private func openScan() {
        ScanHelper.openScan(vc: self.viewController)
    }
    
    private func openDingtalk() {
        UIApplication.shared.open(URL(string: "dingtalk://dingtalkclient/")!, options: [:]) { (result) in
            DDLogInfo("打开了钉钉。。。。\(result)")
        }
    }
    
    // 表单图片控件 从相册选择
    private func chooseFromAlbum() {
        let vc = FileBSImagePickerViewController().bsImagePicker()
        self.viewController.presentImagePicker(vc, select: nil, deselect: nil, cancel: nil, finish: { (arr) in
            let count = arr.count
            DDLogDebug("选择了照片数量：\(count)")
            if count > 0 {
                //获取照片
                let asset = arr[0]
                if asset.mediaType == .image {
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    options.deliveryMode = .fastFormat
                    options.resizeMode = .fast //.none
                    var fName = (asset.value(forKey: "filename") as? String) ?? "untitle.png"
                    // 判断是否是heif
                    var isHEIF = false
                    if #available(iOS 9.0, *) {
                        let resList = PHAssetResource.assetResources(for: asset)
                        resList.forEachEnumerated { (idx, res) in
                            let uti = res.uniformTypeIdentifier
                            if uti == "public.heif" || uti == "public.heic" {
                                isHEIF = true
                            }
                        }
                    } else {
                        if let uti = asset.value(forKey: "uniformTypeIdentifier") as? String {
                            if uti == "public.heif" || uti == "public.heic" {
                                isHEIF = true
                            }
                        }
                    }
                    PHImageManager.default().requestImageData(for: asset, options: options, resultHandler: { (imageData, result, imageOrientation, dict) in
                        DispatchQueue.main.async {
                            self.viewController.showLoading(title: "上传中...")
                        }
                        var newData = imageData
                        if isHEIF {
                            let image: UIImage = UIImage(data: imageData!)!
                            newData = image.jpegData(compressionQuality: 1.0)!
                            fName += ".jpg"
                        }
                        //处理图片旋转的问题
                        if imageOrientation != UIImage.Orientation.up && newData != nil {
                            let newImage = UIImage(data: newData!)?.fixOrientation()
                            if newImage != nil {
                                newData = newImage?.pngData()
                            }
                        }
                        self.uploadImage2Server(imageData: newData!, fName: fName)
                        
                    })
                    
                }else {
                    DDLogError("选择类型不正确，不是照片")
                }
                
            }
        }, completion: nil)
    }

    // 表单图片控件 拍照功能
    private func takePhoto() {
        self.viewController.takePhoto(delegate: self)
    }
    
    //表单图片控件 上传图片到服务器
    private func uploadImage2Server(imageData: Data, fName: String) {
        guard let data = self.uploadImageData else {
            self.viewController.showError(title: "参数传入为空，无法上传图片")
            return
        }
        if data.callback == nil || data.callback.isEmpty || data.reference == nil || data.reference.isEmpty
            || data.referencetype == nil || data.referencetype.isEmpty {
            self.viewController.showError(title: "参数传入为空，无法上传图片")
            return
        }
        
        let fileUploadURL = AppDelegate.o2Collect
            .generateURLWithAppContextKey(
                FileContext.fileContextKey,
                query: FileContext.fileUploadReference,
                parameter: [
                    "##referencetype##": data.referencetype as AnyObject,
                    "##reference##": data.reference as AnyObject,
                    "##scale##": String(data.scale) as AnyObject
                ],
                coverted: true)!
        DDLogDebug(fileUploadURL)
        let tokenName = O2AuthSDK.shared.tokenName()
        let headers:HTTPHeaders = [tokenName:(O2AuthSDK.shared.myInfo()?.token!)!]
        
        DispatchQueue.global(qos: .userInitiated).async {
            AF.upload(multipartFormData: { (mData) in
                mData.append(imageData, withName: "file", fileName: fName, mimeType: "image/png")
            }, to: fileUploadURL, method: .put, headers: headers).responseJSON { (response) in
                if let err = response.error {
                    DispatchQueue.main.async {
                        DDLogError(err.localizedDescription)
                        self.viewController.showError(title: "上传图片失败")
                    }
                } else {
                    if let resData = response.data {
                        let attachId = JSON(resData)["data"]["id"].string!
                        data.fileId = attachId
                    }
                    let callback = data.callback!
                    let callbackParameterJson = data.toJSONString()
                    if callbackParameterJson != nil {
                        DDLogDebug("json:\(callbackParameterJson!)")
                        DispatchQueue.main.async {
                            let callJS = "\(callback)('\(callbackParameterJson!)')"
                            DDLogDebug("执行js：\(callJS)")
                            self.viewController.webView.evaluateJavaScript(callJS, completionHandler: { (result, err) in
                                self.viewController.showSuccess(title: "上传成功")
                            })
                        }
                    }
                }
            }
        }
    }

}

// MARK: - 拍照返回
extension O2BaseJsMessageHandler: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.editedImage] as? UIImage, let newData = image.pngData() {
            let fileName = "\(UUID().uuidString).png"
//            let size = image.size
            self.uploadImage2Server(imageData: newData, fName: fileName)
        } else {
            DDLogError("没有选择到图片！")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
