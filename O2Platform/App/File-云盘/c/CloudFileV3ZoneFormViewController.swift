//
//  CloudFileV3ZoneFormViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/6/2.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

class CloudFileV3ZoneFormViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descTextField: UITextField!
    
    
    var oldZone: CloudFileV3Zone? // 如果传入oldZone 就是修改

    private lazy var cFileVM: CloudFileViewModel = {
        return CloudFileViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let zone = oldZone {
            self.title = L10n.cloudFileV3ZoneFormUpdateTitle
            self.nameTextField.text = zone.name ?? ""
            self.descTextField.text = zone.desc ?? ""
        } else {
            self.title = L10n.cloudFileV3ZoneFormCreateTitle
        }
    }
    
    // 提交
    @IBAction func clickSubmitBtn(_ sender: UIButton) {
        let name = self.nameTextField.text ?? ""
        let desc = self.descTextField.text ?? ""
        if name == "" || name.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            self.showError(title: L10n.cloudFileV3MessageNameNotEmpty)
            return
        }
        if let old = oldZone {
            self.updateZone(id: old.id ?? "", name: name, desc: desc)
        } else {
            self.createZone(name: name, desc: desc)
        }
    }
    
    private func createZone(name: String, desc: String) {
        self.showLoading()
        self.cFileVM.createZone(name: name, desc: desc)
            .then { _ in
                self.hideLoading()
                DispatchQueue.main.async {
                    self.popVC()
                }
            }.catch { e in
                self.showError(title: "\(e.localizedDescription)")
            }
    }
    
    
    private func updateZone(id: String, name: String, desc: String) {
        self.showLoading()
        self.cFileVM.updateZone(id: id, name: name, desc: desc)
            .then { _ in
                self.hideLoading()
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }.catch { e in
                self.showError(title: "\(e.localizedDescription)")
            }
    }
}
