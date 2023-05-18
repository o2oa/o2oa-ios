//
//  SEmpowerCreateViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2023/5/17.
//  Copyright © 2023 zoneland. All rights reserved.
//

import UIKit
import ObjectMapper
 


class SEmpowerCreateViewController: UIViewController {

    @IBOutlet weak var identityBaseView: UIView!
    
    @IBOutlet weak var identityBaseViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var toPersonLabel: UILabel!
    
    @IBOutlet weak var toPersonView: UIStackView!
    
    @IBOutlet weak var startTimeView: UIStackView!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    
    @IBOutlet weak var completeTimeView: UIStackView!
    
    @IBOutlet weak var completeTimeLabel: UILabel!
    
    @IBOutlet weak var applicationView: UIStackView!
    
    @IBOutlet weak var applicationNameLabel: UILabel!
    @IBOutlet weak var processView: UIStackView!
    
    @IBOutlet weak var processNameLabel: UILabel!
    
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
    
    private lazy var viewM: O2PersonalViewModel = {
        return O2PersonalViewModel()
    }()

    var identitys: [IdentityV2] = []
    var identityViews: [IdentitySelectView] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "新建外出授权"
        //右边按钮
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "提交", style: .plain, target: self, action: #selector(self.postForm))
        self.loadCurrentIdentities()
        self.typeSegmentedControl.addTarget(self, action: #selector(typeSegmentPicker), for: .valueChanged)
        
    }
    
    @objc private func typeSegmentPicker(sender: UISegmentedControl?) {
//        DDLogDebug("切换了类型，\(sender?.selectedSegmentIndex ?? -1)")
        switch sender?.selectedSegmentIndex {
        case 1:
            self.processView.isHidden = true
            self.applicationView.isHidden = false
            break
        case 2:
            self.processView.isHidden = false
            self.applicationView.isHidden = true
            break
        default:
            self.processView.isHidden = true
            self.applicationView.isHidden = true
            break
        }
    }
    
    ///
    /// 查询当前用户的身份列表
    /// 
    private func loadCurrentIdentities() {
        self.showLoading()
        self.viewM.loadMyInfo().then({ p in
            self.hideLoading()
            self.identitys = p.woIdentityList ?? []
            self.identityBaseViewHeight.constant = (self.identitys.count * 94 + 20)
            self.setupIdentityUI()
        }).catch({ e in
            self.showError(title: "\(e), 个人信息载入出错!")
        })
            
//            .then { person in
//            self.hideLoading()
//            self.identitys = person.woIdentityList ?? []
//            self.identityBaseViewHeight.constant = (self.identitys.count * 94 + 20)
//            self.setupIdentityUI()
//        }.catch { err in
//            
//            self.showError(title: "\(err), 个人信息载入出错!")
//        }
    }
    
    /// 身份选择的 UI 创建
    private func setupIdentityUI() {
        self.identityViews = []
        self.identityBaseView.removeSubviews()
        
        var i = 0
        self.identitys.forEach { (identity) in
            self.initIdentityView(id: identity, top: (i.toCGFloat * 94 + 20))
            i += 1
        }
        self.identityViews.first?.selectedIdentity()
    }

    private func initIdentityView(id: IdentityV2, top: CGFloat) {
        let view = Bundle.main.loadNibNamed("IdentitySelectView", owner: self, options: nil)?.first as! IdentitySelectView
        view.frame = CGRect(x: 0, y: 0, width: self.identityBaseView.bounds.width, height: 94)
        view.setUp(identity: id)
        self.identityViews.append(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        self.identityBaseView.addSubview(view)

        let topC = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: view.superview!, attribute: .top, multiplier: 1, constant: top)
        let leftC = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: view.superview!, attribute: .leading, multiplier: 1, constant: 0)
        let rightC = NSLayoutConstraint(item: view.superview!, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([topC, leftC, rightC])
        
        view.addTapGesture { (tap) in
            let id = view.id?.distinguishedName
            self.identityViews.forEach { (i) in
                if i.id?.distinguishedName == id {
                    i.selectedIdentity()
                } else {
                    i.deSelectedIdentity()
                }
            }
        }
    }
    
    @objc private func postForm() {}
 
    

}
