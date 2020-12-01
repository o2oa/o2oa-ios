//
//  MeetingFormAttachmentCell.swift
//  O2Platform
//
//  Created by FancyLou on 2020/11/25.
//  Copyright © 2020 zoneland. All rights reserved.
//

import UIKit
import Eureka

class MeetingFormAttachmentCell: Cell<[OOMeetingAttachmentList]>, CellType {

    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var attachmentListView: UITableView!
    
    /// 编辑模式 可以上传和删除
    var editMode = false
    
    var attachmentList: [OOMeetingAttachmentList] = []
    
    /// 上传按钮点击事件
    var uploadAction: (() -> Void)? = nil
    var deleteAction: ((OOMeetingAttachmentList) -> Void)? = nil
    var openFileAction: ((OOMeetingAttachmentList) -> Void)? = nil
    
    override func setup() {
        super.setup()
        selectionStyle = .none
        self.attachmentListView.delegate = self
        self.attachmentListView.dataSource = self
        self.attachmentListView.register(UINib.init(nibName: "MeetingFormAttachmentItemCell", bundle: nil), forCellReuseIdentifier: "MeetingFormAttachmentItemCell")
        self.attachmentListView.tableFooterView = UIView()
        
    }
    
    override func update() {
        super.update()
        print("更新 MeetingFormAttachmentCell")
        textLabel?.text = nil //去掉默认标题
        if editMode {
            self.uploadBtn.isHidden = false
            self.uploadBtn.addTapGesture { (tap) in
                self.uploadAction?()
            }
        }
        if let value = row.value {
            print("有值。。。。。")
            self.attachmentList = value
            self.attachmentListView.reloadData()
        }
    }
    
}


extension MeetingFormAttachmentCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return attachmentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MeetingFormAttachmentItemCell", for: indexPath) as? MeetingFormAttachmentItemCell {
            cell.flushData(atta: self.attachmentList[indexPath.row], editMode: self.editMode)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.attachmentList[indexPath.row]
        if self.editMode {
            self.deleteAction?(item)
        } else {
            self.openFileAction?(item)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
     
    
    
}

final class MeetingFormAttachmentCellRow: Row<MeetingFormAttachmentCell>, RowType {
    
    required init(tag: String?) {
        super.init(tag: tag)
        cellProvider = CellProvider<MeetingFormAttachmentCell>(nibName: "MeetingFormAttachmentCell")
    }
    
}
