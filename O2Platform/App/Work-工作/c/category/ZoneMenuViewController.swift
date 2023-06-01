//
//  ZoneMenuViewController.swift
//  ZoneBarManager
//
//  Created by 刘振兴 on 2017/3/16.
//  Copyright © 2017年 zone. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper
import Promises
import CocoaLumberjack

///
/// 选择器模式
enum ProcessApplicationChooseMode {
    case taskCreateProcess // 默认的 工作创建的时候选择流程
    case application // 选择应用 返回结果
    case process // 选择流程 返回结果
}

typealias ProcessApplicationChooseBack = ( O2Application?, O2ApplicationProcess?) -> Void

class ZoneMenuViewController: UIViewController {
    
    
    private var mainVC:ZoneMainCategoryViewController!
    
    private var subVC:ZoneSubCategoryViewController!
    
    private let o2ProcessAPI = OOMoyaProvider<OOApplicationAPI>()
    
    
    var chooseMode: ProcessApplicationChooseMode = ProcessApplicationChooseMode.taskCreateProcess
    
    var callback: ProcessApplicationChooseBack?
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         notificationInit()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        commonInit()
        loadAppList()
       
    }
    
    private func commonInit(){
        if self.chooseMode == ProcessApplicationChooseMode.taskCreateProcess {
            self.title = "发起工作"
        } else {
            self.title = "选择"
        }
        self.automaticallyAdjustsScrollViewInsets = false
        if self.chooseMode == ProcessApplicationChooseMode.taskCreateProcess
            || self.chooseMode == ProcessApplicationChooseMode.process {
            //mainMenu
            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainMenu") {
                self.mainVC = mainVC as? ZoneMainCategoryViewController
                self.addChild(mainVC)
                mainVC.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width * 0.4, height: view.bounds.height)
                self.view.addSubview(mainVC.view)
            }
            if let subVC = self.storyboard?.instantiateViewController(withIdentifier: "subMenu") {
                self.subVC = subVC as? ZoneSubCategoryViewController
                self.addChild(subVC)
                subVC.view.frame = CGRect(x: view.bounds.width * 0.4, y: 0, width: view.bounds.width * 0.6, height: view.bounds.height)
                //let tView = subVC.view as! UITableView
                //tView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                self.view.addSubview(subVC.view)
            }
        } else {
            if let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "mainMenu") {
                self.mainVC = mainVC as? ZoneMainCategoryViewController
                self.mainVC.initChoose = false
                self.addChild(mainVC)
                mainVC.view.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
                self.view.addSubview(mainVC.view)
            }
        }
    }
    
    private func notificationInit(){
        NotificationCenter.default.addObserver(self, selector: #selector(reveiveCategoryNotification(_:)), name: ZoneMainCategoryViewController.SELECT_MSG_NAME, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveSubNotification(_:)), name: ZoneSubCategoryViewController.SELEC_SUB_ITEM, object: nil)
    }
    
    /// 点击了应用
    @objc private func reveiveCategoryNotification(_ notification:NSNotification){
        DDLogDebug("选择了 应用")
        let obj = notification.object
        if self.chooseMode == ProcessApplicationChooseMode.application {
            self.callback?(obj as? O2Application, nil)
            self.popVC()
        } else  {
            if let app = obj as? O2Application {
                DispatchQueue.main.async {
                    self.subVC.processList = app.processList ?? []
                }
            }
        }
    }
    
    /// 点击了流程
    @objc private func receiveSubNotification(_ notification:NSNotification){
        DDLogDebug("选择了 流程")
        let obj = notification.object
        if self.chooseMode == ProcessApplicationChooseMode.taskCreateProcess {
            loadDepartAndIdentity(process: obj as? O2ApplicationProcess)
        } else {
            self.callback?(nil, obj as? O2ApplicationProcess)
            self.popVC()
        }
    }
    
    
    func loadAppList(){
        self.showLoading(title: "应用加载中...")
        // 这个接口查询当前用户能看到的全部的应用（包含流程）
        self.o2ProcessAPI.request(.applicationListByTerminal, completion: {result in
            let response = OOResult<BaseModelClass<[O2Application]>>(result)
            if response.isResultSuccess() {
                let list = response.model?.data
                if let apps = list {
                    var appMap =  [String: [O2Application]]()
                    for app in apps {
                        if let pList = app.processList, pList.count > 0 {
                            var category = app.applicationCategory ?? ""
                            if category == "" {
                                category = "未分类"
                            }
                            var newAppList = appMap[category] ?? []
                            newAppList.append(app)
                            appMap[category] = newAppList
                        }
                    }
                    var appList: [O2AppByCategory] = []
                    if !appMap.isEmpty {
                        for (key, list) in appMap {
                            appList.append(O2AppByCategory(category: key, app: nil))
                            for app in list {
                                appList.append(O2AppByCategory(category: nil, app: app))
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.showSuccess(title: "加载完成")
                        self.mainVC.appList = appList
                    }
                }else {
                   DispatchQueue.main.async { self.showError(title: "没有应用数据！") }
                }
            }else {
                DDLogError(response.error?.errorDescription ?? "")
                DispatchQueue.main.async { self.showError(title: "加载失败") }
            }
        })
        
    }
    
    //获取身份列表
    func loadDepartAndIdentity(process: O2ApplicationProcess?){
        if process == nil {
            self.showError(title: "流程信息获取失败！")
            return
        }
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(TaskContext.taskContextKey, query: TaskContext.todoCreateAvaiableIdentityByIdQuery, parameter: ["##processId##": process!.id as AnyObject])
        
        AF.request(url!).responseArray(keyPath: "data", context: nil, completionHandler: { (response:AFDataResponse<[IdentityV2]>) in
            switch response.result {
            case .success(let identitys):
                if identitys.count > 1 { // 多身份需要去选择身份
                    let data = TaskCreateData(process: process, identitys: identitys)
                    self.gotoChooseIdentity(data: data)
                }else if identitys.count == 1 {
                    //草稿模式
                    if let mode = process?.defaultStartMode, mode == O2.O2_Word_draft_mode {
                        self.createDraft(processId: process!.id!, identity: identitys[0].distinguishedName!)
                    }else {
                        self.createProcess(processId: process!.id!, identity: identitys[0].distinguishedName!)
                    }
                }else {
                    DispatchQueue.main.async {
                        self.showError(title: "当前用户没有身份，无法创建工作！")
                    }
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                DispatchQueue.main.async {
                    self.showError(title: "读取身份列表失败")
                }
            }
        })
    }
    
    //创建草稿
    private func createDraft(processId: String, identity: String) {
        let bean = CreateProcessBean()
               bean.title = ""
               bean.identity = identity
        let draftCreateUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(WorkContext.workContextKey, query: WorkContext.draftWorkCreateQuery, parameter: ["##processId##":processId as AnyObject])
        self.showLoading(title: "创建中，请稍候...")
        AF.request(draftCreateUrl!,method:.post, parameters: bean.toJSON(), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            
            switch response.result {
            case .success(let val):
                let draftData = JSON(val)["data"]
                DDLogDebug(draftData.description)
                if let draft = Mapper<ProcessDraftBean>().map(JSONString:draftData["work"].debugDescription) {
                    let taskStoryboard = UIStoryboard(name: "task", bundle: Bundle.main)
                    let todoTaskDetailVC = taskStoryboard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
                    todoTaskDetailVC.draft = draft
                    todoTaskDetailVC.backFlag = 1
                    self.navigationController?.pushViewController(todoTaskDetailVC, animated: true)
                    DispatchQueue.main.async {
                        self.hideLoading()
                    }
                } else {
                    self.showError(title: "创建失败")
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.showError(title: "创建失败")
            }
        }
    }
    
    //创建流程
    private func createProcess(processId: String, identity:String){
        let bean = CreateProcessBean()
        bean.title = ""
        bean.identity = identity
        let createURL = AppDelegate.o2Collect.generateURLWithAppContextKey(WorkContext.workContextKey, query: WorkContext.workCreateQuery, parameter: ["##id##":processId as AnyObject])
        self.showLoading(title: "创建中，请稍候...")
        AF.request(createURL!,method:.post, parameters: bean.toJSON(), encoding: JSONEncoding.default, headers: nil).responseJSON { response in
            switch response.result {
            case .success(let val):
                let taskList = JSON(val)["data"][0]
                DDLogDebug(taskList.description)
                if let tasks = Mapper<TodoTask>().mapArray(JSONString:taskList["taskList"].debugDescription) , tasks.count > 0 {
                    let taskStoryboard = UIStoryboard(name: "task", bundle: Bundle.main)
                    let todoTaskDetailVC = taskStoryboard.instantiateViewController(withIdentifier: "todoTaskDetailVC") as! TodoTaskDetailViewController
                    todoTaskDetailVC.todoTask = tasks[0]
                    todoTaskDetailVC.backFlag = 1
                    self.navigationController?.pushViewController(todoTaskDetailVC, animated: true)
                    DispatchQueue.main.async {
                        self.hideLoading()
                    }
                } else {
                    self.showError(title: "创建失败")
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                self.showError(title: "创建失败")
            }
        }
    }
    //进入身份选择页面 创建流程
    private func gotoChooseIdentity(data: TaskCreateData) {
        self.performSegue(withIdentifier: "showStartFlowSegue", sender: data)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStartFlowSegue" {
            let destVc = segue.destination as! TaskCreateViewController
            if sender is TaskCreateData {
                let data = sender as? TaskCreateData
                destVc.process = data?.process
                //主身份排序
                if let identitys = data?.identitys {
                    var newArray = identitys
                    newArray.sort { (first, second) -> Bool in
                        if second.major == true {
                            return false
                        } else  {
                            return true
                        }
                    }
                    destVc.identitys = newArray
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
