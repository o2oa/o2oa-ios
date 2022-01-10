//
//  O2MindMapAddIconDialog.swift
//  O2Platform
//
//  Created by FancyLou on 2022/1/7.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

protocol O2MindMapAddIconDialogDelegate {
    func saveIcons(progress: Int?, priority: Int?)
}

class O2MindMapAddIconDialog: UIView, NibLoadable {
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var progressContainerView: UIView!
    
    @IBOutlet weak var prorityContainerView: UIView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    private var progress = 0 // 进度 1-9
    private var progressBtns:[UIButton] = []
    private var priority = 0 // 优先级 1-9
    private var priorityBtns:[UIButton] = []
    private var delegate: O2MindMapAddIconDialogDelegate? = nil
    
    class func mindMapNodeIconDialog(progress: Int?, priority:Int?, delegate: O2MindMapAddIconDialogDelegate?)-> O2MindMapAddIconDialog {
        let dialog = O2MindMapAddIconDialog.loadViewFromNib()
        dialog.initUI(progress: progress, priority: priority)
        dialog.delegate = delegate
        return dialog
    }
    
    func show() {
        
        UIApplication.shared.keyWindow!.addSubview(self)
        
        self.frame = UIScreen.main.bounds
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomConstraint.constant = 0
            
            self.backgroundColor = UIColor.hexRGB(0x000000, 0.5)
            
            self.layoutIfNeeded()
        }, completion: { (finish) in
            
        })
        
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomConstraint.constant = self.bottomView.frame.size.height
            
            self.backgroundColor = UIColor.hexRGB(0x000000, 0.0)
            
            self.layoutIfNeeded()
            
        }, completion: { (finished) in
            
            self.removeFromSuperview()
            
        })
    }
    
    @IBAction func clickCancelBtn(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func clickSubmitBtn(_ sender: UIButton) {
        var pg:Int? =  nil
        if self.progress == 0 {
            pg = nil
        } else {
            pg = self.progress
        }
        var pri:Int? =  nil
        if self.priority == 0 {
            pri = nil
        } else {
            pri = self.priority
        }
        self.delegate?.saveIcons(progress: pg, priority: pri)
        self.dismiss()
    }
    
    // 点击进度按钮
    private func clickProgressBtn(_ sender: UITapGestureRecognizer) {
        if let button = sender.view as? UIButton {
            for btn in progressBtns {
                if btn.tag != button.tag {
                    btn.isSelected = false
                }else {
                    btn.isSelected = true
                    self.progress = btn.tag
                }
            }
        }
    }
    // 点击优先级按钮
    private func clickPriorityBtn(_ sender: UITapGestureRecognizer) {
        if let button = sender.view as? UIButton {
            for btn in priorityBtns {
                if btn.tag != button.tag {
                    btn.isSelected = false
                }else {
                    btn.isSelected = true
                    self.priority = btn.tag
                }
            }
        }
    }
    
    
    private func initUI(progress: Int?, priority: Int?) {
        self.submitBtn.setBackgroundColor(base_color, forState: .normal)
        self.submitBtn.setCornerRadius(radius: 4)
        self.progress = progress ?? 0
        self.priority = priority ?? 0
        
        let y:CGFloat = ( 36 - 24 ) / 2
        let width:CGFloat = (SCREEN_WIDTH - 20) / 10 - 5
        DDLogDebug("width: \(width)")
        for i in 0...10 {
            // 进度
            let progressBtn = UIButton()
            let x:CGFloat = CGFloat(i) * width + CGFloat(i) * 5
            DDLogDebug("生成按钮\(i) x: \(x)")
            progressBtn.frame = CGRect(x: x, y: y, width: width, height: width)
            progressBtn.setImage(UIImage(named: self.progressImg(progress: i)), for: .normal)
            progressBtn.setBackgroundColor(.gray, forState: .selected)
            progressBtn.setBackgroundColor(.clear, forState: .normal)
            if self.progress == i {
                progressBtn.isSelected = true
            } else {
                progressBtn.isSelected = false
            }
            progressBtn.tag = i
            self.progressContainerView.addSubview(progressBtn)
            progressBtn.addTapGesture { sender in
                self.clickProgressBtn(sender)
            }
            self.progressBtns.append(progressBtn)
            
            // 优先级
            let priorityBtn = UIButton()
            priorityBtn.setImage(UIImage(named: self.priorityImg(priority: i)), for: .normal)
            priorityBtn.frame = CGRect(x: x, y: y, width: width, height: width)
            priorityBtn.setBackgroundColor(.gray, forState: .selected)
            priorityBtn.setBackgroundColor(.clear, forState: .normal)
            if self.priority == i {
                priorityBtn.isSelected = true
            } else {
                priorityBtn.isSelected = false
            }
            priorityBtn.tag = i
            self.prorityContainerView.addSubview(priorityBtn)
            priorityBtn.addTapGesture { sender in
                self.clickPriorityBtn(sender)
            }
            self.priorityBtns.append(priorityBtn)
        }
        
        bottomConstraint.constant = bottomView.frame.size.height
        backgroundColor = UIColor.hexRGB(0x000000, 0.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        addGestureRecognizer(tap)
        
    }
    
    
    // 优先级图标
    private func priorityImg(priority: Int) -> String {
        if priority > 0 {
            return "priority\(priority)"
        }
        return "priorityx"
    }
    // 进度图标
    private func progressImg(progress: Int) -> String {
        if progress > 0 {
            return "progress\(progress)"
        }
        return "progressx"
    }
    
}
// MARK: - UIGestureRecognizerDelegate
extension O2MindMapAddIconDialog: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else { return false }
        
        if touchView.isDescendant(of: bottomView) {
            // 点击的view是否是bottomView或者bottomView的子视图
            return false
        }
        if touchView.isDescendant(of: self.chrysan) {
            // 提示信息点击不关闭
            return false
        }
        
        return true
    }
}
