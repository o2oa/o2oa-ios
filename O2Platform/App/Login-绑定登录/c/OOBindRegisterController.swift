//
//  OOBindRegisterController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/4/5.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import Promises
import CocoaLumberjack

/// 绑定页面
class OOBindRegisterController: OOBaseViewController {

    
    @IBOutlet weak var topGapConstraint: NSLayoutConstraint!
    // 内容底部约束
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var navBackgroundImg: UIImageView!
    
    @IBOutlet weak var phoneNumberTextField: OOUITextField!
    
    @IBOutlet weak var codeTextField: OOUIDownButtonTextField!
    
    @IBOutlet weak var nextButton: OOBaseUIButton!
    
    private var viewModel:OOLoginViewModel = {
       return OOLoginViewModel()
    }()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardNotification()
        ////
        let headerView = Bundle.main.loadNibNamed("OORegisterTableView", owner: self, options: nil)?.first as! OORegisterTableView
        headerView.configTitle(title: L10n.Login.mobilePhoneValidate, actionTitle: nil)
        headerView.frame = CGRect(x: 0, y: 0, width: kScreenW, height: safeAreaTopHeight)
        headerView.theme_backgroundColor = ThemeColorPicker(keyPath: "Base.base_color")
        view.addSubview(headerView)
        self.topGapConstraint.constant = CGFloat(safeAreaTopHeight - CGFloat(IOS11_TOP_STATUSBAR_HEIGHT))
        setupUI()
    }
    
    private func setupKeyboardNotification () {
        NotificationCenter.default.addObserver(self, selector: #selector(openKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func openKeyboard(_ notification: Notification) {
        DDLogDebug("打开键盘。。。。。")
        let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        DDLogDebug("键盘 frame \(String(describing: keyboardFrame))")
        self.contentViewBottomConstraint.constant = keyboardFrame?.height ?? 0
        self.view.layoutIfNeeded()
    }
    
    @objc private func closeKeyboard() {
        DDLogDebug("关闭键盘。。。。。。")
        self.contentViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    private  func setupUI() {
        self.navBackgroundImg.theme_image = ThemeImagePicker(keyPath:"Icon.pic_yzsj_bj")
        phoneNumberTextField.rule = OOPhoneNumberRule()
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.returnKeyType = .next
        phoneNumberTextField.returnNextDelegate = self
        codeTextField.keyboardType = .numberPad
        codeTextField.buttonDelegate = self
        
        self.nextButton.isEnabled = false
        self.nextButton.disableBackColor = UIColor.lightGray
        self.codeTextField.downButton?.isEnabled = false
        self.codeTextField.isEnabled = false
        
        let baseColor = O2ThemeManager.color(for: "Base.base_color")!
        self.codeTextField.themeUpdate(buttonTitleColor: baseColor)
        self.codeTextField.themeUpdate(leftImage: O2ThemeManager.image(for: "Icon.icon_verification_code_nor"), leftLightImage: O2ThemeManager.image(for: "Icon.icon_verification_code_sel"), lineColor: baseColor.alpha(0.4), lineLightColor: baseColor)
        self.phoneNumberTextField.themeUpdate(leftImage: O2ThemeManager.image(for: "Icon.icon_phone_nor"), leftLightImage: O2ThemeManager.image(for: "Icon.icon_phone_sel"), lineColor: baseColor.alpha(0.4), lineLightColor: baseColor)
        
        
        self.codeTextField.reactive.isEnabled <~ viewModel.passwordIsValid
        self.codeTextField.downButton!.reactive.isEnabled <~ viewModel.passwordIsValid
        self.nextButton.reactive.isEnabled <~ viewModel.submitButtionIsValid
        self.nextButton.reactive.backgroundColor <~ viewModel.submitButtonCurrentColor
        
        viewModel.loginControlIsValid(self.phoneNumberTextField, self.codeTextField)
        
    }
    
    @IBAction func nextAction(_ sender: UIButton) {
        codeTextField.stopTimerButton()
        guard let mobile = phoneNumberTextField.text else {
            self.showError(title: L10n.Login.pleaseEnterMobilePhone)
            return
        }
        guard let value = codeTextField.text else {
            self.showError(title: L10n.Login.pleaseEnterValidationCode)
            return
        }
        self.showLoading(title: L10n.Login.binding)
        //苹果上架用的测试账户 手机号码：13912345678 置顶验证码：5678
        if mobile == "13912345678" && value == "5678" {
            DDLogDebug("sample 服务器进入。。。。。")
            O2AuthSDK.shared.bindSampleServer(mobile: mobile) { (state, msg) in
                switch state {
                case .goToChooseBindServer(let unitList):
                    //多于一个节点到节点列表
                    self.performSegue(withIdentifier: "nextSelectNodeSegue", sender: unitList)
                    break
                case .goToLogin:
                    self.showError(title: L10n.Login.errorWithInfo(msg ?? ""))
                    break
                case .noUnitCanBindError:
                    self.showError(title: L10n.Login.canNotGetServerList)
                    break
                case .unknownError:
                    self.showError(title: L10n.Login.errorWithInfo(msg ?? ""))
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
        } else {
            O2AuthSDK.shared.bindMobileToSever(mobile: mobile, code: value) { (state, msg) in
                switch state {
                case .goToChooseBindServer(let unitList):
                    //多于一个节点到节点列表
                    self.performSegue(withIdentifier: "nextSelectNodeSegue", sender: unitList)
                    break
                case .goToLogin:
//                    self.showError(title: L10n.Login.errorWithInfo(msg ?? ""))
                    self.forwardDestVC("login", "loginVC")
                    break
                case .noUnitCanBindError:
                    self.showError(title: L10n.Login.canNotGetServerList)
                    break
                case .unknownError:
                    self.showError(title: L10n.Login.errorWithInfo(msg ?? ""))
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
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "nextSelectNodeSegue" {
            let destVC = segue.destination as! OOBindNodeViewController
            destVC.nodes = sender as! [O2BindUnitModel]
            destVC.mobile = phoneNumberTextField.text
            destVC.value = codeTextField.text
        }
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DDLogDebug("viewDidLayoutSubviews...........")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    
    
}

extension OOBindRegisterController:OOUIDownButtonTextFieldDelegate {
    func viewButtonClicked(_ textField: OOUIDownButtonTextField, _ sender: OOTimerButton) {
        //发送验证码
        self.showLoading()
        guard let mobile = phoneNumberTextField.text else {
            self.showError(title: L10n.Login.pleaseEnterMobilePhone)
            return
        }
        O2AuthSDK.shared.sendBindSMS(mobile: mobile) { (result, msg) in
            if !result {
                DispatchQueue.main.async {
                    self.showError(title: L10n.Login.errorWithInfo(msg ?? ""))
                    sender.stopTiming()
                }
            }
            self.hideLoading()
        }
    }
}

extension OOBindRegisterController: OOUITextFieldReturnNextDelegate {
    func next()  {
        if self.phoneNumberTextField.isFirstResponder {
            self.codeTextField.becomeFirstResponder()
        }
    }
}
