//
//  CloudFileViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2019/10/16.
//  Copyright © 2019 zoneland. All rights reserved.
//

import Moya
import Promises
import CocoaLumberjack
import Combine



protocol CloudFileCheckDelegate {
    func checkItem(_ item: DataModel)
}

protocol CloudFileCheckClickDelegate {
    func clickFolder(_ folder: OOFolder)
    func clickFile(_ file: OOAttachment)
    func clickFolderV3(_ folder: OOFolderV3)
    func clickFileV3(_ file: OOAttachmentV3)
}

class CloudFileViewModel: NSObject {
    override init() {
        super.init()
    }
    
    private let cFileAPI = OOMoyaProvider<OOCloudStorageAPI>()
    
    // v3 网盘
    private let cFileV3API = OOMoyaProvider<OOCloudFileV3API>()
    
    // 是否使用v3版本的api 就是x_pan_assemble_control模块
    private let useV3Api: Bool = {
        let value = StandDefaultUtil.share.userDefaultGetValue(key: O2.O2CloudFileVersionKey) as? Bool
        return value == true
    }()
    
    
    
    
    // MARK: - V3 新加的企业网盘相关api
    
    
    // 判断网盘v3版本是否存在
    func v3Echo() -> Promise<Bool> {
        return Promise { fulfill, reject in
            self.cFileV3API.request(.echo) { result in
                let response = OOResult<BaseModelClass<OOEchoModel>>(result)
                if response.isResultSuccess() {
                    if let _ = response.model?.data {
                        DDLogInfo("网盘v3版本")
                        fulfill(true)
                    } else {
                        fulfill(false)
                    }
                }else {
                    fulfill(false)
                }
            }
        }
    }
    
    /// 企业共享区列表 包含我的收藏
    func loadAllZoneAndFavoriteList() -> Promise<[Int:[CloudFileV3CellViewModel]]> {
        return Promise { fulfill, reject in
            all(self.myFavoriteList(), self.myZoneList()).then { results in
                var all : [Int:[CloudFileV3CellViewModel]] = [:]
                let favoriteList = results.0
                if favoriteList.count > 0 {
                    var list0: [CloudFileV3CellViewModel] = []
                    let header = CloudFileV3ZoneHeader()
                    header.name = L10n.cloudFileMyFavorite
                    list0.append(CloudFileV3CellViewModel(name: header.name, sourceObject: header))
                    favoriteList.forEach { fav in
                        list0.append(CloudFileV3CellViewModel(name: fav.name, sourceObject: fav))
                    }
                    all[0] = list0
                }
                
                let zoneList = results.1
                if zoneList.count > 0 {
                    var list1: [CloudFileV3CellViewModel] = []
                    let header = CloudFileV3ZoneHeader()
                    header.name = L10n.cloudFileMyZone
                    list1.append(CloudFileV3CellViewModel(name: header.name, sourceObject: header))
                    zoneList.forEach { zone in
                        list1.append(CloudFileV3CellViewModel(name: zone.name, sourceObject: zone))
                    }
                    all[all.count] = list1
                }
                fulfill(all)
            }.catch { (error) in
                reject(error)
            }
        }
    }
    // 企业网盘 我的收藏 共享区
    private func myFavoriteList() -> Promise<[CloudFileV3Favorite]> {
        return Promise {fulfill, reject in
            self.cFileV3API.request(.myFavoriteList) { result in
                let response = OOResult<BaseModelClass<[CloudFileV3Favorite]>>(result)
                if response.isResultSuccess() {
                    if let list = response.model?.data {
                        fulfill(list)
                    } else {
                        fulfill([])
                    }
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 我的共享区
    private func myZoneList() -> Promise<[CloudFileV3Zone]> {
        return Promise {fulfill, reject in
            self.cFileV3API.request(.myZoneList) { result in
                let response = OOResult<BaseModelClass<[CloudFileV3Zone]>>(result)
                if response.isResultSuccess() {
                    if let list = response.model?.data {
                        fulfill(list)
                    } else {
                        fulfill([])
                    }
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 是否有创建共享区的权限
    func isZoneCreator() -> Promise<Bool> {
        return Promise {fulfill, _ in
            self.cFileV3API.request(.isZoneCreator) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() && response.model?.data?.value == true  {
                    fulfill(true)
                } else {
                    fulfill(false)
                }
            }
        }
    }
    // 创建共享区
    func createZone(name: String, desc: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            let zone = CloudFileV3ZonePost()
            zone.name = name
            zone.desc = desc
            self.cFileV3API.request(.createZone(zone)) { result in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() , let _ = response.model?.data {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "创建失败！", statusCode: 1000))
                }
            }
        }
    }
    // 更新共享区
    func updateZone(id: String, name: String, desc: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            let zone = CloudFileV3ZonePost()
            zone.name = name
            zone.desc = desc
            self.cFileV3API.request(.updateZone(id, zone)) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() && response.model?.data?.value == true {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "修改失败！", statusCode: 1001))
                }
            }
        }
    }
    // 删除共享区
    func deleteZone(id: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            self.cFileV3API.request(.deleteZone(id)) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() && response.model?.data?.value == true {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "删除失败！", statusCode: 1002))
                }
            }
        }
    }
    // 加入收藏
    func addFavorite(name: String, zoneId: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            let fav = CloudFileV3FavoritePost()
            fav.name = name
            fav.folder = zoneId
            self.cFileV3API.request(.createFavorite(fav)) { result in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() , let _ = response.model?.data {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "添加收藏失败！", statusCode: 1000))
                }
            }
        }
    }
    
    // 重命名收藏
    func renameFavorite(id: String, name: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            let fav = CloudFileV3FavoritePost()
            fav.name = name
            self.cFileV3API.request(.updateFavorite(id, fav)) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() && response.model?.data?.value == true {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "重命名失败！", statusCode: 1001))
                }
            }
        }
    }
    
    // 删除共享区
    func cancelFavorite(id: String) -> Promise<Bool> {
        return Promise{ fulfill, reject in
            self.cFileV3API.request(.deleteFavorite(id)) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() && response.model?.data?.value == true {
                    fulfill(true)
                } else {
                    reject(response.error ?? OOAppError.common(type: "", message: "取消收藏失败！", statusCode: 1002))
                }
            }
        }
    }
    
    
    //共享工作区 获取列表 包含文件夹和文件
    func loadZoneFileListByFolderId(folderParentId: String) -> Promise<[DataModel]> {
        return Promise{ fulfill, reject in
            all(self.folderListV3(folderId: folderParentId), self.fileListV3(folderId: folderParentId))
                .then { (result) in
                    var dataList: [DataModel] = []
                    let folderList = result.0
                    DDLogInfo("文件夹：\(folderList.count)")
                    for folder in folderList {
                        dataList.append(folder)
                    }
                    let fileList = result.1
                    DDLogInfo("文件：\(fileList.count)")
                    for file in fileList {
                        dataList.append(file)
                    }
                    fulfill(dataList)
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                   reject(error)
            }
        }
    }
    
    // 共享工作区 文件列表
    func fileListV3(folderId: String) -> Promise<[OOAttachmentV3]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOAttachmentV3]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(OOAppError.common(type: "cloudFile", message: response.error?.localizedDescription ?? "", statusCode: 1024))
                }
            }
            
            self.cFileV3API.request(.listFileByFolderIdV3(folderId), completion:completion)
        }
        
    }
    
    // 共享工作区 文件夹列表
    func folderListV3(folderId: String) -> Promise<[OOFolderV3]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOFolderV3]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            self.cFileV3API.request(.listFolderByFolderIdV3(folderId), completion:completion)
        }
        
    }
    
    // 共享工作区 创建文件夹
    func createFolderV3(name: String, superior: String = "") -> Promise<String> {
        return Promise { fulfill, reject in
            let completion: Completion =  { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        fulfill(id.id ?? "")
                    }else {
                        fulfill("")
                    }
                }else {
                    reject(response.error!)
                }
            }
            self.cFileV3API.request(.createFolderV3(name, superior), completion: completion)
        }
    }
    // 共享工作区 上传文件
    func uploadFileV3(folderId: String, fileName: String, file: Data) -> Promise<String> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        fulfill(id.id ?? "")
                    }else {
                        fulfill("")
                    }
                }else {
                    reject(response.error!)
                }
            }
            self.cFileV3API.request(.uploadFileV3(folderId, fileName, file), completion: completion)
        }
    }
    
    // 共享工作区  删除文件
    func deleteFileV3(id: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("删除文件成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            self.cFileV3API.request(.deleteFileV3(id), completion: completion)
            
        }
    }
    
    // 共享工作区 删除文件夹
    func deleteFolderV3(id: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("删除文件夹成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            self.cFileV3API.request(.deleteFolderV3(id), completion: completion)
        }
    }
    
    // 重命名文件夹
    func renameFolderV3(id: String, newName: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("重命名文件夹成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            let body = RenamePost()
            body.name = newName
            self.cFileV3API.request(.updateFolderNameV3(id, body), completion: completion)
        }
    }
    
    // 重命名文件
    func renameFileV3(id: String, newName: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("重命名文件成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            let body = RenamePost()
            body.name = newName
            self.cFileV3API.request(.updateFileNameV3(id, body), completion: completion)
        }
    }
    
    // 保存文件、文件夹到我的网盘
    func saveToMyPan(parentId: String, files:[String], folders:[String]) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("保存文件到我的网盘成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            let body = MoveToMyPanPost()
            body.folderIdList = folders
            body.attIdList = files
            self.cFileV3API.request(.moveToMyPan(parentId, body), completion: completion)
        }
    }
    
    
    // 企业网盘内 移动文件夹
    func moveV3Folder(folder: OOFolderV3, destFolder: OOFolderV3) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                     DDLogDebug("移动文件夹成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            let movePost = MoveV3Post()
            movePost.folder = destFolder.id
            movePost.superior = destFolder.id
            movePost.name = folder.name
            self.cFileV3API.request(.moveFolderV3(folder.id ?? "", movePost), completion: completion)
        }
    }
    
    // 企业网盘内 移动文件
    func moveV3File(file: OOAttachmentV3, destFolder: OOFolderV3) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                     DDLogDebug("移动文件成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            let movePost = MoveV3Post()
            movePost.folder = destFolder.id
            movePost.superior = destFolder.id
            movePost.name = file.name
            self.cFileV3API.request(.moveFileV3(file.id ?? "", movePost), completion: completion)
        }
    }
    
    //移动操作
    func moveV3(folderList: [OOFolderV3], fileList: [OOAttachmentV3], destFolder: OOFolderV3) -> Promise<Bool> {
        return Promise { fulfill, reject in
            var fileMove : [Promise<Bool>] = []
            folderList.forEach({ (folder) in
                folder.superior = destFolder.id!
                fileMove.append(self.moveV3Folder(folder: folder, destFolder: destFolder))
            })
            fileList.forEach({ (file) in
                file.folder = destFolder.id!
                fileMove.append(self.moveV3File(file: file, destFolder: destFolder))
            })
            all(fileMove).then({ (results) in
                results.forEach({ (r) in
                    DDLogDebug("移动成功， \(r)")
                })
                fulfill(true)
            }).catch({ (error) in
                reject(error)
            })
        }
    }
    
    
    
    
    
    // MARK: - V2 版本api 根据当前环境查询不同的 网盘模块 x_file_assemble_control ｜ x_pan_assemble_control
    
    //获取图片地址 根据传入的大小进行比例缩放
    func scaleImageUrl(id: String) -> String {
        var model: O2APIServerModel?
        if useV3Api {
            model = O2AuthSDK.shared.o2APIServer(context: .x_pan_assemble_control)
        } else {
            model = O2AuthSDK.shared.o2APIServer(context: .x_file_assemble_control)
        }
        var baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            baseURLString = trueUrl
        }
        //固定200px
        let width = 200
        let height = 200
        return baseURLString + "/jaxrs/attachment2/\(id)/download/image/width/\(width)/height/\(height)"
    }
    
    //获取图片地址 原图
//    func originImageUrl(id: String) -> String {
//        let model = O2AuthSDK.shared.o2APIServer(context: .x_file_assemble_control)
//        var baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
//        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
//            baseURLString = trueUrl
//        }
//        return baseURLString + "/jaxrs/attachment2/\(id)/download"
//    }
    
    //分页查询分类列表
    func listTypeByPage(type: CloudFileType, page: Int, count:Int) -> Promise<[OOAttachment]> {
        return Promise { fulfill, reject in
            var typeString: String
            switch type {
            case .image:
                typeString = "image"
                break
            case .office:
                typeString = "office"
                break
            case .movie:
                typeString = "movie"
                break
            case .music:
                typeString = "music"
                break
            case .other:
                typeString = "other"
                break
            }
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                if response.isResultSuccess() {
                    if let list = response.model?.data {
                        fulfill(list)
                    }else {
                         fulfill([])
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.listTypeByPage(typeString, page, count), completion: completion)
            } else {
                self.cFileAPI.request(.listTypeByPage(typeString, page, count), completion: completion)
            }
        }
    }
    
    //移动操作
    func moveToFolder(folderList: [OOFolder], fileList: [OOAttachment], destFolder: OOFolder) -> Promise<Bool> {
        return Promise { fulfill, reject in
            var fileMove : [Promise<Bool>] = []
            folderList.forEach({ (folder) in
                folder.superior = destFolder.id!
                fileMove.append(self.updateFolder(folder: folder))
            })
            fileList.forEach({ (file) in
                file.folder = destFolder.id!
                fileMove.append(self.updateFile(file: file))
            })
            all(fileMove).then({ (results) in
                results.forEach({ (r) in
                    DDLogDebug("移动成功， \(r)")
                })
                fulfill(true)
            }).catch({ (error) in
                reject(error)
            })
        }
    }
    
    //分享操作
    func share(folderList: [OOFolder], fileList: [OOAttachment], users: [O2PersonPickerItem], orgs: [O2UnitPickerItem]) -> Promise<Bool> {
        return Promise { fulfill, reject in
            var fileShare : [Promise<Bool>] = []
            var userIds: [String] = []
            var orgIds: [String] = []
            users.forEach({ (person) in
                userIds.append(person.distinguishedName!)
            })
            orgs.forEach({ (unit) in
                orgIds.append(unit.distinguishedName!)
            })
            folderList.forEach({ (folder) in
                fileShare.append(self.share(id: folder.id!, users: userIds, orgs: orgIds))
            })
            fileList.forEach({ (file) in
                fileShare.append(self.share(id: file.id!, users: userIds, orgs: orgIds))
            })
            all(fileShare).then({ (results) in
                results.forEach({ (r) in
                    DDLogDebug("分享成功， \(r)")
                })
                fulfill(true)
            }).catch({ (error) in
                reject(error)
            })
        }
    }
    
    //删除我分享的
    func deleteShareList(shareList: [String]) -> Promise<Bool> {
        return Promise { fulfill, reject in
            var fileShare : [Promise<Bool>] = []
            shareList.forEach { (id) in
                fileShare.append(self.deleteShare(shareId: id))
            }
            all(fileShare).then { (results) in
                results.forEach({ (r) in
                    DDLogDebug("删除分享， \(r)")
                })
                fulfill(true)
            }.catch { (err) in
                reject(err)
            }
        }
    }
    
    //屏蔽给我的分享
    func shieldShareList(shareList: [String]) -> Promise<Bool> {
         return Promise { fulfill, reject in
                   var fileShare : [Promise<Bool>] = []
                   shareList.forEach { (id) in
                       fileShare.append(self.shieldShare(shareId: id))
                   }
                   all(fileShare).then { (results) in
                       results.forEach({ (r) in
                           DDLogDebug("屏蔽分享， \(r)")
                       })
                    fulfill(true)
                   }.catch { (err) in
                       reject(err)
                   }
               }
    }
    
    //删除选中的数据 包含文件夹和文件
    func deleteCheckedList(folderList: [OOFolder], fileList: [OOAttachment]) -> Promise<Bool> {
        return Promise { fulfill, reject in
            var fileDelete : [Promise<Bool>] = []
            folderList.forEach({ (folder) in
                fileDelete.append(self.deleteFolder(id: folder.id!))
            })
            fileList.forEach({ (file) in
                fileDelete.append(self.deleteFile(id: file.id!))
            })
            all(fileDelete).then({ (results) in
                results.forEach({ (r) in
                    DDLogDebug("删除成功， \(r)")
                })
                fulfill(true)
            }).catch({ (error) in
                reject(error)
            })
        }
    }
    
    //重命名文件夹
    func updateFolder(folder: OOFolder) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                     DDLogDebug("重命名文件夹成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.updateFolder(folder.id!, folder), completion: completion)
            } else {
                self.cFileAPI.request(.updateFolder(folder.id!, folder), completion: completion)
            }
        }
    }
    
    //重命名文件
    func updateFile(file: OOAttachment) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("重命名文件成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.updateFile(file.id!, file), completion: completion)
            } else {
                self.cFileAPI.request(.updateFile(file.id!, file), completion: completion)
            }
            
        }
    }
    
    //获取分享给我的文件列表 包含文件夹和文件
    func loadShareToMeList(folderParentId: String, shareId: String) -> Promise<[DataModel]> {
        return Promise{ fulfill, reject in
            all(self.shareToMeFolderList(folderId: folderParentId, shareId: shareId), self.shareToMeFileList(folderId: folderParentId, shareId: shareId))
                .then { (result) in
                    var dataList: [DataModel] = []
                    let folderList = result.0
                    for folder in folderList {
                        dataList.append(folder)
                    }
                    let fileList = result.1
                    for file in fileList {
                        dataList.append(file)
                    }
                    fulfill(dataList)
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    reject(error)
            }
        }
    }
    
    func loadMyShareList(folderParentId: String, shareId: String) -> Promise<[DataModel]> {
        return Promise{ fulfill, reject in
            all(self.myShareFolderList(folderId: folderParentId, shareId: shareId), self.myShareFileList(folderId: folderParentId, shareId: shareId))
                .then { (result) in
                    var dataList: [DataModel] = []
                    let folderList = result.0
                    for folder in folderList {
                        dataList.append(folder)
                    }
                    let fileList = result.1
                    for file in fileList {
                        dataList.append(file)
                    }
                    fulfill(dataList)
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                    reject(error)
            }
        }
    }
    
    //获取列表 包含文件夹和文件
    func loadCloudFileList(folderParentId: String) -> Promise<[DataModel]> {
        return Promise{ fulfill, reject in
            all(self.folderList(folderId: folderParentId), self.fileList(folderId: folderParentId))
                .then { (result) in
                    var dataList: [DataModel] = []
                    let folderList = result.0
                    DDLogInfo("文件夹：\(folderList.count)")
                    for folder in folderList {
                        dataList.append(folder)
                    }
                    let fileList = result.1
                    DDLogInfo("文件：\(fileList.count)")
                    for file in fileList {
                        dataList.append(file)
                    }
                    fulfill(dataList)
                }.catch { (error) in
                    DDLogError(error.localizedDescription)
                   reject(error)
            }
        }
    }
    
    //文件列表
    func fileList(folderId: String) -> Promise<[OOAttachment]> {
        return Promise { fulfill, reject in
            
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(OOAppError.common(type: "cloudFile", message: response.error?.localizedDescription ?? "", statusCode: 1024))
                }
            }
            
            if folderId.isBlank {
                if self.useV3Api {
                    self.cFileV3API.request(.listTop, completion: completion)
                } else {
                    self.cFileAPI.request(.listTop, completion: completion)
                }
            } else {
                if self.useV3Api {
                    self.cFileV3API.request(.listByFolder(folderId), completion:completion)
                } else {
                    self.cFileAPI.request(.listByFolder(folderId), completion:completion)
                }
            }
        }
        
    }
    
    //文件夹列表
    func folderList(folderId: String) -> Promise<[OOFolder]> {
        
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOFolder]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            if folderId.isBlank {
                if self.useV3Api {
                    self.cFileV3API.request(.listFolderTop, completion: completion)
                } else {
                    self.cFileAPI.request(.listFolderTop, completion: completion)
                }
            } else {
                if self.useV3Api {
                    self.cFileV3API.request(.listFolderByFolder(folderId), completion:completion)
                } else {
                    self.cFileAPI.request(.listFolderByFolder(folderId), completion:completion)
                }
            }
        }
        
    }
    
    //创建文件夹
    func createFolder(name: String, superior: String = "") -> Promise<String> {
        return Promise { fulfill, reject in
            let completion: Completion =  { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        fulfill(id.id ?? "")
                    }else {
                        fulfill("")
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.createFolder(name, superior), completion: completion)
            } else {
                self.cFileAPI.request(.createFolder(name, superior), completion: completion)
            }
        }
    }
    
    //上传文件
    func uploadFile(folderId: String, fileName: String, file: Data) -> Promise<String> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        fulfill(id.id ?? "")
                    }else {
                        fulfill("")
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.uploadFile(folderId, fileName, file), completion: completion)
            } else {
                self.cFileAPI.request(.uploadFile(folderId, fileName, file), completion: completion)
            }
        }
    }
    
    
    // MARK: - private func
    
    //分享给我的文件夹列表
    private func shareToMeFolderList(folderId: String, shareId: String ) -> Promise<[OOFolder]> {
        if folderId.isBlank {
            return self.shareToMeTopFolderList()
        } else {
            return Promise { fulfill, reject in
                let completion: Completion = { (result) in
                    let response = OOResult<BaseModelClass<[OOFolder]>>(result)
                    if response.isResultSuccess() {
                        if let data = response.model?.data {
                            fulfill(data)
                        } else {
                            reject(OOAppError.apiEmptyResultError)
                        }
                    }else {
                        reject(response.error!)
                    }
                }
                if self.useV3Api {
                    self.cFileV3API.request(.shareFolderListWithFolderId(shareId, folderId), completion: completion)
                } else {
                    self.cFileAPI.request(.shareFolderListWithFolderId(shareId, folderId), completion: completion)
                }
                
            }
        }
    }
    
    //分享给我的顶层文件夹列表
    private func shareToMeTopFolderList() -> Promise<[OOFolder]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOFolder]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.shareToMe("folder"), completion: completion)
            } else {
                self.cFileAPI.request(.shareToMe("folder"), completion: completion)
            }
            
        }
    }
    
    //分享给我的文件列表
    func shareToMeFileList(folderId: String, shareId: String ) -> Promise<[OOAttachment]> {
        if folderId.isBlank {
            return self.shareToMeTopFileList()
        }else {
            return Promise { fulfill, reject in
                let completion: Completion = { (result) in
                    let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                    if response.isResultSuccess() {
                        if let data = response.model?.data {
                            fulfill(data)
                        } else {
                            reject(OOAppError.apiEmptyResultError)
                        }
                    }else {
                        reject(response.error!)
                    }
                }
                if self.useV3Api {
                    self.cFileV3API.request(.shareFileListWithFolderId(shareId, folderId), completion: completion)
                } else {
                    self.cFileAPI.request(.shareFileListWithFolderId(shareId, folderId), completion: completion)
                }
            }
        }
        
    }
    
    //分享给我的顶层文件列表
    private func shareToMeTopFileList() -> Promise<[OOAttachment]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.shareToMe("attachment"), completion: completion)
            } else {
                self.cFileAPI.request(.shareToMe("attachment"), completion: completion)
            }
        }
    }
    
    
    //我分享的顶层文件夹列表
    private func myShareFolderList(folderId: String, shareId: String) -> Promise<[OOFolder]> {
        if folderId.isBlank {
            return self.myShareTopFolderList()
        } else {
            return Promise { fulfill, reject in
                let completion: Completion = { (result) in
                    let response = OOResult<BaseModelClass<[OOFolder]>>(result)
                    if response.isResultSuccess() {
                        if let data = response.model?.data {
                            fulfill(data)
                        } else {
                            reject(OOAppError.apiEmptyResultError)
                        }
                    }else {
                        reject(response.error!)
                    }
                }
                if self.useV3Api {
                    self.cFileV3API.request(.shareFolderListWithFolderId(shareId, folderId), completion: completion)
                } else {
                    self.cFileAPI.request(.shareFolderListWithFolderId(shareId, folderId), completion: completion)
                }
                
            }
        }
    }
    
    //我分享的顶层文件夹列表
    private func myShareTopFolderList() -> Promise<[OOFolder]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOFolder]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.myShareList("folder"), completion: completion)
            } else {
                self.cFileAPI.request(.myShareList("folder"), completion: completion)
            }
            
        }
    }
    
    //分享给我的文件列表
    func myShareFileList(folderId: String, shareId: String) -> Promise<[OOAttachment]> {
        if folderId.isBlank {
            return self.myShareTopFileList()
        }else {
            return Promise { fulfill, reject in
                let completion: Completion = { (result) in
                    let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                    if response.isResultSuccess() {
                        if let data = response.model?.data {
                            fulfill(data)
                        } else {
                            reject(OOAppError.apiEmptyResultError)
                        }
                    }else {
                        reject(response.error!)
                    }
                }
                if self.useV3Api {
                    self.cFileV3API.request(.shareFileListWithFolderId(shareId, folderId), completion: completion)
                } else {
                    self.cFileAPI.request(.shareFileListWithFolderId(shareId, folderId), completion: completion)
                }
            }
        }
        
    }
    
    //我分享的顶层文件列表
    private func myShareTopFileList() -> Promise<[OOAttachment]> {
        return Promise { fulfill, reject in
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<[OOAttachment]>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        fulfill(data)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.myShareList("attachment"), completion: completion)
            } else {
                self.cFileAPI.request(.myShareList("attachment"), completion: completion)
            }
            
           
        }
    }
    
    //删除文件
    private func deleteFile(id: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("删除文件成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.deleteFile(id), completion: completion)
            } else {
                self.cFileAPI.request(.deleteFile(id), completion: completion)
            }
            
        }
    }
    
    //删除文件夹
    private func deleteFolder(id: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let  completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("删除文件夹成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.deleteFolder(id), completion: completion)
            } else {
                self.cFileAPI.request(.deleteFolder(id), completion: completion)
            }
            
        }
    }
    
    //分享
    private func share(id: String, users: [String], orgs: [String]) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let form = OOShareForm()
            form.fileId = id
            form.shareType = "member"
            form.shareUserList = users
            form.shareOrgList = orgs
            
            let completion: Completion = { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("分享成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.share(form), completion: completion)
            } else {
                self.cFileAPI.request(.share(form), completion: completion)
            }
            
            
        }
    }
    
    //删除分享
    private func deleteShare(shareId: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { result in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("删除分享成功：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.deleteMyShare(shareId), completion: completion)
            } else {
                self.cFileAPI.request(.deleteMyShare(shareId), completion: completion)
            }
            
           
        }
    }
    
    //屏蔽分享给我的文件
    private func shieldShare(shareId: String) -> Promise<Bool> {
        return Promise { fulfill, reject in
            let completion: Completion = { result in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data {
                        DDLogDebug("屏蔽分享给我的文件：\(id)")
                    }
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
            if self.useV3Api {
                self.cFileV3API.request(.shieldShare(shareId), completion: completion)
            } else {
                self.cFileAPI.request(.shieldShare(shareId), completion: completion)
            }
            
        }
    }
    
}
