//
//  O2MindMapAddLinkDialog.swift
//  O2Platform
//
//  Created by FancyLou on 2022/1/7.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

protocol O2MindMapAddLinkDialogDelegate {
    func deleteLink()
    func saveLink(link: String, linkTitle:String)
}

class O2MindMapAddLinkDialog: UIView, NibLoadable {
    
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var linkText: UITextField!
    
    @IBOutlet weak var linkTitleText: UITextField!
    
    @IBOutlet weak var bottomViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    private var delegate: O2MindMapAddLinkDialogDelegate? = nil
    
    @IBAction func clickCancelBtn(_ sender: UIButton) {
        self.dismiss()
    }
    
    @IBAction func clickDeleteLinkBtn(_ sender: Any) {
        self.delegate?.deleteLink()
        self.dismiss()
    }
    
    @IBAction func clickSubmitBtn(_ sender: UIButton) {
        let link = self.linkText.text ?? ""
        if link == "" || link.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.chrysan.show(.error ,message: "请输入链接地址", hideDelay: 2)
            return
        }
        if !Validate.URL(link).isRight {
            self.chrysan.show(.error, message: "请输入正确的链接地址", hideDelay: 2)
            return
        }
        let linkTitle = self.linkTitleText.text ?? ""
        
        self.delegate?.saveLink(link: link, linkTitle: linkTitle)
        self.dismiss()
    }
    
    class func mindMapNodeLinkDialog(link: String?, linkTitle: String?, delegate: O2MindMapAddLinkDialogDelegate?)-> O2MindMapAddLinkDialog {
        let dialog: O2MindMapAddLinkDialog = O2MindMapAddLinkDialog.loadViewFromNib()
        dialog.initUI(link: link, linkTitle: linkTitle)
        dialog.delegate = delegate
        return dialog
    }
    
    func show() {
        
        UIApplication.shared.keyWindow!.addSubview(self)
        
        self.frame = UIScreen.main.bounds
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomViewConstraint.constant = 0
            
            self.backgroundColor = UIColor.hexRGB(0x000000, 0.5)
            
            self.layoutIfNeeded()
        }, completion: { (finish) in
            
        })
        
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            
            self.bottomViewConstraint.constant = self.bottomView.frame.size.height
            
            self.backgroundColor = UIColor.hexRGB(0x000000, 0.0)
            
            self.layoutIfNeeded()
            
        }, completion: { (finished) in
            
            self.removeFromSuperview()
            
        })
    }
    
    private func initUI(link: String?, linkTitle: String?) {
        self.submitBtn.setBackgroundColor(base_color, forState: .normal)
        self.submitBtn.setCornerRadius(radius: 4)
        self.linkText.text = link ?? ""
        self.linkTitleText.text = linkTitle ?? ""
        
        bottomViewConstraint.constant = bottomView.frame.size.height
        backgroundColor = UIColor.hexRGB(0x000000, 0.0)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismiss))
        tap.delegate = self
        addGestureRecognizer(tap)
         
    }
    
}
// MARK: - UIGestureRecognizerDelegate
extension O2MindMapAddLinkDialog: UIGestureRecognizerDelegate {
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
