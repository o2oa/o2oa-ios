//
//  SettingViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/6.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper
import SwiftyJSON

import SDWebImage
import CocoaLumberjack
import Flutter

class SettingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
//    @IBOutlet weak var settingHeaderView: SettingHeaderView!
//
//    @IBOutlet weak var iconImageView: UIImageView!
//
//    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var settingItemTableView: UITableView!
    
//    @IBOutlet weak var SettingHeaderViewTopConstraint: NSLayoutConstraint!
    
    
    var itemModels:[Int:[SettingHomeCellModel]] {
        let item0 = SettingHomeCellModel(iconName: "person_avatar", title: "个人信息", status: nil,segueIdentifier:"showPersonSegue")
        let item1 = SettingHomeCellModel(iconName: "setting_accout", title: "账号与安全", status: nil,segueIdentifier:"showInfoAndSecuritySegue")
        let itemSkin = SettingHomeCellModel(iconName: "icon_skin", title: "个性换肤", status: nil,segueIdentifier:"showSkinViewSegue")
        let item2 = SettingHomeCellModel(iconName: "setting_newMessage", title: "新消息通知", status: nil,segueIdentifier:"showMessageNotiSegue")
        let item3 = SettingHomeCellModel(iconName: "setting_common", title: "通用", status: nil,segueIdentifier:"showCommonSegue")
//        let item4 = SettingHomeCellModel(iconName: "setting_myCRM", title: "我的客服", status: nil,segueIdentifier:"showServiceSegue")
//        let item5 = SettingHomeCellModel(iconName: "setting_ideaback", title: "意见反馈", status: nil,segueIdentifier:"showIdeaBackSegue")
        let item6 = SettingHomeCellModel(iconName: "setting_about", title: "关于", status: nil,segueIdentifier:"showAboutSegue")
        return [0:[item0], 1:[item1], 2:[itemSkin, item2,item3], 3:[item6]]
    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = true
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        self.navigationController?.navigationBar.isHidden = false
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "设置"
        //更新头像之后刷新
        NotificationCenter.default.addObserver(self, selector: #selector(loadAvatar), name: Notification.Name("reloadMyIcon"), object: nil)
        
        
//        if #available(iOS 11.0, *) {
//            let topConstant = CGFloat(0 - IOS11_TOP_STATUSBAR_HEIGHT)
//            self.SettingHeaderViewTopConstraint.constant = topConstant
//        }
//        self.settingHeaderView.theme_backgroundColor = ThemeColorPicker(keyPath: "Base.base_color")
        self.settingItemTableView.separatorStyle = .none
        
//        self.iconImageView.layer.masksToBounds = true
//        self.iconImageView.layer.cornerRadius =  75 / 2.0
//        self.iconImageView.layer.borderColor = UIColor.white.cgColor
//        self.iconImageView.layer.borderWidth = 1
        
        self.settingItemTableView.delegate = self
        self.settingItemTableView.dataSource = self
        
        self.loadAvatar()

    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemModels.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (itemModels[section]?.count)!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 75
        } else {
            return 50
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingHomeCellIdentifier", for: indexPath) as! SettingHomeCell
//        cell.cellModel = itemModels[(indexPath as NSIndexPath).section]![(indexPath as NSIndexPath).row]
        if indexPath.section == 0 {
            cell.showPersonCell() // 个人信息 特殊处理 cell
        } else {
            let m = itemModels[indexPath.section]![indexPath.row]
            let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
            if (numberOfRows > 1 && indexPath.row != numberOfRows - 1) {
                cell.setModel(model: m, isShowBottom: true)
            } else {
                cell.setModel(model: m, isShowBottom: false)
            }
        }
        return cell
    }
    
    /// Cell 圆角背景计算
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //圆率
        let cornerRadius:CGFloat = 10.0
        //大小
        let bounds:CGRect  = cell.bounds
        //行数
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        //绘制曲线
        var bezierPath: UIBezierPath? = nil
        if (indexPath.row == 0 && numberOfRows == 1) {
//            bounds.origin.y -= 1.0
//            bounds.size.height += 2.0
            //一个为一组时,四个角都为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == 0) {
//            bounds.origin.y -= 1.0
            //为组的第一行时,左上、右上角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
//                bezierPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:(UIRectCornerTopLeft|UIRectCornerTopRight) cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        } else if (indexPath.row == numberOfRows - 1) {
//            bounds.size.height += 2.0
            //为组的最后一行,左下、右下角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            //中间的都为矩形
            bezierPath = UIBezierPath(rect: bounds)
        }
        //cell的背景色透明
        cell.backgroundColor = .clear
        //新建一个图层
        let layer = CAShapeLayer()
        //图层边框路径
        layer.path = bezierPath?.cgPath
        //图层填充色,也就是cell的底色
        layer.fillColor = UIColor.white.cgColor
        //图层边框线条颜色
        /*
         如果self.tableView.style = UITableViewStyleGrouped时,每一组的首尾都会有一根分割线,目前我还没找到去掉每组首尾分割线,保留cell分割线的办法。
         所以这里取巧,用带颜色的图层边框替代分割线。
         这里为了美观,最好设为和tableView的底色一致。
         设为透明,好像不起作用。
         */
        layer.strokeColor = UIColor.white.cgColor
        //将图层添加到cell的图层中,并插到最底层
        cell.layer.insertSublayer(layer, at: 0)
//        cell.layer.mask = layer
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellModel = self.itemModels[indexPath.section]?[indexPath.row]
        if let segue = cellModel?.segueIdentifier {
            if segue == "showIdeaBackSegue" {
//                PgyManager.shared().showFeedbackView()
//                self.testShowPicker()
            }else{
                self.performSegue(withIdentifier: segue, sender: nil)
            }
        }
    
        
    }
    
    @IBAction func showPersonDetail(_ sender: UITapGestureRecognizer) {
        self.performSegue(withIdentifier: "showPersonSegue", sender: nil)
    }
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    
    @objc private func loadAvatar() {
        DDLogInfo("刷新头像和名字。。。。。。。。。。。。。。。。。。。。。")
//        let me = O2AuthSDK.shared.myInfo()
//        self.nameLabel.text = me?.name
//        let avatarUrlString = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personIconByNameQueryV2, parameter: ["##name##":me?.id as AnyObject])
//        let avatarUrl = URL(string: avatarUrlString!)
//        self.iconImageView.hnk_setImageFromURL(avatarUrl!)
    }
    
    

}
