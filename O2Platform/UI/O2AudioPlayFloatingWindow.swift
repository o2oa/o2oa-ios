//
//  O2AudioPlayFloatingWindow.swift
//  O2Platform
//
//  Created by FancyLou on 2021/7/28.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class O2AudioPlayFloatingWindow: UIWindow {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var stopBtn: UIButton!
    
    private func initView() {
        DDLogDebug("初始化悬浮按钮。。。。")
        self.backgroundColor = .clear
        self.windowLevel = UIWindow.Level.alert + 1
        self.rootViewController = UIViewController()
        self.makeKeyAndVisible()
        
        stopBtn = UIButton.init(type: .custom)
        stopBtn.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        stopBtn.setImage(UIImage(named: "icon_play_off"), for: .normal)
        self.addSubview(stopBtn)
        stopBtn.addTapGesture { (tap) in
            DDLogDebug("点击关闭")
            self.stopPlay()
        }
    }
    
    /// 关闭音频播放
    func stopPlay() {
        AudioPlayerManager.shared.stopAudio()
        self.hideFloatingBtn()
    }
    
    func showFloatingBtn()  {
        self.isHidden = false
    }
    
    func hideFloatingBtn()  {
        self.isHidden = true
    }
}
