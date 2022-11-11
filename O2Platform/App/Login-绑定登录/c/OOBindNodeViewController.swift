//
//  OOBindNodeViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/4/8.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import Promises

/// 绑定页面 单位选择
class OOBindNodeViewController:OOBaseViewController,UITableViewDataSource,UITableViewDelegate {
    
    private var viewModel:OOLoginViewModel = {
       return OOLoginViewModel()
    }()
    
    private let cellIdentitifer = "OONodeUnitTableViewCell"
    
    private let headerFrame = CGRect(x: 0, y: 0, width: kScreenW, height: 164)
    
//    private let footerFrame = CGRect(x: 0, y: 0, width: kScreenW, height: 100)
    
    lazy var headerView:UIImageView = {
        return UIImageView(image: O2ThemeManager.image(for: "Icon.pic_xzzz_bj"))
    }()
    
    
    
    public var nodes:[O2BindUnitModel] = []
    
    public var mobile:String!
    
    public var value:String!
    
    private var selectedNode:O2BindUnitModel?
    
    @IBOutlet weak var footerBar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
//    lazy var footerView:UIView = {
//        let containerView = UIView(frame: self.footerBar.frame)
//        let buttonFrame = CGRect(x: 25, y: (self.footerBar.frame.height - 44) / 2, width: self.footerBar.frame.width - 25 * 2, height: 44)
//
//        containerView.addSubview(nextButton)
//        return containerView
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //下一步 按钮
        let nextButton = OOBaseUIButton(frame: CGRect(x: 25, y: (self.footerBar.bounds.height - 44) / 2, width: (kScreenW - (25 * 2)), height: 44))
        nextButton.theme_backgroundColor = ThemeColorPicker(keyPath: "Base.base_color")
        nextButton.configUI()
        let attrits = NSAttributedString(string: L10n.Login.nextStep, attributes: [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont(name:"PingFangSC-Regular",size:17)!])
        nextButton.setAttributedTitle(attrits, for: .normal)
        nextButton.addTarget(self, action: #selector(nextButtonClick(_:)), for: .touchUpInside)
        self.footerBar.addSubview(nextButton)
        //
        let headerView1 = Bundle.main.loadNibNamed("OORegisterTableView", owner: self, options: nil)?.first as! OORegisterTableView
        headerView1.configTitle(title: L10n.Login.selectServiceNode, actionTitle: nil)
        headerView1.frame = CGRect(x: 0, y: 0, width: kScreenW, height: 66)
        headerView1.theme_backgroundColor = ThemeColorPicker(keyPath: "Base.base_color")
        self.view.addSubview(headerView1)
        self.tableView.tableHeaderView = headerView
        headerView.contentMode = .scaleAspectFill
//        self.tableView.tableFooterView = footerView
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentitifer, for: indexPath) as! OONodeUnitTableViewCell
        cell.config(withItem: nodes[indexPath.row])
        if cell.isSelected {
            cell.selectImageView.isHighlighted = true
        }else {
            cell.selectImageView.isHighlighted = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       selectedNode = nodes[indexPath.row]
    }
    
    private func nextAction() {
        if let node = selectedNode {
            self.showLoading(title: L10n.Login.binding)
            O2AuthSDK.shared.bindMobileToServer(unit: node, mobile: mobile, code: value) { (state, msg) in
                switch state {
                case .goToChooseBindServer(_):
                    //多于一个节点到节点列表
                    //self.performSegue(withIdentifier: "nextSelectNodeSegue", sender: unitList)
//                    self.showError(title: L10n.Login.UnknownError)
                    self.alertError(msg: L10n.Login.UnknownError)
                    break
                case .goToLogin:
//                    self.showError(title: "错误！\(msg ?? "")")
                    self.forwardDestVC("login", "loginVC")
                    break
                case .noUnitCanBindError:
//                    self.showError(title: L10n.Login.canNotGetServerList)
                    self.alertError(msg: L10n.Login.canNotGetServerList)
                    break
                case .unknownError:
                    self.alertError(msg: L10n.Login.errorWithInfo(msg ?? ""))
                    break
                case .success:
                    //处理移动端应用
                    self.viewModel._saveAppConfigToDb()
                    //成功，跳转
                    DispatchQueue.main.async {
                        if self.presentedViewController == nil {
                            self.dismissVC(completion:nil)
                        }
                        let destVC = O2MainController.genernateVC()
//                        destVC.selectedIndex = 2
                        UIApplication.shared.keyWindow?.rootViewController = destVC
                        UIApplication.shared.keyWindow?.makeKeyAndVisible()
                    }
                    break
                }
                self.hideLoading()
            }
        }else{
            //请选择指定的目标服务
            self.showError(title: L10n.Login.selectServiceNode)
        }
    }
    
    @objc func nextButtonClick(_ sender:Any) {
        nextAction()
    }
    
    private func alertError(msg: String) {
        self.showSystemAlert(title: L10n.alert, message: msg) { action in
            self.dismissVC(completion: nil) // 关闭当前页面
        }
    }
    
    
}
