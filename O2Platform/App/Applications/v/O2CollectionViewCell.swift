//
//  O2CollectionViewCell.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/6/17.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class O2CollectionViewCell: UICollectionViewCell {
   
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.white
    }
    
    @IBOutlet weak var appIconImageView: UIImageView!
    
    @IBOutlet weak var opIconImageView: UIImageView!
    
    @IBOutlet weak var appTitle: UILabel!
    
    @IBOutlet weak var numberLabel: UILabel!
    
    
    private var nowData:O2App?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.appIconImageView.image = nil
    }
    
    // editIcon 0 不编辑 1 选中的应用显示删除icon 2 选中的应用显示已选择的icon 3未选中的应用显示可选择的icon
    func setAppData(app: O2App, editIcon: Int) {
        self.nowData = app
        self.numberLabel.isHidden = true
        if editIcon == 0 {
            self.opIconImageView.isHidden  = true
        } else {
            if editIcon == 1 {
                self.opIconImageView.image = UIImage(named: "icon_jian_1")
            } else if editIcon == 2 {
                self.opIconImageView.image = UIImage(named: "icon__ok2_yx")
            } else {
                self.opIconImageView.image = UIImage(named: "icon_add_1")
            }
            self.opIconImageView.isHidden  = false
        }
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
            } else{
                self.appIconImageView.image = UIImage(named: app.normalIcon!)
                self.appIconImageView.highlightedImage = UIImage(named: app.selectedIcon!)
            }
            
        } else{
            self.appIconImageView.image = UIImage(named: app.normalIcon!)
            self.appIconImageView.highlightedImage = UIImage(named: app.selectedIcon!)
            if let dn = O2AuthSDK.shared.myInfo()?.distinguishedName, editIcon == 0  {
//                DDLogDebug("这里进来了。。。。。dn：\(dn)")
                if app.appId == "task" || app.appId == "read" {
                    if let countUrl = AppDelegate.o2Collect.generateURLWithAppContextKey(ApplicationContext.applicationContextKey, query: ApplicationContext.countByPerson, parameter: ["##credential##": dn as AnyObject]) {
//                        DDLogDebug("这里进来了。。。。。countUrl：\(countUrl)")
                        AF.request(countUrl, method: .get, parameters:nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                            switch response.result {
                            case .success(let val):
//                                DDLogDebug("这里进来了。。。。。val：\(val)")
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
                                DDLogError("获取待办已办数量的请求错误了！！！！")
                                DDLogError(err.localizedDescription)
                                break
                            }
                        }
                    }
                }
            }
        }
        self.appTitle.text = app.title
    }
   
    
    
}
