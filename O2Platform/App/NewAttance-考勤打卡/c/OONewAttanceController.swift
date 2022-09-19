//
//  OONewAttanceController.swift
//  O2Platform
//
//  Created by 刘振兴 on 2018/5/14.
//  Copyright © 2018年 zoneland. All rights reserved.
//

import UIKit
import Promises

public class OONewAttanceController: UITabBarController, UITabBarControllerDelegate {

    private var viewModel: OOAttandanceViewModel = {
        return OOAttandanceViewModel()
    }()

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        self.tabBarItemsAttributes = OONewAttanceController.items
        self.viewControllers = OONewAttanceController.myViewControllers
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
    }

//    private func commonInit(_ result:Bool){
//        if result == true {
////            self.tabBarItemsAttributes = OONewAttanceController.items
//            self.viewControllers = OONewAttanceController.myViewControllers
//        }else{
////            self.tabBarItemsAttributes = OONewAttanceController.items1
//            self.viewControllers = OONewAttanceController.myViewControllers1
//        }
//    }

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


    private static let myViewControllers: [UIViewController] = {
        //打卡
        if let value = StandDefaultUtil.share.userDefaultGetValue(key: O2.O2_Attendance_version_key) as? Bool, value == true {
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
            return [checkInVC, tongjiVC, settingVC]
        } else {
            let vc1 = OOAttanceCheckInController(nibName: "OOAttanceCheckInController", bundle: nil)
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
            return [checkInVC, tongjiVC, settingVC]
        }
    }()


//    private static let myViewControllers1: [UIViewController] = {
//        //打卡
//        let vc1 = OOAttanceCheckInController(nibName: "OOAttanceCheckInController", bundle: nil)
//        let nav1 = ZLNavigationController(rootViewController: vc1)
//        nav1.tabBarItem = UITabBarItem(title: "打卡", image: UIImage(named: "icon_daka_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_daka")!)
//        //统计
//        let vc2 = OOAttanceTotalController(nibName: "OOAttanceTotalController", bundle: nil)
//        let nav2 = ZLNavigationController(rootViewController: vc2)
//        nav2.tabBarItem = UITabBarItem(title: "统计", image: UIImage(named: "icon_tongji_nor"), selectedImage: O2ThemeManager.image(for: "Icon.at_tongji")!)
//        return [nav1,nav2]
//    }()
//


    public func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    }
}
