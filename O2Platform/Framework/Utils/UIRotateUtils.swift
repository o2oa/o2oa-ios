//
//  屏幕旋转工具类 
//  UIRotateUtils.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/29.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit


// 基础视图控制器的默认配置，涵盖了跟旋转屏、present时屏幕方向和状态栏样式有关系的常用配置
let kDefaultPreferredStatusBarStyle: UIStatusBarStyle = .default // 状态栏样式，默认使用系统的
let kDefaultPrefersStatusBarHidden: Bool = false // 状态栏是否隐藏，默认不隐藏
let kDefaultShouldAutorotate: Bool = true // 是否支持屏幕旋转，默认支持
let kDefaultSupportedInterfaceOrientations: UIInterfaceOrientationMask = .portrait // 支持的旋转方向，默认竖屏
let kDefaultPreferredInterfaceOrientationForPresentation: UIInterfaceOrientation = .portrait // present时，打开视图控制器的方向，默认竖屏

extension UIInterfaceOrientation {
    var orientationMask: UIInterfaceOrientationMask {
       switch self {
       case .portrait: return .portrait
       case .portraitUpsideDown: return .portraitUpsideDown
       case .landscapeLeft: return .landscapeLeft
       case .landscapeRight: return .landscapeRight
       default: return .all
       }
   }
}

extension UIInterfaceOrientationMask {
    
    var isLandscape: Bool {
        switch self {
        case .landscapeLeft, .landscapeRight, .landscape: return true
        default: return false
        }
    }

    var isPortrait: Bool {
         switch self {
        case . portrait, . portraitUpsideDown: return true
        default: return false
        }
    }

}

// MARK: - 专门负责旋转屏的工具类
class UIRotateUtils {

    static let shared = UIRotateUtils()
        
    private var appOrientation: UIDevice {
        return UIDevice.current
    }
    
    /// 方向枚举
    enum Orientation {
        
        case portrait
        case portraitUpsideDown
        case landscapeRight
        case landscapeLeft
        case unknown
        
        var mapRawValue: Int {
            switch self {
            case .portrait: return UIInterfaceOrientation.portrait.rawValue
            case .portraitUpsideDown: return UIInterfaceOrientation.portraitUpsideDown.rawValue
            case .landscapeRight: return UIInterfaceOrientation.landscapeRight.rawValue
            case .landscapeLeft: return UIInterfaceOrientation.landscapeLeft.rawValue
            case .unknown: return UIInterfaceOrientation.unknown.rawValue
            }
        }
        
    }
        
    private let unicodes: [UInt8] =
        [
            111,// o -> 0
            105,// i -> 1
            101,// e -> 2
            116,// t -> 3
            114,// r -> 4
            110,// n -> 5
            97  // a -> 6
        ]
        
    private lazy var key: String = {
        return [
            self.unicodes[0],// o
            self.unicodes[4],// r
            self.unicodes[1],// i
            self.unicodes[2],// e
            self.unicodes[5],// n
            self.unicodes[3],// t
            self.unicodes[6],// a
            self.unicodes[3],// t
            self.unicodes[1],// i
            self.unicodes[0],// o
            self.unicodes[5] // n
            ].map {
                return String(Character(Unicode.Scalar ($0)))
            }.joined(separator: "")
    }()
    
    /// 旋转到竖屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToPortrait(_ orientation: Orientation = .portrait) {
        rotate(to: orientation)
    }
    
    /// 旋转到横屏
    ///
    /// - Parameter orientation: 方向枚举
    func rotateToLandscape(_ orientation: Orientation = .landscapeRight) {
        rotate(to: orientation)
    }
        
    /// 旋转到指定方向
    ///
    /// - Parameter orientation: 方向枚举
    func rotate(to orientation: Orientation) {
        appOrientation.setValue(Orientation.unknown.mapRawValue, forKey: key) // 👈 需要先设置成 unknown 哟
        appOrientation.setValue(orientation.mapRawValue, forKey: key)
    }
}
