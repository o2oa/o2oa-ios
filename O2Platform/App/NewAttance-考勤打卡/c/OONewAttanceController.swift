//
//  OONewAttanceController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/5/14.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import Promises
import CocoaLumberjack

public class OONewAttanceController: UITabBarController, UITabBarControllerDelegate {

    private var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.myViewControllers()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }


    private  func myViewControllers() {
        //打卡
        if let value = StandDefaultUtil.share.userDefaultGetValue(key: O2.O2_Attendance_version_key) as? String, value == "2" { // V2 版本考勤
            DDLogInfo("有v2版本。。。。。。。。。")
            let vc1 = AttendanceV2CheckInViewController(nibName: "AttendanceV2CheckInViewController", bundle: nil)
            vc1.title = "打卡"
            let checkInVC = ZLNavigationController(rootViewController: vc1)
            checkInVC.tabBarItem = UITabBarItem(title: "打卡", image: UIImage(named: "icon_daka_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_daka")!)
            
            let vc2 = AttendanceV2StatisticViewController(nibName: "AttendanceV2StatisticViewController", bundle: nil)
            vc2.title = "统计"
            let tongjiVC = ZLNavigationController(rootViewController: vc2)
            tongjiVC.tabBarItem = UITabBarItem(title: "统计", image: UIImage(named: "icon_tongji_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_tongji")!)
            
            self.viewControllers = [checkInVC, tongjiVC]
        } else {
            let vc1 = OOAttendanceCheckInNewController(nibName: "OOAttendanceCheckInNewController", bundle: nil)
            vc1.title = "打卡"
            let checkInVC = ZLNavigationController(rootViewController: vc1)
            checkInVC.tabBarItem = UITabBarItem(title: "打卡", image: UIImage(named: "icon_daka_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_daka")!)
            
            let vc2 = OOAttanceTotalController(nibName: "OOAttanceTotalController", bundle: nil)
            vc2.title = "统计"
            let tongjiVC = ZLNavigationController(rootViewController: vc2)
            tongjiVC.tabBarItem = UITabBarItem(title: "统计", image: UIImage(named: "icon_tongji_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_tongji")!)
            //设置
            let vc3 = OOAttanceSettingController(nibName: "OOAttanceSettingController", bundle: nil)
            vc3.title = "设置"
            let settingVC = ZLNavigationController(rootViewController: vc3)
            settingVC.tabBarItem = UITabBarItem(title: "设置", image: UIImage(named: "icon_setup_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_setting")!)
            self.viewControllers = [checkInVC, tongjiVC, settingVC]
        }
    }

}
