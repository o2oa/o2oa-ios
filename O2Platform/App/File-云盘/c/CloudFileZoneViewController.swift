//
//  CloudFileZoneViewController.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import UIKit
import CocoaLumberjack

class CloudFileZoneViewController: UITableViewController {

    // 收藏列表 和 共享区列表
    private var myZoneData:[Int:[CloudFileV3CellViewModel]] = [0:[],1:[]]
    private lazy var cFileVM: CloudFileViewModel = {
        return CloudFileViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = L10n.cloudFileZoneName
        
        self.tableView.separatorStyle = .none
        self.tableView.register(UINib.init(nibName: "CloudFileV3ZoneCell", bundle: nil), forCellReuseIdentifier: "CloudFileV3ZoneCell")
        self.tableView.register(UINib.init(nibName: "CloudFileV3ZoneHeaderCell", bundle: nil), forCellReuseIdentifier: "CloudFileV3ZoneHeaderCell")
        self.tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(loadData(_:)))
        self.loadIsZoneCreator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.loadData(nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let id = segue.identifier, id == "openZoneForm", let zone = sender as? CloudFileV3Zone, let vc = segue.destination as? CloudFileV3ZoneFormViewController {
            vc.oldZone = zone
        }
    }
    
    
    func loadIsZoneCreator() {
        self.cFileVM.isZoneCreator().then { r in
            if r { // 有创建共享区的权限
                self.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: UIImage(named: "add"), style: .plain, target: self, action: #selector(self.addZone))]
            }
        }.catch { e in
            DDLogError(e.localizedDescription)
        }
    }
    
    // 加载列表数据 收藏的共享区和我能看到的共享区
    @objc func loadData(_ sender:AnyObject?) {
        self.showLoading()
        self.cFileVM.loadAllZoneAndFavoriteList().then { list in
            self.finishLoading()
            self.myZoneData = list
            self.tableView.reloadData()
        }.catch { error in
            self.finishLoading()
            self.showError(title: "\(error.localizedDescription)")
        }
    }
    
    private func finishLoading() {
        self.hideLoading()
        if self.tableView.mj_header.isRefreshing() == true {
            self.tableView.mj_header.endRefreshing()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.myZoneData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myZoneData[section]?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let data = self.myZoneData[indexPath.section]?[indexPath.row] {
            switch data.dataType {
            case .header(_):
                return 44
            default:
                return 60
            }
        }
        return 60
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let data = self.myZoneData[indexPath.section]?[indexPath.row] {
            switch data.dataType {
            case .header(_):
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CloudFileV3ZoneHeaderCell", for: indexPath) as? CloudFileV3ZoneHeaderCell {
                    cell.setHeader(header: data)
                    return cell
                } else {
                    return UITableViewCell()
                }
            default:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CloudFileV3ZoneCell", for: indexPath) as? CloudFileV3ZoneCell {
                    cell.delegate = self
                    cell.setData(data: data)
                    return cell
                } else {
                    return UITableViewCell()
                }
            }
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        if let data = self.myZoneData[indexPath.section]?[indexPath.row] {
            switch data.dataType {
            case .zone(let zone):
                if let z = zone as? CloudFileV3Zone {
                    self.openZoneFileList(id: z.id ?? "", name: z.name ?? "")
                }
                break
            case .favorite(let fav):
                if let f = fav as? CloudFileV3Favorite {
                    self.openZoneFileList(id: f.zoneId ?? "", name: f.name ?? "")
                }
                break
            default:
                break
            }
        }
    }
    
    private func openZoneFileList(id: String, name: String) {
        if let zoneFileVC = self.storyboard?.instantiateViewController(withIdentifier: "cloudFileListMultiModeVC") as? CloudFileListController {
            zoneFileVC.showMode = .zone
            let first = OOFolder()
            first.id = id
            first.name = name
            zoneFileVC.breadcrumbList = [first]
            self.pushVC(zoneFileVC)
        }
    }
    
    
    
    /// Section 圆角背景计算
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //圆率
        let cornerRadius:CGFloat = 10.0
        //大小
        let bounds:CGRect  = cell.bounds
        //行数
        let numberOfRows = tableView.numberOfRows(inSection: indexPath.section)
        //绘制曲线
        var bezierPath: UIBezierPath? = nil
        if (indexPath.row == 0 && numberOfRows == 1) {
            //一个为一组时,四个角都为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == 0) {
            //为组的第一行时,左上、右上角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.topLeft, .topRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else if (indexPath.row == numberOfRows - 1) {
            //为组的最后一行,左下、右下角为圆角
            bezierPath = UIBezierPath(roundedRect: bounds, byRoundingCorners:  [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        } else {
            //中间的都为矩形
            bezierPath = UIBezierPath(rect: bounds)
        }
        //cell的背景色透明
        cell.backgroundColor = .clear
        //新建一个图层
        let layer = CAShapeLayer()
        //图层边框路径
        layer.path = bezierPath?.cgPath
        //图层填充色,也就是cell的底色
        layer.fillColor = UIColor.white.cgColor
        //图层边框线条颜色
        /*
         如果self.tableView.style = UITableViewStyleGrouped时,每一组的首尾都会有一根分割线,目前我还没找到去掉每组首尾分割线,保留cell分割线的办法。
         所以这里取巧,用带颜色的图层边框替代分割线。
         这里为了美观,最好设为和tableView的底色一致。
         设为透明,好像不起作用。
         */
        layer.strokeColor = UIColor.white.cgColor
        //将图层添加到cell的图层中,并插到最底层
        cell.layer.insertSublayer(layer, at: 0)
        
    }
    
    
    @objc private func addZone() {
        self.performSegue(withIdentifier: "openZoneForm", sender: nil)
    }
    
    
    private func deleteZone(id: String, name: String) {
        self.showDefaultConfirm(title: L10n.alert, message: L10n.cloudFileV3ConfirmDeleteZone(name)) { _ in
            self.cFileVM.deleteZone(id: id)
                .then { _ in
                    self.loadData(nil)
                }.catch { e in
                    self.showError(title: "\(e.localizedDescription)")
                }
        }
    }
    
    private func addFavorite(name: String, zoneId: String) {
        self.cFileVM.addFavorite(name: name, zoneId: zoneId)
            .then { _ in
                self.loadData(nil)
            }.catch { e in
                self.showError(title: "\(e.localizedDescription)")
            }
    }

    private func cancelFavorite(id: String) {
        self.cFileVM.cancelFavorite(id: id)
            .then { _ in
                self.loadData(nil)
            }.catch { e in
                self.showError(title: "\(e.localizedDescription)")
            }
    }
    
    private func renameFavorite(id: String, oldName: String) {
        self.showPromptAlert(title: L10n.alert, message: L10n.cloudFileV3MessageAlertRenameFavorite, inputText: oldName) { _, newName in
            if newName == "" || newName.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
                self.showError(title: L10n.cloudFileV3MessageNameNotEmpty)
            } else {
                self.cFileVM.renameFavorite(id: id, name: newName)
                    .then { _ in
                        self.loadData(nil)
                    }.catch { e in
                        self.showError(title: "\(e.localizedDescription)")
                    }
            }
        }
    }

  
    // 显示收藏的菜单
    private func showFavriteMenu(fav: CloudFileV3Favorite) {
        let menus: [UIAlertAction] = [
            UIAlertAction(title: L10n.cloudFileV3MenuCancelFav, style: .default, handler: { action in
                // 取消收藏
                if let id = fav.id {
                    self.cancelFavorite(id: id)
                }
            }),
            UIAlertAction(title: L10n.cloudFileV3MenuRenameFav, style: .default, handler: { action in
                // 重命名收藏
                self.renameFavorite(id: fav.id ?? "", oldName: fav.name ?? "")
            })
        ]
        self.showSheetAction(title: L10n.alert, message: "", actions: menus)
    }
    // 显示共享区的菜单
    private func showZoneMenu(zone: CloudFileV3Zone) {
        var menus: [UIAlertAction] = [UIAlertAction(title: L10n.cloudFileV3MenuAddFav, style: .default, handler: { action in
            // 加入收藏
            self.addFavorite(name: zone.name ?? "", zoneId: zone.id ?? "")
        })]
        if zone.isAdmin == true {
            menus.append(
                UIAlertAction(title: L10n.cloudFileV3MenuEditZone, style: .default, handler: { action in
                    // 编辑
                    self.performSegue(withIdentifier: "openZoneForm", sender: zone)
                }))
            menus.append(
                UIAlertAction(title: L10n.cloudFileV3MenuDeleteZone, style: .default, handler: { action in
                    // 删除
                    self.deleteZone(id: zone.id ?? "", name: zone.name ?? "")
                }))
        }
        self.showSheetAction(title: L10n.alert, message: "", actions: menus)
    }
    
}


extension CloudFileZoneViewController: CloudFileV3ZoneCellMoreDelegate {
    func clickMore(data: CloudFileV3CellViewModel) {
        switch(data.dataType) {
        case .favorite(let fav):
            if let f = fav as? CloudFileV3Favorite {
                self.showFavriteMenu(fav: f)
            }
            break
        case .zone(let zone):
            if let z = zone as? CloudFileV3Zone {
                self.showZoneMenu(zone: z)
            }
            break
        default:
            break
        }
    }
    
    
}
