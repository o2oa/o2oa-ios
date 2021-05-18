//
//  O2AppViewController.swift
//  O2Platform
//
//  Created by 刘振兴 on 16/7/25.
//  Copyright © 2016年 zoneland. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import Flutter

import CocoaLumberjack


class O2AppViewController: UIViewController{
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let reuseIdentifier = "myCell"
       
    fileprivate let collectionViewDelegate = ZLCollectionView()
    
    var o2ALLApps:[O2App] = []
    var apps2:[[O2App]] = [[], [], []]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.app
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.edit, style: .plain, target: self, action: #selector(_forwardEditSegue))
        self.collectionViewDelegate.delegate = self
        self.collectionView.dataSource = self.collectionViewDelegate
        self.collectionView.delegate = self.collectionViewDelegate
        self.o2ALLApps = []
        self.apps2 = [[], [], []]
        //self.loadAppConfigDb()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.loadAppConfigDb()
    }
    
    func loadAppConfigDb() {
        let allApps = DBManager.shared.queryData()
        var nativeApps:[O2App] = []
        var portalApps:[O2App] = []
        allApps.forEach { (app) in
            if app.storyBoard == "webview" {
                portalApps.append(app)
            } else  {
                nativeApps.append(app)
            }
        }
        o2ALLApps = allApps
        
        let mainApps = DBManager.shared.queryMainData()
        apps2 = [mainApps, nativeApps, portalApps]
        self.collectionViewDelegate.apps = apps2
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    
    
    @objc private func _forwardEditSegue() {
//        self.performSegue(withIdentifier: "showAppEditSegue", sender: nil)
        if self.collectionViewDelegate.isEdit {
            self.collectionViewDelegate.isEdit = false
            self.navigationItem.rightBarButtonItem?.title = L10n.edit
            self._saveUpdate()
            self.collectionView.reloadData()
        } else {
            self.collectionViewDelegate.isEdit = true
            self.navigationItem.rightBarButtonItem?.title = L10n.done
            self.collectionView.reloadData()
        }
        
    }
    
    @objc private func _saveUpdate() {
        let mainApps = self.apps2[0]
        mainApps.forEachEnumerated { (i, app) in
            app.mainOrder = i
            DBManager.shared.updateData(app, 1)
        }
        var noMainApps: [O2App] = []
        o2ALLApps.forEach { (app) in
            if !mainApps.contains(where: { (a) -> Bool in
                return a.appId == app.appId
            }) {
                noMainApps.append(app)
            }
        }
        noMainApps.forEachEnumerated { (i, app) in
            app.order = i
            DBManager.shared.updateData(app, 0)
        }
        self.showMessage(msg: L10n.applicationsUpdateSuccess)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMailSegue" {
            segue.destination.modalPresentationStyle = .fullScreen
            if let nav = segue.destination as? ZLNavigationController {
                nav.viewControllers.forEach { (vc) in
                    if vc is MailViewController {
                        DDLogDebug("显示门户。。。。")
                        (vc as! MailViewController).app = sender as? O2App
                    }
                }
            }else if let mail = segue.destination as? MailViewController {
                mail.app = sender as? O2App
            }
        }
    }


    @IBAction func unBackAppsForApps(_ segue:UIStoryboardSegue){
        DDLogDebug("返回应用列表")
    }

    
    // MARK: - Flutter
    //打开flutter应用
    /**
     @param routeName flutter的路由 打开不同的页面
    **/
    func openFlutterApp(routeName: String) {
        let flutterViewController = O2FlutterViewController()
        DDLogDebug("init route:\(routeName)")
        flutterViewController.setInitialRoute(routeName)
        flutterViewController.modalPresentationStyle = .fullScreen
        self.present(flutterViewController, animated: false, completion: nil)
    }
    

}

extension O2AppViewController:ZLCollectionViewDelegate{
    func clickWithApp(_ app: O2App, section: Int) {
        if self.collectionViewDelegate.isEdit {
            if section == 0 {
                var main = self.apps2[0]
                main.removeAll { (a) -> Bool in
                    return a.appId == app.appId
                }
                self.apps2[0] = main
            } else {
                if !self.collectionViewDelegate.isAdd2Main(app: app) {
                    var main = self.apps2[0]
                    main.append(app)
                    self.apps2[0] = main
                }
            }
            self.collectionViewDelegate.apps = self.apps2
            self.collectionView.reloadData()
        } else {
            self.openApp(app: app)
        }
        
    }
    
    private func openApp(app: O2App) {
        if let flutter = app.storyBoard, flutter == "flutter" {
            openFlutterApp(routeName: app.appId!)
        }else {
            //设置返回标志，其它应用根据此返回标志调用返回unwindSegue
            AppConfigSettings.shared.appBackType = 2
            if let segueIdentifier = app.segueIdentifier,segueIdentifier != "" { // portal 门户 走这边
                if app.storyBoard! == "webview" { // 打开MailViewController
                    DDLogDebug("open webview for 22222: "+app.title!+" url: "+app.vcName!)
                    self.performSegue(withIdentifier: segueIdentifier, sender: app)
                }else {
                    self.performSegue(withIdentifier: segueIdentifier, sender: nil)
                }
                
            } else {
                if app.storyBoard! == "webview" {
                    DDLogError("321 open webview for : "+app.title!+" url: "+app.vcName!)
                } else {
                    // 内置应用走这边  根据appkey 打开对应的storyboard
                    if app.appId == "o2ai" {
                        app.storyBoard = "ai"
                    }
                    let story = O2AppUtil.apps.first { (appInfo) -> Bool in
                        return app.appId == appInfo.appId
                    }
                    var storyBoardName = app.storyBoard
                    if story != nil {
                        storyBoardName = story?.storyBoard
                    }
                    DDLogDebug("storyboard: \(storyBoardName!) , app:\(app.appId!)")
                    ///新版云盘 2019-11-20
                    if storyBoardName == "cloudStorage" {
                        storyBoardName = "CloudFile"
                    }
                    ////
                    let storyBoard = UIStoryboard(name: storyBoardName!, bundle: nil)
                    var destVC:UIViewController!
                    if let vcname = app.vcName,vcname.isEmpty == false {
                        destVC = storyBoard.instantiateViewController(withIdentifier: app.vcName!)
                    }else{
                        destVC = storyBoard.instantiateInitialViewController()
                    }
                    
                    if app.vcName == "todoTask" {
                        if "taskcompleted" == app.appId {
                            AppConfigSettings.shared.taskIndex = 2
                        }else if "read" == app.appId {
                           AppConfigSettings.shared.taskIndex = 1
                        }else if "readcompleted" == app.appId {
                            AppConfigSettings.shared.taskIndex = 3
                        }else {
                            AppConfigSettings.shared.taskIndex = 0
                        }
                    }
                    destVC.modalPresentationStyle = .fullScreen
                    if destVC.isKind(of: ZLNavigationController.self) {
                        DDLogInfo("cloudFIle 进来了？")
                        self.show(destVC, sender: nil)
                    }else{
                        self.navigationController?.pushViewController(destVC, animated: true)
                    }
                    
                }
            }
        }
    }
}

extension O2AppViewController:AppEditControllerUpdater {
    func appEditControllerUpdater() {
        self.loadAppConfigDb()
    }
}

