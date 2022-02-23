//
//  ZLCollectionView.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/8/18.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper
import CocoaLumberjack

protocol ZLCollectionViewDelegate {
    func clickWithApp(_ app:O2App, section: Int)
}

class ZLCollectionView: NSObject {
    
    fileprivate let itemNumberWithSection = 5
    
    var apps:[[O2App]] = [[], [], []]
    
    var delegate:ZLCollectionViewDelegate?
    
    var isEdit = false

    
}

extension ZLCollectionView:UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return apps[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as!  O2CollectionViewCell
        let app = self.apps[indexPath.section][indexPath.row]
        var icon = 0
        if isEdit {
            if indexPath.section == 0 {
                icon = 1
            } else {
                if isAdd2Main(app: app) {
                    icon = 2
                } else {
                    icon = 3
                }
            }
        } else {
            icon = 0
        }
        cell.setAppData(app: app, editIcon: icon)
        return cell
    }
    
    func isAdd2Main(app: O2App)-> Bool {
        let main = apps[0]
        if main.count > 0 {
            return main.contains { (a) -> Bool in
                return a.appId == app.appId
            }
        } else {
            return false
        }
    }
    
    
}

extension ZLCollectionView:UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width:SCREEN_WIDTH/CGFloat(itemNumberWithSection),height:80)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
}


extension ZLCollectionView:UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            let app = self.apps[indexPath.section][indexPath.row]
            DDLogDebug("app \(app.title!) be clicked")
        self.delegate?.clickWithApp(app, section: indexPath.section)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView:UICollectionReusableView = UICollectionReusableView(frame: .zero)
        if kind == UICollectionView.elementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "OOAppMainheaderView", for: indexPath)
            let headerView = reusableView as! OOAppMainCollectionReusableView
            if indexPath.section == 0 {
                headerView.titleLabel.text = L10n.applicationsMainApp
            } else if indexPath.section == 1  {
                headerView.titleLabel.text = L10n.applicationsNativeApp
            } else {
                headerView.titleLabel.text = L10n.applicationsPortalApp
            }
        }else if kind == UICollectionView.elementKindSectionFooter {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "OOAppMainCollectionFooterView", for: indexPath)
        }
        return reusableView
    }
}
