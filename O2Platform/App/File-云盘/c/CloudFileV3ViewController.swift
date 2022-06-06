//
//  CloudFileV3ViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit

// 云盘 V3 版本入口 可以选择进入个人网盘还是企业共享区
class CloudFileV3ViewController: UIViewController {

    @IBOutlet weak var myZoneArea: UIView!
    
    @IBOutlet weak var myFileArea: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.cloudFiles // Languager.standardLanguager().string(key: "Cloud Files")
        
        
        self.myZoneArea.addTapGesture { tap in
            self.openZone()
        }
        
        self.myFileArea.addTapGesture { _ in
            self.openPan()
        }
    }
    
    private func openZone() {
        if let myZoneVC = self.storyboard?.instantiateViewController(withIdentifier: "cloudFileV3MyZone") as? CloudFileZoneViewController {
            self.pushVC(myZoneVC)
        }
    }
    
    private func openPan() {
        self.performSegue(withIdentifier: "showCloudFileV2", sender: nil)
    }
 

}
