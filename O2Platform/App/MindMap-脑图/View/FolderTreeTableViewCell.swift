//
//  FolderTreeTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/15.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol FolderTreeTableViewCellDelegate {
    func editFolder(_ folder: MindFolder)
}

class FolderTreeTableViewCell: UITableViewCell {
    
    var folderNameLabel: UILabel!
    
    var deleteBtn: UIButton!
    
    var folder: MindFolder?
    
    var delegate: FolderTreeTableViewCellDelegate?
    
    let offset:CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        DDLogDebug("Initialization cell。。。。。。")
        self.folderNameLabel = UILabel()
        self.folderNameLabel.textColor = .black
        self.contentView.addSubview(self.folderNameLabel)
        self.deleteBtn = UIButton(type: UIButton.ButtonType.system)
        self.deleteBtn.setImage(UIImage(named: "icon_more_s"), for: .normal)
        self.deleteBtn.tintColor = UIColor(hex: "#999999")
//        self.deleteBtn.backgroundColor = UIColor.red
//        self.deleteBtn.setTitle("删除", for: .normal)
//        self.deleteBtn.setTitleColor(UIColor.white, for: .normal)
        self.contentView.addSubview(self.deleteBtn)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = self.contentView.frame.size.width
        let height = self.contentView.frame.size.height
        if folder != nil {
            if folder?.id != o2MindMapDefaultFolderRootId {
                self.deleteBtn.isHidden = false
                self.deleteBtn.frame = CGRect(x: width - 48, y: 0, width: 48, height: height)
                self.deleteBtn.addTapGesture { t in
                    self.delegate?.editFolder(self.folder!)
                }
            } else {
                self.deleteBtn.isHidden = true
            }
            
            let left = offset * CGFloat(folder?.level ?? 1)
            let labelWidth = width - offset - left
            let labelHeigth = height - (offset * 2)
            self.folderNameLabel.frame = CGRect(x: left, y: offset, width: labelWidth, height: labelHeigth)
            if folder?.selected == true {
                self.folderNameLabel.textColor = base_color
            } else {
                self.folderNameLabel.textColor = .black
            }
        } else {
            DDLogError("没有数据。。。。。。。。。。")
        }
    }
    
    func setFolderModel(folder: MindFolder) {
        self.folder = folder
        self.folderNameLabel.text = self.folder?.name
    }

}
