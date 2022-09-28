//
//  O2RecordVoiceWindow.swift
//  O2Platform
//
//  Created by FancyLou on 2022/9/28.
//  Copyright © 2022 zoneland. All rights reserved.
//


import UIKit
import CocoaLumberjack

class O2RecordVoiceWindow: UIView {
    private let emojiBarHeight = 196
    //语音录制按钮
    private lazy var audioBtnView: IMChatAudioView = {
        let view = Bundle.main.loadNibNamed("IMChatAudioView", owner: self, options: nil)?.first as! IMChatAudioView
        view.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: emojiBarHeight.toCGFloat)
        view.delegate = self
        return view
    }()
    //录音的时候显示的view
    private var voiceIconImage: UIImageView?
    private var voiceIocnTitleLable: UILabel?
    private var voiceImageSuperView: UIView?
    
    // 录音结果
    typealias DidRecordCallback = (_ path: String?, _ voice: Data?, _ duration: String?) -> Void ///< 定义确认回调
    private var path: String?
    private var voice: Data?
    private var duration: String?
    private var recordCallback: DidRecordCallback?
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = UIColor(hex: "#000000").alpha(0.5)
        
        self.audioBtnView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(self.audioBtnView)
        let bottom = NSLayoutConstraint(item: self.audioBtnView, attribute: .bottom, relatedBy: .equal, toItem: self.audioBtnView.superview!, attribute: .bottom, multiplier: 1, constant: CGFloat(0))
        let width = NSLayoutConstraint(item: self.audioBtnView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: SCREEN_WIDTH)
        let height = NSLayoutConstraint(item: self.audioBtnView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.emojiBarHeight.toCGFloat)
        NSLayoutConstraint.activate([bottom, width, height])
        self.layoutIfNeeded()
        self.audioBtnView.setWindowMode()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func openWindow(callback: @escaping DidRecordCallback) {
        self.recordCallback = callback
        UIApplication.shared.keyWindow?.addSubview(self)
        UIApplication.shared.keyWindow?.bringSubviewToFront(self)
    }
    
    @objc private func close() {
        self.removeFromSuperview()
    }
    
    
    private func audioRecordingGif() -> UIImage? {
        let url: URL? = Bundle.main.url(forResource: "listener08_anim", withExtension: "gif")
        guard let u = url else {
            return nil
        }
        guard let data = try? Data.init(contentsOf: u) else {
            return nil
        }
        return UIImage.sd_animatedGIF(with: data)
    }
}

extension O2RecordVoiceWindow:IMChatAudioViewDelegate {
    func clickCloseBtn() {
        self.close()
    }
    
    func clickDoneBtn() {
        DDLogDebug("点击完成")
        self.recordCallback?(path, voice, duration)
        self.close()
    }
    
    func sendVoice(path: String, voice: Data, duration: String) {
        DDLogDebug("完成录音。。。 \(path) \(duration)")
        self.path = path
        self.voice = voice
        self.duration = duration
    }
    
    func showAudioRecordingView() {
        DDLogDebug("正在录音。。。。。。")
        if self.voiceIconImage == nil {
            self.voiceImageSuperView = UIView()
            self.addSubview(self.voiceImageSuperView!)
            self.voiceImageSuperView?.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.6)
             
            self.voiceImageSuperView?.snp_makeConstraints { (make) in
                make.center.equalTo(self)
                make.size.equalTo(CGSize(width:140, height:140))
            }
        
            self.voiceIconImage = UIImageView()
            self.voiceImageSuperView?.addSubview(self.voiceIconImage!)
            self.voiceIconImage?.snp_makeConstraints { (make) in
                make.top.left.equalTo(self.voiceImageSuperView!).inset(UIEdgeInsets(top: 20, left: 35, bottom: 0, right: 0))
                make.size.equalTo(CGSize(width: 70, height: 70))
            }
            let voiceIconTitleLabel = UILabel()
            self.voiceIocnTitleLable = voiceIconTitleLabel
            self.voiceIconImage?.addSubview(voiceIconTitleLabel)
            voiceIconTitleLabel.textColor = UIColor.white
            voiceIconTitleLabel.font = .systemFont(ofSize: 12)
            voiceIconTitleLabel.text = "松开发送，上滑取消"
            voiceIconTitleLabel.snp_makeConstraints { (make) in
                make.bottom.equalTo(self.voiceImageSuperView!).offset(-15)
                make.centerX.equalTo(self.voiceImageSuperView!)
            }
        }
        self.voiceImageSuperView?.isHidden = false
        if let gifImage = self.audioRecordingGif() {
            self.voiceIconImage?.image = gifImage
        }else {
            self.voiceIconImage?.image = UIImage(named: "chat_audio_voice")
        }
        self.voiceIocnTitleLable?.text = "松开发送，上滑取消";
    }
    
    func hideAudioRecordingView() {
        DDLogDebug("结束录音。。。。。")
        self.voiceImageSuperView?.isHidden = true
    }
    
    func changeRecordingView2uplide() {
        DDLogDebug("松开手指，取消发送 .....")
        self.voiceIocnTitleLable?.text = "松开手指，取消发送";
        self.voiceIconImage?.image = UIImage(named: "chat_audio_cancel")
    }
    
    func changeRecordingView2down() {
        DDLogDebug("松开发送，上滑取消 .....")
        if let gifImage = self.audioRecordingGif() {
            self.voiceIconImage?.image = gifImage
        }else {
            self.voiceIconImage?.image = UIImage(named: "chat_audio_voice")
        }
        self.voiceIocnTitleLable?.text = "松开发送，上滑取消";
    }
    
    
    
}
