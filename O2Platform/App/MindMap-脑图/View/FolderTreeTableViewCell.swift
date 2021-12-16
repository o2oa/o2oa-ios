//
//  FolderTreeTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/15.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class FolderTreeTableViewCell: UITableViewCell {
    
    var folderNameLabel: UILabel!
    
    var folder: MindFolder?
    
    let offset:CGFloat = 10
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // Initialization code
        DDLogDebug("Initialization cell。。。。。。")
        self.folderNameLabel = UILabel()
        self.folderNameLabel.textColor = .black
        self.contentView.addSubview(self.folderNameLabel)
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
