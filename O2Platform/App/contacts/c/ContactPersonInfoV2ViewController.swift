//
//  ContactPersonInfoV2ViewController.swift
//  O2Platform
//
//  Created by 程剑 on 2017/7/11.
//  Copyright © 2017年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper

import Eureka
import CocoaLumberjack


class ContactPersonInfoV2ViewController: UITableViewController {
    @IBOutlet weak var beijingImg: UIImageView!
    @IBOutlet weak var personImg: UIImageView!
    @IBOutlet weak var personName: UILabel!
    @IBOutlet weak var personQQ: UILabel!
    @IBOutlet weak var personCollect: UIButton!
    
    @IBOutlet weak var personGirl: UIButton!
    @IBOutlet weak var personMan: UIButton!
    @IBOutlet weak var personCollectLab: UILabel!
    
    var isCollect = false
    @IBAction func collectPerson(_ sender: UIButton) {
        
        let me = O2AuthSDK.shared.myInfo()
        if personCollect.isSelected == true {
            //删除
            DBManager.shared.deleteContactData(contact!, (me?.id)!)
        }else{
            //增加
            DBManager.shared.insertContactData(contact!, (me?.id)!)
        }
        personCollect.isSelected = !personCollect.isSelected
        
    }
    
    let nameLabs = [L10n.Contacts.enterpriseInformation, L10n.Contacts.personName, L10n.Contacts.employeeNumber,
                    L10n.Contacts.uniqueCode, L10n.Contacts.contactNumber, L10n.Contacts.email, L10n.Contacts.dept
                    , L10n.Contacts.officePhone, L10n.Contacts.superior, L10n.Contacts.boardDate, L10n.Contacts.description]
    
    var myPersonURL:String?
    
    
    var identity:IdentityV2? {
        didSet {
            self.myPersonURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personInfoByNameQuery, parameter: ["##name##":identity!.person! as AnyObject])
        }
    }
    
    var person:PersonV2?{
        didSet {
            self.myPersonURL = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personInfoByNameQuery, parameter: ["##name##":person!.id! as AnyObject])
        }
    }
    
    var isLoadPerson:Bool = true
    // 个人信息
    var contact:PersonV2? {
        didSet {
            isLoadPerson = false
        }
    }
    // 汇报对象 名称
    var superiorName = ""
    // 个人属性
    var attributes: [PersonAttribute] = []
    // 包含用户信息 和 个人属性的列表 展现
    var personInfoList: [PersonInfoWithAttributes] = []
    //im 聊天
    private lazy var viewModel: IMViewModel = {
        return IMViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.beijingImg.theme_image = ThemeImagePicker(keyPath: "Icon.pic_beijing1")
        self.personImg.layer.cornerRadius = self.personImg.frame.size.width / 2
        self.personImg.clipsToBounds = true
        loadPersonInfo(nil)
        let startChatButton = OOBaseUIButton(x: (kScreenW - 260)/2, y: 5, w: 260, h: 30, target: self, action: #selector(_startChat))
        startChatButton.setTitle(L10n.Contacts.initiateChat, for: .normal)
        let btnContainerView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 40))
        btnContainerView.addSubview(startChatButton)
        tableView.tableFooterView = btnContainerView
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //去掉nav底部分割线
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func _startChat() {
        var username = ""
        if self.contact != nil {
            username = self.contact?.distinguishedName ?? ""
        }else if self.person != nil {
            username = self.person?.distinguishedName ?? ""
        }
        if username == "" {
            self.showError(title: L10n.Contacts.unableToCreatChat)
            return
        }
        
        self.viewModel.createConversation(type: o2_im_conversation_type_single, users: [username]).then { (conv) in
            let chatView = IMChatViewController()
            chatView.conversation = conv
            self.navigationController?.pushViewController(chatView, animated: true)
        }.catch { (err) in
            self.showError(title: L10n.errorWithMsg(err.localizedDescription))
        }
        
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return personInfoList.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "personInfoCell", for: indexPath) as! ContactPersonInfoCell

        //
        let data = self.personInfoList[indexPath.row]
        if data.infoType == 0 {
            cell.nameLab.text = data.name
            switch data.name {
            case L10n.Contacts.enterpriseInformation:
                cell.nameLab.font = UIFont.systemFont(ofSize: 17)
                cell.nameLab.textColor = UIColor.black
                cell.valueLab.isHidden = true
                cell.eventBut.isHidden = true
            case L10n.Contacts.personName:
                cell.valueLab.text = self.contact?.name
                cell.eventBut.isHidden = true
            case L10n.Contacts.employeeNumber:
                cell.valueLab.text = self.contact?.employee
                cell.eventBut.isHidden = true
            case L10n.Contacts.uniqueCode:
                cell.valueLab.text = self.contact?.unique
                cell.eventBut.isHidden = true
            case L10n.Contacts.contactNumber:
                if OrganizationPermissionManager.shared.isHiddenMobile(person: self.contact?.distinguishedName ?? "") {
                    cell.valueLab.text = "***********"
                } else {
                    cell.valueLab.text = self.contact?.mobile
    //                cell.eventBut.addTarget(self, action: #selector(self.call), for: UIControl.Event.touchUpInside)
                }
            case L10n.Contacts.email:
                cell.valueLab.text = self.contact?.mail
                cell.eventBut.theme_setImage(ThemeImagePicker(keyPath:"Icon.icon_email"), forState: .normal)
                cell.eventBut.addTarget(self, action: #selector(self.sendMail), for: UIControl.Event.touchUpInside)
            case L10n.Contacts.dept:
                var unitName = ""
                if let idenList = self.contact?.woIdentityList {
                    for iden in idenList {
                        if let unit = iden.woUnit {
                            if unitName != "" {
                                unitName.append(";")
                            }
                            unitName.append(unit.name ?? "")
                        }
                    }
                }
                cell.valueLab.text = unitName
                cell.eventBut.isHidden = true
            case L10n.Contacts.officePhone:
                cell.valueLab.text = self.contact?.officePhone
                cell.eventBut.isHidden = true
            case L10n.Contacts.superior:
                cell.valueLab.text = self.superiorName
                cell.eventBut.isHidden = true
            case L10n.Contacts.boardDate:
                cell.valueLab.text = self.contact?.boardDate
                cell.eventBut.isHidden = true
            case L10n.Contacts.description:
                cell.valueLab.text = self.contact?.desc
                cell.eventBut.isHidden = true
            case L10n.Contacts.personAttributes:
                cell.nameLab.font = UIFont.systemFont(ofSize: 17)
                cell.nameLab.textColor = UIColor.black
                cell.nameLab.text = L10n.Contacts.personAttributes
                cell.valueLab.isHidden = true
                cell.eventBut.isHidden = true
            default:
                break
            }
        } else if data.infoType == 1 {
            if let attr = data.attr {
                cell.nameLab.text = attr.name
//                cell.nameLab.font = UIFont.systemFont(ofSize: 17)
//                cell.nameLab.textColor = UIColor.black
                cell.valueLab.text = attr.attributeList?.joined(separator: ", ")
                cell.eventBut.isHidden = true
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.nameLabs[indexPath.row] {
        case L10n.Contacts.contactNumber:
            if !OrganizationPermissionManager.shared.isHiddenMobile(person: self.contact?.distinguishedName ?? "") {
                self.call()
            }
        case L10n.Contacts.email:
            self.sendMail()
        default:
            break
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    

    @objc func sendMail() {
        if let mail = self.contact?.mail, mail != "" {
            let alertController = UIAlertController(title: "", message: nil,preferredStyle: .actionSheet)
            let mailAction = UIAlertAction(title:L10n.Contacts.sendEmail, style: .default, handler: { _ in
                let mailURL = URL(string: "mailto://\(mail)")
                
                if UIApplication.shared.canOpenURL(mailURL!) {
                    UIApplication.shared.openURL(mailURL!)
                }else{
                    self.showError(title: L10n.Contacts.sendEmailError)
                }
            })
            let copyAction = UIAlertAction(title:L10n.copy, style: .default, handler: { _ in
                UIPasteboard.general.string = mail
                self.showSuccess(title: L10n.copySuccess)
            })
            
            let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
            alertController.addAction(mailAction)
            alertController.addAction(copyAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @objc func call(){
        if let phone = self.contact?.mobile, phone != "" {
            let alertController = UIAlertController(title: "", message: nil,preferredStyle: .actionSheet)
            let smsAction = UIAlertAction(title: L10n.sms, style: .default, handler: { _ in
                let smsURL = URL(string: "sms://\(phone)")
                if UIApplication.shared.canOpenURL(smsURL!) {
                    UIApplication.shared.openURL(smsURL!)
                }else{
                    self.showError(title: L10n.smsFail)
                }
            })
            let phoneAction = UIAlertAction(title: L10n.call, style: .default, handler: { _ in
                let phoneURL = URL(string: "tel://\(phone)")
                if UIApplication.shared.canOpenURL(phoneURL!) {
                    UIApplication.shared.openURL(phoneURL!)
                }else{
                    self.showError(title: L10n.callFail)
                }
            })
            let copyAction = UIAlertAction(title: L10n.copy, style: .default, handler: { _ in
                UIPasteboard.general.string = phone
                self.showSuccess(title: L10n.copySuccess)
            })
            
            let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil)
            alertController.addAction(phoneAction)
            alertController.addAction(smsAction)
            alertController.addAction(copyAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func loadPersonInfo(_ sender: AnyObject?){
        self.showLoading()
        AF.request(myPersonURL!).responseJSON {
            response in
            switch response.result {
            case .success( let val):
                let json = JSON(val)["data"]
                self.contact = Mapper<PersonV2>().map(JSONString:json.description)!
                // 汇报对象
                if let superior = self.contact?.superior {
                    self.loadSuperior(id: superior)
                }
                
                self.attributes = self.contact?.woPersonAttributeList ?? []
                // 默认的用户信息
                self.nameLabs.forEach { (label) in
                    let attr = PersonInfoWithAttributes(infoType: 0, name: label, attr: nil)
                    self.personInfoList.append(attr)
                }
                // 个人属性
                if !self.attributes.isEmpty {
                    let attr = PersonInfoWithAttributes(infoType: 0, name: L10n.Contacts.personAttributes, attr: nil)
                    self.personInfoList.append(attr)
                    self.attributes.forEach { (pAttr) in
                        if pAttr.name != "appBindDeviceList" {
                            let p = PersonInfoWithAttributes(infoType: 1, name: pAttr.name, attr: pAttr)
                            self.personInfoList.append(p)
                        }
                    }
                }
                
                //OOCon
                let me = O2AuthSDK.shared.myInfo()
                self.isCollect = DBManager.shared.isCollect(self.contact!, (me?.id)!)
                if self.isCollect == true {
                    self.personCollect.isSelected = true
                }else{
                    self.personCollect.isSelected = false
                }
                self.personName.text = self.contact?.name
                if let qq = self.contact?.qq, qq != "" {
                    self.personQQ.text = "QQ \(qq)"
                }else{
                    self.personQQ.text = ""
                }
                if let gt = self.contact?.genderType, gt == "f" {
                    self.personGirl.setImage(UIImage(named: "icon_girl_2"), for: .normal)
                }else{
                    self.personMan.setImage(UIImage(named: "icon_boy_2"), for: .normal)
                }
                let urlstr = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personIconByNameQueryV2, parameter: ["##name##":self.contact?.unique as AnyObject], generateTime: false)
                let url = URL(string: urlstr!)
                self.personImg.hnk_setImageFromURL(url!)
                DispatchQueue.main.async {
                    self.hideLoading()
                    self.tableView.reloadData()
                }
            case .failure(let err):
                DDLogError(err.localizedDescription)
                DispatchQueue.main.async {
                    self.showError(title: L10n.errorWithMsg(err.localizedDescription))
                }
            }
            
        }
    }
    
    /// 查询汇报对象
    private func loadSuperior(id: String) {
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(ContactContext.contactsContextKeyV2, query: ContactContext.personInfoByNameQuery, parameter: ["##name##": id as AnyObject])
        AF.request(url!).responseJSON {
            response in
            switch response.result {
            case .success( let val):
                let json = JSON(val)["data"]
                let person = Mapper<PersonV2>().map(JSONString:json.description)!
                self.superiorName = person.name ?? ""
                self.tableView.reloadData()
            case .failure(let err):
                DDLogError(err.localizedDescription)
            }
        }
    }
}
