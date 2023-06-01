//
//  NewMainAppCollectionViewCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 2017/3/12.
//  Copyright © 2017年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import CocoaLumberjack

class NewMainAppCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var appIconImageView: UIImageView!
    
    @IBOutlet weak var appNameLabel: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    
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
        } else {
            
            self.numberLabel.isHidden = true
            if let dn = O2AuthSDK.shared.myInfo()?.distinguishedName {
                if app.appId == "task" || app.appId == "read" {
                    if let countUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(ApplicationContext.applicationContextKey, query: ApplicationContext.countByPerson, parameter: ["##credential##": dn as AnyObject]) {
                        AF.request(countUrl, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let val):
                                let json = JSON(val)["data"]
                                let type = JSON(val)["type"]
                                if type == "success" {
                                    let pInfos = Mapper<WorkNumbersData>().map(JSONString: json.description)
                                    DispatchQueue.main.async {
                                        if let uPInfos = pInfos, self.nowData?.appId == app.appId {
                                            if app.appId == "task" {
                                                let taskNumber = uPInfos.task ?? 0
                                                if taskNumber > 0 {
                                                    self.numberLabel.text = "\(taskNumber)"
                                                    self.numberLabel.isHidden = false
                                                }
                                            }
                                            if app.appId == "read" {
                                                let readNumber = uPInfos.read ?? 0
                                                if readNumber > 0 {
                                                    self.numberLabel.text = "\(readNumber)"
                                                    self.numberLabel.isHidden = false
                                                }
                                            }
                                        }
                                    }
                                }
                                break
                            case .failure(let err):
                                DDLogDebug("这里进来了。。。。 错误。了")
                                DDLogError(err.localizedDescription)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
}
