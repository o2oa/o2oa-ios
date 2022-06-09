//
//  CMSAPPCollectionViewCell.swift
//  O2Platform
//
//  Created by FancyLou on 2022/6/9.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class CMSAPPCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var appIconImageView: UIImageView!
    
    @IBOutlet weak var descLabel: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    
  
    
    var cmsData:CMSData? {
        didSet {
            if  let appIcon = cmsData?.appIcon {
                self.appIconImageView.image = UIImage.base64ToImage(appIcon, defaultImage: UIImage(named:"icon_cms_application_default")!)
            }else{
                self.appIconImageView.image = UIImage(named:"icon_cms_application_default")!
            }
            self.appNameLabel.text = cmsData?.appName
            self.descLabel.text = cmsData?.descriptionField
            self.numberLabel.text =  "分类: \(cmsData?.categoryList?.count ?? 0)"
        }
    }
    
}
