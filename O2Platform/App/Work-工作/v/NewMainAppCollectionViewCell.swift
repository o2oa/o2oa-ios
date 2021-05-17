//
//  NewMainAppCollectionViewCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 2017/3/12.
//  Copyright © 2017年 zoneland. All rights reserved.
//

import UIKit

class NewMainAppCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var appIconImageView: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    private var nowData:O2App?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setAppData(app: O2App)  {
        self.nowData = app
        self.appIconImageView.image = UIImage(named: app.normalIcon!)
        self.appNameLabel.text = app.title
        if let storeBoard = app.storyBoard, storeBoard == "webview" {
            if let iconUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(ApplicationContext.applicationContextKey2, query: ApplicationContext.applicationIconQuery, parameter: ["##applicationId##":app.appId! as AnyObject])  {
                let url = URL(string: iconUrl)
                let size = self.appIconImageView.bounds.size
                if size.width == 0 {
                    self.appIconImageView.bounds.size = CGSize(width: 38, height: 38)
                }
                self.appIconImageView.image = UIImage(named: app.normalIcon!)
                self.appIconImageView.highlightedImage = UIImage(named: app.normalIcon!)
                self.appIconImageView.hnk_setImageFromURL(url!, placeholder: UIImage(named: app.normalIcon!), format: nil, failure: { (err) in
                    self.appIconImageView.image = UIImage(named: app.normalIcon!)
                }) { image in
                    if self.nowData?.appId == app.appId {
                        self.appIconImageView.image = image
                        
                    }
                }
            } else {
                self.appIconImageView.image = UIImage(named: app.normalIcon!)
            }
        }
    }
}
