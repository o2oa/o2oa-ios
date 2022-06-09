//
//  BBSForumCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 2016/11/3.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit

class BBSForumCell: UICollectionViewCell {
    
    @IBOutlet weak var bbsSectionTitleLabel: UILabel!
    
    @IBOutlet weak var bbsSectionIconImageView: UIImageView!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    
    var bbsSectionData:BBSectionListData? {
        didSet {
            self.bbsSectionTitleLabel.text = bbsSectionData?.sectionName
            if bbsSectionData?.icon != nil {
                self.bbsSectionIconImageView.image =  UIImage.sd_image(with: Data(base64Encoded: (bbsSectionData?.icon)!, options:NSData.Base64DecodingOptions.ignoreUnknownCharacters))
            }else {
                self.bbsSectionIconImageView.image = UIImage(named: "icon_forum_default")
            }
            let time = self.bbsSectionData?.updateTime?.subString(from: 5, to: 10)
            self.timeLabel.text = "\(time ?? "")"
            self.numberLabel.text = "\(self.bbsSectionData?.subjectTotal ?? 0)个"
             
        }
    }
   
    
    
    
}
