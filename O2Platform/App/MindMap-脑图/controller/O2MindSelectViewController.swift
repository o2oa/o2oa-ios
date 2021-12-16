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
            self.showError(title: "请求数据异常！")
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
    
}
 
