//
//  ZLNavigationController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/6/16.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit

class ZLNavigationController: O2BaseForRotateUINavViewController {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance.init()
            appearance.backgroundColor = navbar_barTint_color
            appearance.titleTextAttributes =  [NSAttributedString.Key.font:navbar_text_font,NSAttributedString.Key.foregroundColor:navbar_tint_color]
            self.navigationBar.standardAppearance = appearance
            self.navigationBar.scrollEdgeAppearance = appearance
        }else {
            self.navigationBar.barTintColor = navbar_barTint_color
            self.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:navbar_text_font,NSAttributedString.Key.foregroundColor:navbar_tint_color]
        }
        self.navigationBar.tintColor = navbar_tint_color
        self.navigationBar.isTranslucent = false
        self.toolbar.barTintColor = navbar_barTint_color
        self.toolbar.tintColor = navbar_tint_color
        self.toolbar.barStyle = .default
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        }
        super.pushViewController(viewController, animated: animated)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
//    override func childViewControllerForStatusBarStyle() -> UIViewController? {
//        return self.topViewController
//    }
  
}
