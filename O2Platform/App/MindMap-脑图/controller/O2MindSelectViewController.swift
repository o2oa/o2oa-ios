//
//  O2MindSelectViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/15.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

 
typealias O2MindSelectFolerDelegate = (_ folder: MindFolder) -> Void


class O2MindSelectViewController: UITableViewController {
    
    private let FolderCellName = "FolderTreeTableViewCell"
    
    lazy var currentFolder: MindFolder = {
        let f = MindFolder()
        f.id = o2MindMapDefaultFolderRootId
        f.name = o2MindMapDefaultFolderRoot
        return f
    }()
    
    var folderList:[MindFolder] = []
    
    var delegate: O2MindSelectFolerDelegate?
    
    private lazy var viewModel: O2MindMapViewModel = {
        return O2MindMapViewModel()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "目录"
        self.tableView.register(FolderTreeTableViewCell.self, forCellReuseIdentifier: FolderCellName)
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.loadData()
    }
    
    private func loadData() {
        self.showLoading()
        self.viewModel.myFolderTree().then { list in
            self.hideLoading()
            self.folderList = list
            self.tableView.reloadData()
        }.catch { error in
            DDLogError(error.localizedDescription)
//            self.showError(title: "请求数据异常！")
            self.hideLoading()
        }
    }
  


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: FolderCellName, for: indexPath) as? FolderTreeTableViewCell {
            let model = folderList[indexPath.row]
            if currentFolder.id != nil && currentFolder.id == model.id {
                model.selected = true
            } else {
                model.selected = false
            }
            cell.setFolderModel(folder: model)
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
     
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        self.delegate?(self.folderList[indexPath.row])
        self.popVC()
    }
    
    private func showEditMenu(folder: MindFolder) {
        var menus :[UIAlertAction] = []
        let chooseImg = UIAlertAction(title: "重命名", style: .default) { (ok) in
            self.renameFolder(folder: folder)
        }
        menus.append(chooseImg)
        let camera = UIAlertAction(title: "删除目录", style: .default) { (ok) in
            self.deleteFolder(folder: folder)
        }
        menus.append(camera)
        self.showSheetAction(title: "菜单", message: "", actions: menus)
    }
    
    private func deleteFolder(folder: MindFolder) {
        DDLogInfo("删除目录")
        self.showDefaultConfirm(title: "提示", message: "确定要删除目录【\(folder.name ?? "")】?") { action in
            self.showLoading()
            self.viewModel.deleteFolder(id: folder.id!)
                .then { id in
                    DDLogDebug("删除成功，\(id)")
                    self.hideLoading()
                    if self.currentFolder.id == folder.id {
                        if let first = self.folderList.first(where: { f in
                            f.id != self.currentFolder.id
                        }) {
                            self.delegate?(first)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.popVC()
                    }
                }.catch { err in
                    DDLogError("删除目录失败，\(err.localizedDescription)")
                    self.hideLoading()
                    if self.currentFolder.id == folder.id {
                        if let first = self.folderList.first(where: { f in
                            f.id != self.currentFolder.id
                        }) {
                            self.delegate?(first)
                            
                        }
                    }
                    DispatchQueue.main.async {
                        self.popVC()
                    }
                }
        }
    }
    private func renameFolder(folder: MindFolder) {
        DDLogInfo("重命名")
        self.showPromptAlert(title: "重命名", message: "请输入目录名称", inputText: folder.name ?? "") { action, result in
            if result == "" || result.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.showError(title: "请输入目录名称！")
                return
            }
            self.showLoading()
            self.viewModel.renameFolder(name: result, folder: folder)
                .then { id in
                    DDLogDebug("重命名成功，\(id)")
                    self.hideLoading()
                    if self.currentFolder.id == id {
                        self.currentFolder.name = result
                        self.delegate?(self.currentFolder)
                    }
                    DispatchQueue.main.async {
                        self.popVC()
                    }
                }.catch { err in
                    DDLogError("重命名目录失败，\(err.localizedDescription)")
                    self.showError(title: "重命名目录失败！")
                }
        }
    }
    
}
 

extension O2MindSelectViewController: FolderTreeTableViewCellDelegate {
    
    func editFolder(_ folder: MindFolder) {
        DDLogDebug("操作目录： \(folder.name ?? "")")
        self.showEditMenu(folder: folder)
    }
    
    
}
