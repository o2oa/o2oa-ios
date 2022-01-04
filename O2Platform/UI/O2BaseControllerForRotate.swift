//
//  O2BaseForRotateUIViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/29.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit

//  O2BaseForRotateUITabBarController 作为根视图，需要把参数传递给它的子视图。
class O2BaseForRotateUITabBarController: UITabBarController {
     override var prefersStatusBarHidden: Bool {
         return selectedViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
     }

     override var preferredStatusBarStyle: UIStatusBarStyle {
         return selectedViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
     }

     override var shouldAutorotate: Bool {
         return selectedViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
     }

     override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
         return [selectedViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations, preferredInterfaceOrientationForPresentation.orientationMask]
     }

     override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
         return selectedViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
     }
}

// 导航试图
class O2BaseForRotateUINavViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self // 切记不要放在构造方法中配置，因为那时的 interactivePopGestureRecognizer 可能是 nil
    }

    override var shouldAutorotate: Bool {
        if let presentedViewController = presentedViewController, presentedViewController is UIAlertController {
            return false
        }
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
        }

        return visibleViewController?.shouldAutorotate ?? kDefaultShouldAutorotate
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedViewController = presentedViewController, presentedViewController is UIAlertController {
            return kDefaultSupportedInterfaceOrientations
        }
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
        }

        return visibleViewController?.supportedInterfaceOrientations ?? kDefaultSupportedInterfaceOrientations
    }

    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
        }

        return visibleViewController?.preferredInterfaceOrientationForPresentation ?? kDefaultPreferredInterfaceOrientationForPresentation
    }

    override var prefersStatusBarHidden: Bool {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
        }

        return visibleViewController?.prefersStatusBarHidden ?? kDefaultPrefersStatusBarHidden
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingPresented {
            return presentedViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
        }

        if let presentedController = topViewController?.presentedViewController, presentedController.isBeingDismissed {
            return topViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
        }

        return visibleViewController?.preferredStatusBarStyle ?? kDefaultPreferredStatusBarStyle
    }
}
extension O2BaseForRotateUINavViewController: UIGestureRecognizerDelegate {
     
     func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let controller = topViewController, controller.isForbidInteractivePopGesture {
            return false // 播放器处于横屏时，禁用左滑手势
        }
        return viewControllers.count > 1
     }
     
 }

class O2BaseForRotateUIViewController: UIViewController {
    // MARK: - 关于旋转的一些配置和说明

    // _xxx_ 系列方法，由子类自定义实现，未实现时，使用下面的默认参数
    var _preferredStatusBarStyle_: UIStatusBarStyle? { return nil }
    var _prefersStatusBarHidden_: Bool? { return nil }
    var _shouldAutorotate_: Bool? { return nil }
    var _supportedInterfaceOrientations_: UIInterfaceOrientationMask? { return nil }
    var _preferredInterfaceOrientationForPresentation_: UIInterfaceOrientation? { return nil }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.preferredStatusBarStyle
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _preferredStatusBarStyle_ ?? kDefaultPreferredStatusBarStyle
        }
        if let presentedController = presentedViewController {
            return presentedController.preferredStatusBarStyle
        }
        return _preferredStatusBarStyle_ ?? kDefaultPreferredStatusBarStyle
    }
        
    override var prefersStatusBarHidden: Bool {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.prefersStatusBarHidden
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _prefersStatusBarHidden_ ?? kDefaultPrefersStatusBarHidden
        }
        if let presentedController = presentedViewController {
            return presentedController.prefersStatusBarHidden
        }
        return _prefersStatusBarHidden_ ?? kDefaultPrefersStatusBarHidden
    }
        
    override var shouldAutorotate: Bool {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.shouldAutorotate
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _shouldAutorotate_ ?? kDefaultShouldAutorotate
        }
        if let presentedController = presentedViewController {
            return presentedController.shouldAutorotate
        }
        return _shouldAutorotate_ ?? kDefaultShouldAutorotate
    }
        
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.supportedInterfaceOrientations
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _supportedInterfaceOrientations_ ?? kDefaultSupportedInterfaceOrientations
        }
        if let presentedController = presentedViewController {
            return presentedController.supportedInterfaceOrientations
        }
        return _supportedInterfaceOrientations_ ?? kDefaultSupportedInterfaceOrientations
    }
        
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        if let presentedController = presentedViewController, presentedController.isBeingPresented {
            return presentedController.preferredInterfaceOrientationForPresentation
        }
        if let presentedController = presentedViewController, presentedController.isBeingDismissed {
            return _preferredInterfaceOrientationForPresentation_ ?? kDefaultPreferredInterfaceOrientationForPresentation
        }
        if let presentedController = presentedViewController {
            return presentedController.preferredInterfaceOrientationForPresentation
        }
        return _preferredInterfaceOrientationForPresentation_ ?? kDefaultPreferredInterfaceOrientationForPresentation
    }
}
