//
//  OOLoginViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/4/9.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import ReactiveCocoa
import ReactiveSwift
import CocoaLumberjack
import AVFoundation

/// 登录界面
class OOLoginViewController: OOBaseViewController {

    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var userNameTextField: OOUITextField!
    // 短信验证码
    @IBOutlet weak var passwordTextField: OOUIDownButtonTextField!
    // 密码
    @IBOutlet weak var passwordField: OOUITextField!
    // 图片验证码区域
    @IBOutlet weak var captchaCodeView: UIView!
    // 图片验证码输入
    @IBOutlet weak var captchaCodeField: OOUITextField!
    // 图片验证码
    @IBOutlet weak var captchaCodeImage: UIImageView!
    
    
    @IBOutlet weak var copyrightLabel: UILabel!
    
    @IBOutlet weak var submitButton: OOBaseUIButton!
    
    @IBOutlet weak var rebindBtn: UIButton!
    //修改成 其他登录方式按钮
    @IBOutlet weak var bioAuthLoginBtn: UIButton!
    //生物识别登录是否开启
    private var bioIsOpen: Bool = false
    private var bioTypeName: String = ""
    //初始化进入的时候是否直接跳转到生物识别认证登录界面
    private var notJumpBioAuth = false
    //登录方式
    private var loginType = 0 // 0默认的用户名验证码登录 1用户名密码登录
    
    private var useCaptcha = false // 是否启用图片验证码
    private var captchaCodeData: O2LoginCaptchaImgData? = nil
    

    var viewModel:OOLoginViewModel = {
       return OOLoginViewModel()
    }()
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //监听截屏通知
        NotificationCenter.default.addObserver(self, selector: #selector(screenshots),
                                               name: UIApplication.userDidTakeScreenshotNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
                
        //delegate
        passwordTextField.buttonDelegate = self
        
        setupUI()
        // 图片验证码点击刷新
        self.captchaCodeImage.addTapGesture { tap in
            self.getCaptchaImage()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.userDidTakeScreenshotNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let bioAuthUser = AppConfigSettings.shared.bioAuthUser
        //判断是否当前绑定的服务器的
        if !bioAuthUser.isBlank {
            let array = bioAuthUser.split("^^")
            if array.count == 2 {
                if array[0] == O2AuthSDK.shared.bindUnit()?.id {
                    self.bioIsOpen = true
                }
            }
        }
        if !self.notJumpBioAuth && self.bioIsOpen {
            DDLogDebug("已开启生物识别认证")
            self.gotoBioAuthLogin()
        }
        
    }
     
    
    @IBAction func unwindFromBioAuthLogin(_ unwindSegue: UIStoryboardSegue) {
        if unwindSegue.identifier == "goBack2Login" {
            DDLogDebug("从生物识别认证页面返回的，所以不需要再跳转了。。。。。。")
            notJumpBioAuth = true
        }
    }
    
    @objc private func didEnterBackground() {
        DDLogDebug("进入后台.................")
        self.userNameTextField.text = ""
        self.passwordField.text = ""
    }
    
    //截屏提示
    @objc private func screenshots() {
        self.showSystemAlert(title: L10n.alert, message: L10n.Login.donotScreenshot) { (action) in
            DDLogDebug("确定提示。")
        }
    }
    
    // 查询服务器开启的登录模式 codeLogin=true 就是启用了短信验证码 captchaLogin=true启用了图片验证码
    private func loadLoginMode() {
        O2AuthSDK.shared.loginMode { result, error in
            if let result = result {
                self.useCaptcha = result.captchaLogin ?? false
                if (result.codeLogin == true) {
                    self.bioAuthLoginBtn.isHidden = false
                } else {
                    self.bioAuthLoginBtn.isHidden = true
                }
                // 默认密码登录 如果需要默认显示短信验证码登录 下面那行换成 self.change2PhoneCodeLogin() 前提是上面loginmode返回的result.codeLogin==true
                self.change2PasswordLogin()
                if (result.captchaLogin == true) {
                    if self.loginType == 1 && self.useCaptcha == true {
                        if let base64String = self.captchaCodeData?.image, let base64Data = Data(base64Encoded: base64String) {
                            self.captchaCodeImage.image = UIImage(data: base64Data)
                        }
                        self.captchaCodeView.isHidden = false
                    } else {
                        self.captchaCodeView.isHidden = true // 图片验证码
                    }
                }
            } else {
                DDLogError("\(error ?? "登录模式查询错误！")")
            }
            
        }
    }
    
    // 获取图片验证码
    private func getCaptchaImage() {
        O2AuthSDK.shared.getLoginCaptchaCode{ result, error in
            if let result = result {
                self.captchaCodeData = result
                if let base64String = self.captchaCodeData?.image, let base64Data = Data(base64Encoded: base64String) {
                    self.captchaCodeImage.image = UIImage(data: base64Data)
                }
            } else {
                DDLogError("\(error ?? "获取图片验证码错误！")")
            }
            self.loadLoginMode()
        }
    }
    
    // 界面加载
    private func setupUI(){
        logoImageView.image = OOCustomImageManager.default.loadImage(.login_avatar)
        let backImageView = UIImageView(image: #imageLiteral(resourceName: "pic_beijing"))
        backImageView.frame = self.view.frame
        //毛玻璃效果
        let blur = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blur)
        effectView.frame = backImageView.frame
        backImageView.addSubview(effectView)
        // 皮肤
        let baseColor = O2ThemeManager.color(for: "Base.base_color")!
        self.passwordTextField.themeUpdate(buttonTitleColor: baseColor)
        self.passwordTextField.themeUpdate(leftImage: O2ThemeManager.image(for: "Icon.icon_verification_code_nor"), leftLightImage: O2ThemeManager.image(for: "Icon.icon_verification_code_sel"), lineColor: baseColor.alpha(0.4), lineLightColor: baseColor)
        self.passwordField.themeUpdate(leftImage: O2ThemeManager.image(for: "Icon.icon_verification_code_nor"), leftLightImage: O2ThemeManager.image(for: "Icon.icon_verification_code_sel"), lineColor: baseColor.alpha(0.4), lineLightColor: baseColor)
        self.userNameTextField.themeUpdate(leftImage: O2ThemeManager.image(for: "Icon.icon_user_nor"), leftLightImage: O2ThemeManager.image(for: "Icon.icon_user_sel"), lineColor: baseColor.alpha(0.4), lineLightColor: baseColor)
        
        self.passwordField.isSecureTextEntry = true
        self.passwordTextField.isSecureTextEntry = true
//        self.passwordTextField.keyboardType = .numberPad // 验证码有可能有其他字符
        self.userNameTextField.returnKeyType = .next
        self.userNameTextField.returnNextDelegate = self
        
        // 图片验证码 隐藏
        self.captchaCodeView.isHidden = true
        // 切换按钮 默认隐藏
        self.bioAuthLoginBtn.isHidden = true
        
        if O2IsConnect2Collect {
            self.loginType = 0
            self.rebindBtn.isHidden = false
            self.passwordTextField.isHidden = false //验证码
            self.passwordField.isHidden = true //密码
        }else {
            self.loginType = 1
            self.rebindBtn.isHidden = true
            self.passwordTextField.isHidden = true
            self.passwordField.isHidden = false
        }
        
//        self.passwordTextField.reactive.isEnabled <~ viewModel.passwordIsValid
//        self.passwordField.reactive.isEnabled <~ viewModel.pwdIsValid
        self.passwordTextField.downButton!.reactive.isEnabled <~ viewModel.passwordIsValid
//        self.submitButton.reactive.isEnabled <~ viewModel.submitButtionIsValid
//        self.submitButton.reactive.backgroundColor <~ viewModel.submitButtonCurrentColor
//        if O2IsConnect2Collect {
//            viewModel.loginControlIsValid(self.userNameTextField, self.passwordTextField, false)
//        }else {
//            viewModel.loginControlIsValid(self.userNameTextField, self.passwordField, true)
//        }
        
        let bioType = O2BioLocalAuth.shared.checkBiometryType()
        switch bioType {
        case O2BiometryType.FaceID:
            self.bioTypeName = L10n.Login.faceRecognitionLogin
            break
        case O2BiometryType.TouchID:
            self.bioTypeName = L10n.Login.fingerprintIdentificationLogin
            break
        default:
            break
        }
        
        
        //版权信息
        self.view.insertSubview(backImageView, belowSubview: self.logoImageView)
        let year = Calendar.current.component(Calendar.Component.year, from: Date())
        copyrightLabel.text = "Copyright © \(year)  All Rights Reserved"
        
        self.getCaptchaImage()
    }
 
    
    // 官方模式 重新绑定
    @IBAction func btnReBindNodeAction(_ sender: UIButton) {
        self.showDefaultConfirm(title: L10n.Login.rebind, message: L10n.Login.rebindToNewServiceNode) { (action) in
            O2AuthSDK.shared.clearAllInformationBeforeReBind(callback: { (result, msg) in
                DDLogInfo("清空登录和绑定信息，result:\(result), msg:\(msg ?? "")")
                DBManager.shared.removeAll()
                DispatchQueue.main.async {
                    self.forwardDestVC("login", nil)
                }
            })
        }
        
    }
    
    
    // 登录方式切换
    @IBAction func bioAuthLoginBtnAction(_ sender: UIButton) {
        //弹出选择登录方式
        var loginActions: [UIAlertAction] = []
        if self.loginType == 0 { //当前是验证码登录
            let passwordLogin = UIAlertAction(title: L10n.Login.passwordLogin, style: .default) { (action) in
                self.change2PasswordLogin()
            }
            loginActions.append(passwordLogin)
        }else {
            let phoneCodeLogin = UIAlertAction(title: L10n.Login.verificationCodeLogin, style: .default) { (action) in
                self.change2PhoneCodeLogin()
            }
            loginActions.append(phoneCodeLogin)
        }
        if self.bioIsOpen {
            let bioLogin = UIAlertAction(title: self.bioTypeName, style: .default) { (action) in
                self.gotoBioAuthLogin()
            }
            loginActions.append(bioLogin)
        }
        self.showSheetAction(title: L10n.alert, message: L10n.Login.selectFollowLoginMethod, actions: loginActions)
//        self.gotoBioAuthLogin()
    }
    
    // 切换成密码登录
    private func change2PasswordLogin() {
        self.passwordTextField.isHidden = true //验证码
        self.passwordField.isHidden = false //密码
        self.loginType = 1
        // 是否开启了图片验证码
        if self.useCaptcha == true {
            if let base64String = self.captchaCodeData?.image, let base64Data = Data(base64Encoded: base64String) {
                self.captchaCodeImage.image = UIImage(data: base64Data)
            }
            self.captchaCodeView.isHidden = false
        } else {
            self.captchaCodeView.isHidden = true // 图片验证码
        }
    }
    
    // 切换成短信验证码
    private func change2PhoneCodeLogin() {
        self.passwordTextField.isHidden = false //验证码
        self.passwordField.isHidden = true //密码
        self.loginType = 0
        self.captchaCodeView.isHidden = true // 图片验证码
    }
    
    // 登录提交
    @IBAction func btnLogin(_ sender: OOBaseUIButton) {
        self.view.endEditing(true)
        let credential = userNameTextField.text ?? ""
        var codeAnswer = ""
        if self.loginType == 0 {
            codeAnswer = passwordTextField.text ?? ""
        }else {
            codeAnswer = passwordField.text ?? ""
        }
        
        if credential == "" || codeAnswer == "" {
            self.showError(title: L10n.Login.mobilePhoneNumberPasswordIsEmptry)
            return
        }
        
        self.showLoading()
        if O2IsConnect2Collect {
            if self.loginType == 0 {
                passwordTextField.stopTimerButton()
                //app 上架用 sample服务器 固定的手机号码和验证码
                if credential == "13912345678" && codeAnswer == "5678" && O2UserDefaults.shared.unit?.centerHost == "sample.o2oa.net" {
                    DDLogDebug("sample 测试用的。。。。。。。。")
                    O2AuthSDK.shared.loginWithPassword(username: credential, password: "o2") { (result, msg) in
                        if result {
                            self.hideLoading()
                            self.gotoMain()
                        }else  {
                            self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
                        }
                    }
                } else {
                    O2AuthSDK.shared.login(mobile: credential, code: codeAnswer) { (result, msg) in
                        if result {
                            self.hideLoading()
                            self.gotoMain()
                        }else  {
                            self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
                        }
                    }
                }
            }else {
                let form = O2LoginWithCaptchaForm()
                form.credential = credential
                form.password = codeAnswer
                if self.useCaptcha {
                    // 验证码
                    let captchaCode = self.captchaCodeField.text ?? ""
                    if captchaCode == "" {
                        self.showError(title: L10n.Login.captchaCodeIsEmpty)
                        return
                    }
                    form.captcha = self.captchaCodeData?.id ?? ""
                    form.captchaAnswer = captchaCode
                    
                }
                O2AuthSDK.shared.loginWithCaptcha(form: form) { (result, msg) in
                    if result {
                        self.hideLoading()
                        self.gotoMain()
                    }else  {
                        self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
                    }
                }
//
//                O2AuthSDK.shared.loginWithPassword(username: credential, password: codeAnswer) { (result, msg) in
//                    if result {
//                        self.hideLoading()
//                        self.gotoMain()
//                    }else  {
//                        self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
//                    }
//                }
            }
        }else {
            //内网版本登录
            if self.loginType == 0 {
                passwordTextField.stopTimerButton()
                O2AuthSDK.shared.login(mobile: credential, code: codeAnswer) { (result, msg) in
                    if result {
                        self.hideLoading()
                        self.gotoMain()
                    }else  {
                        self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
                    }
                }
            } else {
                let form = O2LoginWithCaptchaForm()
                form.credential = credential
                form.password = codeAnswer
                if self.useCaptcha {
                    // 验证码
                    let captchaCode = self.captchaCodeField.text ?? ""
                    if captchaCode == "" {
                        self.showError(title: L10n.Login.captchaCodeIsEmpty)
                        return
                    }
                    form.captcha = self.captchaCodeData?.id ?? ""
                    form.captchaAnswer = captchaCode
                    
                }
                O2AuthSDK.shared.loginWithCaptcha(form: form) { (result, msg) in
                    if result {
                        self.hideLoading()
                        self.gotoMain()
                    }else  {
                        self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
                    }
                }
            }
            
//            O2AuthSDK.shared.loginWithPassword(username: credential, password: codeAnswer) { (result, msg) in
//                if result {
//                    self.hideLoading()
//                    self.gotoMain()
//                }else  {
//                    self.showError(title: L10n.Login.loginErrorWith(msg ?? ""))
//                }
//            }
        }
        
    }
    
    private func gotoMain() {
        //跳转到主页
        let destVC = O2MainController.genernateVC()
//        destVC.selectedIndex = 2 // 首页选中 TODO 图标不亮。。。。。
        UIApplication.shared.keyWindow?.rootViewController = destVC
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }

    private func gotoBioAuthLogin() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "showBioAuthLogin", sender: nil)
        }
    }
}

extension OOLoginViewController:OOUIDownButtonTextFieldDelegate {
    func viewButtonClicked(_ textField: OOUIDownButtonTextField, _ sender: OOTimerButton) {
        guard let credential = userNameTextField.text else {
            self.showError(title: L10n.Login.pleaseEnterMobilePhone)
            sender.stopTiming()
            return
        }
        O2AuthSDK.shared.sendLoginSMS(mobile: credential) { (result, msg) in
            if !result {
                DDLogError((msg ?? ""))
                self.showError(title: L10n.Login.sendCodeFail)
            }
        }
        
    }
}

extension OOLoginViewController: OOUITextFieldReturnNextDelegate {
    func next() {
        if self.userNameTextField.isFirstResponder {
            if self.passwordField.isHidden == false {
                self.passwordField.becomeFirstResponder()
            }
            if self.passwordTextField.isHidden == false {
                self.passwordTextField.becomeFirstResponder()
            }
        }
    }
    
    
}

