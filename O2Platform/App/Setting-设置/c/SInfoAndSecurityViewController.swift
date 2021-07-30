//
//  SInfoAndSecurityViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2016/10/17.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Eureka
import CocoaLumberjack


class SInfoAndSecurityViewController: FormViewController {
    var bioType = O2BiometryType.None
    var typeTitle = "生物识别登录"
    var typeValue = "功能不可用"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let account = O2AuthSDK.shared.myInfo()
        
        LabelRow.defaultCellUpdate = {
            cell,row in
            cell.textLabel?.font = setting_content_textFont
            cell.textLabel?.textColor  = setting_content_textColor
            cell.detailTextLabel?.font = setting_value_textFont
            cell.detailTextLabel?.textColor = setting_value_textColor
            cell.accessoryType = .disclosureIndicator
        }
        
        //演示版本 显示绑定的服务器
//        if O2IsConnect2Collect {
//
//        }
        let unit =  SampleEditionManger.shared.getCurrentUnit()
        form +++ Section()
            <<< LabelRow(){
                $0.title = "绑定服务器"
                $0.value = unit.name
            }.onCellSelection({ (cell, row) in
                self.chooseBindSampleServer()
            })
        
       form +++ Section()
            <<< LabelRow(){
                $0.title = "登录帐号"
                $0.value = account?.name
                }.cellUpdate({ (cell, row) in
                    cell.accessoryType = .none
                })
            <<< LabelRow(){
                $0.title = "登录密码"
                $0.value = "修改密码"
                }.onCellSelection({ (cell,row) in
                    self.performSegue(withIdentifier: "showPassworChangeSegue", sender: nil)
                })
        form +++ Section()
            <<< LabelRow("bioAuthRow"){
                    $0.title = typeTitle
                    $0.value = typeValue
            }.onCellSelection({ (cell, row) in
                if self.bioType != O2BiometryType.None {
                    self.performSegue(withIdentifier: "showAccountSecSegue", sender: nil)
                }else {
                    self.showError(title: "手机系统未开启或不支持识别功能")
                }
            })
            
            
        
        if O2IsConnect2Collect {
            let mobile = O2AuthSDK.shared.bindDevice()?.mobile
            form +++ Section()
            <<< LabelRow() {
                $0.title = "变更手机号码"
                $0.value = mobile
            }.onCellSelection({ (cell,row) in
                self.performSegue(withIdentifier: "showMobileChangeSegue", sender: nil)
            })
            
            form +++ Section()
            <<< LabelRow() {
                 $0.title = "设备"
                 $0.value = "常用设备管理"
                
                }.onCellSelection({ (cell, row) in
                    self.performSegue(withIdentifier: "showDeviceListSegue", sender: nil)
                })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 显示的时候刷新数据
        self.checkBioType()
        let authRow = self.form.rowBy(tag: "bioAuthRow") as? LabelRow
        authRow?.title = typeTitle
        authRow?.value = typeValue
        authRow?.updateCell()
    }
    
    /// 选择绑定的演示服务器
    private func chooseBindSampleServer() {
        let unitList = SampleEditionManger.shared.unitList
        var actions: [UIAlertAction] = []
        for item in unitList {
            let action = UIAlertAction(title: item.name, style: .default) { (action) in
                self.change2Unit(unit: item)
            }
            actions.append(action)
        }
        self.showSheetAction(title: "提示", message: "切换访问环境", actions: actions)
    }
    
    private func change2Unit(unit: O2BindUnitModel) {
        self.showDefaultConfirm(title: "提示", message: "确定要切换访问环境吗，会重启应用并且需要新环境的用户密码进行登录？") { (action) in
            SampleEditionManger.shared.setCurrent(unit: unit)
            O2AuthSDK.shared.logout { (result, msg) in
                DDLogInfo("O2 登出 \(result), msg：\(msg ?? "")")
            }
            O2AuthSDK.shared.clearAllInformationBeforeReBind(callback: { (result, msg) in
                DDLogInfo("清空登录和绑定信息，result:\(result), msg:\(msg ?? "")")
                DBManager.shared.removeAll()
                DispatchQueue.main.async {
                    self.forwardDestVC("login", "startFlowVC")
                }
            })
        }
    }
    
    private func checkBioType() {
        let bioAuthUser = AppConfigSettings.shared.bioAuthUser
        var isAuthed = false
        //判断是否当前绑定的服务器的
        if !bioAuthUser.isBlank {
            let array = bioAuthUser.split("^^")
            if array.count == 2 {
                if array[0] == O2AuthSDK.shared.bindUnit()?.id {
                    isAuthed = true
                }
            }
        }
        bioType = O2BioLocalAuth.shared.checkBiometryType()
        
        switch bioType {
        case O2BiometryType.FaceID:
            typeTitle = "人脸识别登录"
            typeValue = (isAuthed ? "已开启":"未开启")
            break
        case O2BiometryType.TouchID:
            typeTitle = "指纹识别登录"
            typeValue = (isAuthed ? "已开启":"未开启")
            break
        case O2BiometryType.None:
            typeTitle = "生物识别登录"
            typeValue = "功能不可用"
            break
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
