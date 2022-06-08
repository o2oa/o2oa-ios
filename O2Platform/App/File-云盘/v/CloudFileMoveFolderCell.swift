//
//  CloudFileMoveFolderCell.swift
//  O2Platform
//
//  Created by FancyLou on 2019/10/25.
//  Copyright © 2019 zoneland. All rights reserved.
//

import UIKit

protocol CloudFileMoveChooseDelegate {
    func choose(folder: OOFolder)
}
protocol CloudFileMoveV3ChooseDelegate {
    func choose(folder: OOFolderV3)
}

class CloudFileMoveFolderCell: UITableViewCell {
    
    @IBOutlet weak var chooseBtn: UIButton!
    
    @IBOutlet weak var folderNameLabel: UILabel!
    @IBOutlet weak var folderTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.chooseBtn.setTitleColor(base_color, for: .normal)
    }
    
    @IBAction func chooseAction(_ sender: UIButton) {
        if self.folder != nil {
            self.delegate?.choose(folder: self.folder!)
        }
        if self.folderV3 != nil {
            self.delegatev3?.choose(folder: self.folderV3!)
        }
    }
    
    
    var folder: OOFolder?
    var folderV3: OOFolderV3?
    var delegate: CloudFileMoveChooseDelegate?
    var delegatev3: CloudFileMoveV3ChooseDelegate?
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //添加数据
    func setData(folder: OOFolder) {
        self.folder = folder
        self.folderV3 = nil
        self.folderNameLabel.text = folder.name ?? ""
        self.folderTimeLabel.text = folder.updateTime ?? ""
    }
    
    //添加数据
    func setDataV3(folder: OOFolderV3) {
        self.folder = nil
        self.folderV3 = folder
        self.folderNameLabel.text = folder.name ?? ""
        self.folderTimeLabel.text = folder.updateTime ?? ""
    }
    
}
