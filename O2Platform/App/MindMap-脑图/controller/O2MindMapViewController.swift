//
//  O2MindMapViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/15.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

let o2MindMapDefaultFolderRoot = "根目录"
let o2MindMapDefaultFolderRootId = "root"

class O2MindMapViewController: UIViewController {

    @IBOutlet weak var folderLabel: UILabel!
    
    @IBOutlet weak var folderBar: UIView! // 目录工具条
    
    @IBOutlet weak var tableView: UITableView!
    
    
    private lazy var currentFolder: MindFolder = {
        let f = MindFolder()
        f.id = o2MindMapDefaultFolderRootId
        f.name = o2MindMapDefaultFolderRoot
        return f
    }()
    private lazy var viewModel: O2MindMapViewModel = {
        return O2MindMapViewModel()
    }()
    
    private var isLoading = false
    private var nextId = O2.O2_First_ID
    private var mindMapList:[MindMapItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "脑图"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .plain, target: self, action: #selector(closeWindow))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "创建", style: .plain, target: self, action: #selector(addMenus))
        
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: {
            DDLogDebug("下拉刷新？？？")
            self.nextId = O2.O2_First_ID
            self.loadMindMapList()
        })
        self.tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            DDLogDebug("上拉加载。。。。。。。。。。。。")
            self.loadMindMapList()
        })
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.folderBar.addTapGesture(target: self, action: #selector(openFolderSelector))
        self.folderLabel.text = currentFolder.name
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.mj_header.beginRefreshing()
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSelectFolder" {
            if let vc = segue.destination as? O2MindSelectViewController {
                vc.currentFolder = self.currentFolder
                vc.delegate = { folder in
                    self.currentFolder = folder
                    self.folderLabel.text = folder.name
                    // 重新查询列表
                    self.nextId = O2.O2_First_ID
                    self.loadMindMapList()
                }
            }
        } else if segue.identifier == "showMindMapCanvas" {
            if let id = sender as? String, let vc = segue.destination as? O2MindMapCanvasController {
                vc.id = id // 设置脑图id
            }
        }
    }
    
    private func loadMindMapList() {
        guard let folderId = self.currentFolder.id else {
            return
        }
        if self.isLoading { // 正在查询
            return
        }
        self.isLoading = true
        if self.nextId == O2.O2_First_ID {
            self.mindMapList = []
        }
        self.viewModel.listMindMapFilter(nextId: nextId, folderId: folderId).then { list in
            for item in list {
                self.mindMapList.append(item)
            }
            self.enRefresh(list: list)
        }.catch { err in
            DDLogError("获取脑图数据错误，\(err.localizedDescription)")
            self.showError(title: "查询出错！")
            self.enRefresh(list: [])
        }
    }
    
    private func enRefresh(list: [MindMapItem]) {
        if list.count < O2.defaultPageSize {
            self.tableView.mj_footer.endRefreshingWithNoMoreData()
        }else{
            self.tableView.mj_footer.endRefreshing()
        }
        self.tableView.mj_header.endRefreshing()
        if list.count > 0 {
            self.nextId = list[list.count - 1].id!
        }
        
        self.tableView.reloadData()
        self.isLoading = false
    }
    
    //新建脑图
    private func createNewMindMap() {
        self.showDefaultConfirm(title: "提示", message: "确定要在当前目录【\(self.currentFolder.name ?? "")】中创建一个脑图？") { action in
            self.showPromptAlert(title: "创建", message: "请输入脑图名称", inputText: "") { action, result in
                if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    self.showError(title: "请输入脑图名称！")
                    return
                }
                self.showLoading()
                self.viewModel.createMindMap(name: result, folderId: self.currentFolder.id ?? "")
                    .then { id in
                        DDLogDebug("保存成功，打开脑图 \(id)")
                        self.openMindMapView(id: id)
                    }.catch { err in
                        DDLogError("创建脑图失败，\(err.localizedDescription)")
                        self.showError(title: "创建脑图失败！")
                    }
            }
        }
    }
    
    private func createNewFolder() {
        self.showDefaultConfirm(title: "提示", message: "确定要在当前目录【\(self.currentFolder.name ?? "")】下创建一个子目录？") { action in
            self.showPromptAlert(title: "创建", message: "请输入目录名称", inputText: "") { action, result in
                if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                    self.showError(title: "请输入目录名称！")
                    return
                }
                self.showLoading()
                self.viewModel.createFolder(name: result, parentId: self.currentFolder.id ?? "")
                    .then { id in
                        DDLogDebug("创建目录成功，\(id)")
                        self.loadFolderListData(id)
                    }.catch { err in
                        DDLogError("创建目录失败，\(err.localizedDescription)")
                        self.showError(title: "创建目录失败！")
                    }
            }
        }
    }
    
    private func loadFolderListData(_ forcreateId: String? = nil) {
        self.viewModel.myFolderTree().then { list in
            self.hideLoading()
            if forcreateId != nil {
                for item in list {
                    if item.id == forcreateId {
                        self.currentFolder = item
                        self.folderLabel.text = item.name
                        // 重新查询列表
                        self.nextId = O2.O2_First_ID
                        self.loadMindMapList()
                    }
                }
            }
        }.catch { error in
            DDLogError(error.localizedDescription)
            self.showError(title: "请求数据异常！")
        }
    }
  
    
    
    //MARK: - private func
    
    @objc func closeWindow() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func addMenus() {
        var menus :[UIAlertAction] = []
         
        let chooseImg = UIAlertAction(title: "新建脑图", style: .default) { (ok) in
            DDLogInfo("新建脑图")
            self.createNewMindMap()
        }
        menus.append(chooseImg)
        let camera = UIAlertAction(title: "新建目录", style: .default) { (ok) in
            DDLogInfo("新建目录")
            self.createNewFolder()
        }
        menus.append(camera)
        self.showSheetAction(title: "新建", message: "", actions: menus)
    }
    
    // 选择目录
    @objc func openFolderSelector() {
        DDLogDebug("打开目录选择")
        self.performSegue(withIdentifier: "showSelectFolder", sender: nil)
    }
    
    // 打开脑图
    @objc func openMindMapView(id: String) {
        DDLogDebug("打开脑图， id: \(id)")
        self.performSegue(withIdentifier: "showMindMapCanvas", sender: id)
    }

}


extension O2MindMapViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mindMapList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MindMapItemTableViewCell", for: indexPath) as? MindMapItemTableViewCell {
            cell.setItem(item: mindMapList[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let id = mindMapList[indexPath.row].id {
            self.openMindMapView(id: id)
        } else {
            DDLogError("mind map item id 为空。。。。。")
        }
    }
}
