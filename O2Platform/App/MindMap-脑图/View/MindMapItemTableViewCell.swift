//
//  MindMapItemTableViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/16.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit


class MindMapItemTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    @IBOutlet weak var preViewImage: UIImageView! //预览图
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    
    func setItem(item: MindMapItem) {
        self.titleLabel.text = item.name
        self.versionLabel.text = "版本：\(item.fileVersion ?? 1)"
        self.timeLabel.text = timeFormat(time: item.updateTime)
        // todo 图片
        if let icon = item.icon, icon != "" {
            let urlstr = O2AuthSDK.shared.getFileDownloadUrl(fileId: icon)
            let url = URL(string: urlstr)
            self.preViewImage.hnk_setImageFromURL(url!)
        }
    }
    
    /// @param time 2019-02-11 12:20:00
    private func timeFormat(time: String?)-> String {
        guard let t = time else {
            return ""
        }
        let thisYear = Date().year
        let timeYear = t.subString(from: 0, to: 4)
        if timeYear == "\(thisYear)" {
            return t.subString(from: 5, to: 16)
        } else {
            return t.subString(from: 0, to: 16)
        }
    }
   
}
