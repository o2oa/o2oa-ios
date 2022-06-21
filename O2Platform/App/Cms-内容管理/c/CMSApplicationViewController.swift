//
//  CMSApplicationViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/6/9.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage
import AlamofireObjectMapper

import ObjectMapper
import CocoaLumberjack


// 信息中心首页
class CMSApplicationViewController: UIViewController {

    @IBOutlet weak var appCollectionView: UICollectionView!
    
    var cmsApplication:CMSApplication?
    var pageModel:SubjectPageModel = SubjectPageModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.appCollectionView.dataSource = self
        self.appCollectionView.delegate = self
        self.loadFirstData()
    }
    
    @IBAction func backToSuper(_ sender: UIBarButtonItem) {
        let backType = AppConfigSettings.shared.appBackType
        if backType == 1 {
            self.performSegue(withIdentifier: "backToMain", sender: nil)
        }else if backType == 2 {
            self.performSegue(withIdentifier: "backToApps", sender: nil)
        }
    }
    
    private func loadFirstData(){
        let url = AppDelegate.o2Collect.generateURLWithAppContextKey(CMSContext.cmsContextKey, query: CMSContext.cmsCategoryQuery, parameter: nil)
        self.cmsApplication = nil
        AF.request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            switch response.result {
                case .success(let val):
                    self.cmsApplication = Mapper<CMSApplication>().map(JSONObject: val)
                    self.pageModel.setPageTotal((self.cmsApplication?.count!)!)
                case .failure(let err):
                    DDLogError(err.localizedDescription)
            }
            DispatchQueue.main.async {
                self.appCollectionView.reloadData()
            }
           
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCategorySegue" {
            let cmsData = sender as? CMSData
            let destVC = segue.destination as! CMSCategoryListViewController
            destVC.title = cmsData?.appName
            destVC.cmsData = cmsData
       }
    }

}

// MARK: - collectionView delegate
extension CMSApplicationViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cmsApplication?.data?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CMSAPPCollectionViewCell", for: indexPath) as? CMSAPPCollectionViewCell {
            cell.cmsData = cmsApplication?.data?[indexPath.row]
            return cell
        }
        return UICollectionViewCell()
    }
    
    
}

extension CMSApplicationViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (SCREEN_WIDTH - 45) / 2
        return CGSize(width: CGFloat(width),height: CGFloat(205))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView:UICollectionView,layout collectionViewLayout:UICollectionViewLayout,referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: 0,height: 0)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        DDLogDebug("cell clicked")
        let cmsData = self.cmsApplication?.data?[indexPath.row]
        if cmsData?.wrapOutCategoryList != nil {
             self.performSegue(withIdentifier: "showCategorySegue", sender: cmsData)
        }else {
            self.showError(title: "该栏目为空，没有数据！")
        }
        
    }

}
