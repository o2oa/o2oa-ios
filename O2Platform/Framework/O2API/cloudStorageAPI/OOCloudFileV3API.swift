//
//  OOCloudFileV3API.swift
//  O2Platform
//
//  Created by FancyLou on 2022/5/30.
//  Copyright © 2022 zoneland. All rights reserved.
//

import Foundation
import Moya




// MARK:- 所有调用的API枚举
enum OOCloudFileV3API {
    // v3
    case echo
    case myFavoriteList
    case myZoneList
    case isZoneCreator
    case createZone(CloudFileV3ZonePost)
    case updateZone(String, CloudFileV3ZonePost)
    case deleteZone(String)
    case createFavorite(CloudFileV3FavoritePost)
    case updateFavorite(String, CloudFileV3FavoritePost)
    case deleteFavorite(String)
    case listFileByFolderIdV3(String) // 根据目录id查询文件列表
    case listFolderByFolderIdV3(String)// 根据目录id查询文件夹列表
    case createFolderV3(String, String)
    // folderId, fileName , file
    case uploadFileV3(String, String, Data)
    case updateFolderNameV3(String, RenamePost)
    case updateFileNameV3(String, RenamePost)
    case deleteFileV3(String)
    case deleteFolderV3(String)
    case moveToMyPan(String, MoveToMyPanPost)
    case moveFolderV3(String, MoveV3Post)
    case moveFileV3(String, MoveV3Post)
    case getFileV3(String) //
    case downloadFileV3(OOAttachmentV3)
    
    
    //新版v2
    case listTop
    case listFolderTop
    case listByFolder(String)
    case listFolderByFolder(String)
    case createFolder(String, String)
    case getFile(String)
    // folderId, fileName , file
    case uploadFile(String, String, Data)
    //fileId, file
    case updateFile(String, OOAttachment)
    //folderId folder
    case updateFolder(String, OOFolder)
    case deleteFolder(String)
    case deleteFile(String)
    //分享
    case share(OOShareForm)
    //分类查询 分页 type: String, page: Int, count: Int
    case listTypeByPage(String, Int, Int)
    case downloadFile(OOAttachment)
    //fileType = attachment | folder
    case shareToMe(String)
    //fileType = attachment | folder
    case myShareList(String)
    case shareFileListWithFolderId(String, String)
    case shareFolderListWithFolderId(String, String)
    case shieldShare(String)
    case deleteMyShare(String)
    
    // 上传文件 fileName referencetype reference scale file
    case uploadImageWithReferencetype(String, String, String, Int, Data)
    
    //老版
    //获取当前人员顶层文件夹 - jaxrs/complex/folder/##id##
    case listFolder(String)
    //jaxrs/share/list
    case listMyShare
    //jaxrs/editor/list
    case listMyEditor
    //jaxrs/attachment/{id}
    case listMyShareByPerson(String)
    
    case listMyEditorByPerson(String)
    
    case getPicItemURL(String)
    
    case getAttachment(String)
    // jaxrs/attachment/{id}/download/stream
    case downloadAttachment(OOAttachment)
    //*
    case deleteAttachement(String)
    
    case renameAttachment(String)
    
    case uploadAttachment(String?)
    
}

// MARK:- 上下文实现
extension OOCloudFileV3API:OOAPIContextCapable {
    var apiContextKey: String {
        return "x_pan_assemble_control"
    }
}


// MARK: - 是否需要加入x-token访问头
extension OOCloudFileV3API:OOAccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return true
    }
}

// MARK: - MoyaAPI实现
extension OOCloudFileV3API:TargetType{
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_pan_assemble_control)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
   
    var path: String {
        switch self {
            //v3
        case .echo:
            return "/jaxrs/echo"
        case .myFavoriteList:
            return "/jaxrs/favorite/list"
        case .myZoneList:
            return "/jaxrs/zone/list"
        case .isZoneCreator:
            return "/jaxrs/config/is/zone/creator"
        case .createZone(_):
            return "/jaxrs/zone"
        case .updateZone(let id, _):
            return "/jaxrs/zone/\(id)/update"
        case .deleteZone(let id):
            return "/jaxrs/zone/\(id)"
        case .createFavorite(_):
            return "/jaxrs/favorite"
        case .updateFavorite(let id, _):
            return "/jaxrs/favorite/\(id)/update"
        case .deleteFavorite(let id):
            return "/jaxrs/favorite/\(id)"
        case .listFolderByFolderIdV3(let folderId):
            return "/jaxrs/folder3/list/\(folderId)/order/by/updateTime/desc/true"
        case .listFileByFolderIdV3(let folderId):
            return "/jaxrs/attachment3/list/folder/\(folderId)/order/by/updateTime/desc/true"
        case .createFolderV3(_, _):
            return "/jaxrs/folder3"
        case .uploadFileV3(let folderId, _, _):
            return "/jaxrs/attachment3/upload/folder/\(folderId)"
        case .updateFolderNameV3(let id, _):
            return "/jaxrs/folder3/\(id)/update/name"
        case .updateFileNameV3(let id, _):
            return "/jaxrs/attachment3/\(id)/update/name"
        case .deleteFileV3(let id):
            return "/jaxrs/attachment3/\(id)"
        case .deleteFolderV3(let id):
            return "/jaxrs/folder3/\(id)"
        case .moveToMyPan(let personFolder, _):
            return "/jaxrs/folder3/save/to/person/\(personFolder)"
        case .moveFileV3(let id, _):
            return "/jaxrs/attachment3/\(id)/move"
        case .moveFolderV3(let id, _):
            return "/jaxrs/folder3/\(id)/move"
        case .getFileV3(let id):
            return "/jaxrs/attachment3/\(id)"
        case .downloadFileV3(let file):
            return "/jaxrs/attachment3/\(file.id!)/download/stream"
            
            
            //v2
        case .listTop:
            return "/jaxrs/attachment2/list/top/order/by/updateTime/desc/true"
        case .listFolderTop:
            return "/jaxrs/folder2/list/top/order/by/updateTime/desc/true"
        case .listByFolder(let folderId):
            return "/jaxrs/attachment2/list/folder/\(folderId)/order/by/updateTime/desc/true"
        case .listFolderByFolder(let folderId):
            return "/jaxrs/folder2/list/\(folderId)/order/by/updateTime/desc/true"
        case .createFolder(_, _):
            return "/jaxrs/folder2"
        case .uploadFile(let folderId, _, _):
            return "/jaxrs/attachment2/upload/folder/\(folderId)"
        case .updateFile(let fileId, _), .deleteFile(let fileId):
            return "/jaxrs/attachment2/\(fileId)"
        case .getFile(let fileId):
            return "jaxrs/attachment2/\(fileId)"
        case .updateFolder(let folderId, _), .deleteFolder(let folderId):
            return "/jaxrs/folder2/\(folderId)"
        case .share(_):
            return "/jaxrs/share"
        case .listTypeByPage(_, let page, let count):
            return "/jaxrs/attachment2/list/type/\(page)/size/\(count)"
        case .downloadFile(let file):
            return "/jaxrs/attachment2/\(file.id!)/download/stream"
        case .shareToMe(let fileType):
            return "/jaxrs/share/list/to/me2/\(fileType)"
        case .myShareList(let fileType):
            return "/jaxrs/share/list/my2/member/\(fileType)"
        case .shareFolderListWithFolderId(let shareId, let folderId):
            return "/jaxrs/share/list/folder/share/\(shareId)/folder/\(folderId)/"
        case .shareFileListWithFolderId(let shareId, let folderId):
            return "/jaxrs/share/list/att/share/\(shareId)/folder/\(folderId)/"
        case .shieldShare(let shareId):
            return "/jaxrs/share/shield/\(shareId)"
        case .deleteMyShare(let shareId):
            return "/jaxrs/share/\(shareId)"
            
        case .uploadImageWithReferencetype(_, let referencetype, let reference, let scale, _):
            return "/jaxrs/file/upload/referencetype/\(referencetype)/reference/\(reference)/scale/\(scale)"
        case .listFolder(let folderId):
            return "/jaxrs/complex/folder/\(folderId)"
        case .listMyShare:
            return "/jaxrs/share/list"
        case .listMyEditor:
            return "/jaxrs/editor/list"
        case .listMyShareByPerson(let personId):
            return "/jaxrs/attachment/list/share/\(personId)"
        case .listMyEditorByPerson(let personId):
            return "/jaxrs/attachment/list/editor/\(personId)"
        case .getAttachment(let attachmentId),.deleteAttachement(let attachmentId),.renameAttachment(let attachmentId):
            return "/jaxrs/attachment/\(attachmentId)"
        case .getPicItemURL(let id):
            return "\(self.baseURL.absoluteString)/jaxrs/file/\(id)/download/stream"
        case .downloadAttachment(let attachment):
            return "/jaxrs/attachment/\(attachment.id!)/download/stream"
        case .uploadAttachment(let folderId):
            if folderId == nil {
                return "jaxrs/attachment/upload"
            }else{
                return "jaxrs/attachment/upload/folder/\(folderId!)"
            }
        }
    }
    
    var method: Moya.Method {
        switch self {
            //v3
        case .echo, .myZoneList, .myFavoriteList, .isZoneCreator, .listFileByFolderIdV3(_), .listFolderByFolderIdV3(_), .getFileV3(_), .downloadFileV3(_):
            return .get
        case .createZone(_), .updateZone(_, _), .createFavorite(_), .updateFavorite(_, _), .createFolderV3(_, _),
                .uploadFileV3(_, _, _), .updateFileNameV3(_, _), .updateFolderNameV3(_, _), .moveFileV3(_, _),
                .moveFolderV3(_, _), .moveToMyPan(_, _):
            return .post
        case .deleteZone(_), .deleteFavorite(_), .deleteFolderV3(_), .deleteFileV3(_):
            return .delete
         // v2
        case .listTop, .listFolderTop, .listByFolder(_), .listFolderByFolder(_), .downloadFile(_), .getFile(_):
           return .get
        case .listFolder(_), .shareToMe(_), .myShareList(_), .shareFileListWithFolderId(_, _), .shareFolderListWithFolderId(_, _), .shieldShare(_):
            return .get
        case .listMyShare:
            return .get
        case .listMyEditor:
            return .get
        case .listMyShareByPerson(_):
            return .get
        case .listMyEditorByPerson(_):
            return .get
        case .getAttachment(_):
            return .get
        case .getPicItemURL(_):
            return .get
        case .deleteAttachement(_), .updateFolder(_, _), .updateFile(_, _), .uploadImageWithReferencetype(_, _, _, _, _):
            return .put
        case .uploadAttachment(_), .downloadAttachment(_),
            .renameAttachment(_), .createFolder(_, _), .uploadFile(_,_,_), .share(_),.listTypeByPage(_, _, _):
            return .post
        case .deleteFolder(_), .deleteFile(_), .deleteMyShare(_):
            return .delete
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
            // v3
        case .echo, .myFavoriteList, .myZoneList, .isZoneCreator, .deleteZone(_), .deleteFavorite(_), .listFileByFolderIdV3(_), .listFolderByFolderIdV3(_), .getFileV3(_):
            return.requestPlain
        case .createZone(let zone), .updateZone(_, let zone):
            return .requestParameters(parameters: zone.toJSON()!, encoding: JSONEncoding.default)
        case .createFavorite(let fav), .updateFavorite(_, let fav):
            return .requestParameters(parameters: fav.toJSON()!, encoding: JSONEncoding.default)
        case .createFolderV3(let name, let superior):
            return .requestParameters(parameters: ["name":name, "superior": superior], encoding: JSONEncoding.default)
        case .uploadFileV3(_, let fileName, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData])
        case .updateFileNameV3(_, let body), .updateFolderNameV3(_, let body) :
            return .requestParameters(parameters: body.toJSON()!, encoding: JSONEncoding.default)
        case .moveFileV3(_, let body), .moveFolderV3(_, let body):
            return .requestParameters(parameters: body.toJSON()!, encoding: JSONEncoding.default)
        case .moveToMyPan(_, let body):
            return .requestParameters(parameters: body.toJSON()!, encoding: JSONEncoding.default)
        case .deleteFileV3(_), .deleteFolderV3(_):
            return .requestPlain
            
        case .listFolderByFolder(_), .listByFolder(_), .listTop,.listFolderTop,.listFolder(_),.listMyEditorByPerson(_),.listMyShareByPerson(_),
             .listMyEditor,.listMyShare,.getAttachment(_),.deleteAttachement(_),.getPicItemURL(_), .deleteFolder(_), .deleteFile(_),
             .getFile(_), .shareFileListWithFolderId(_, _), .shareFolderListWithFolderId(_, _):
            return .requestPlain
        case .shareToMe(_):
            return .requestPlain
        case .myShareList(_), .deleteMyShare(_), .shieldShare(_):
            return .requestPlain
        case .downloadFile(let attachment):
            let myDest = getDownDest(attachment)
            return .downloadDestination(myDest)
        case .downloadAttachment(let attachment):
            let myDest = getDownDest(attachment)
            return .downloadDestination(myDest)
        case .downloadFileV3(let attachment3):
            let myDest = getDownDestV3(attachment3)
            return .downloadDestination(myDest)
        case .renameAttachment(_):
            return .requestPlain
        case .uploadAttachment(_):
            return .requestPlain
            
        //新接口
        case .createFolder(let name, let superior):
            return .requestParameters(parameters: ["name":name, "superior": superior], encoding: JSONEncoding.default)
        case .uploadFile(_, let fileName, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData])
            
        case .updateFolder(_, let folder):
            return .requestParameters(parameters: folder.toJSON()!, encoding: JSONEncoding.default)
        case .updateFile(_, let file):
            return .requestParameters(parameters: file.toJSON()!, encoding: JSONEncoding.default)
        case .share(let form):
            return .requestParameters(parameters: form.toJSON()!, encoding: JSONEncoding.default)
        case .listTypeByPage(let type, _, _):
            return .requestParameters(parameters: ["fileType": type], encoding: JSONEncoding.default)
            
        case .uploadImageWithReferencetype(let fileName, _, _, _, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData])
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    func getDownDest(_ attachment:OOAttachment) -> DownloadDestination {
        let myDest:DownloadDestination = { temporaryURL, response in
            let fileURL = O2CloudFileManager.shared.cloudFileLocalPath(file: attachment)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return myDest
    }
    
    func getDownDestV3(_ attachment:OOAttachmentV3) -> DownloadDestination {
        let myDest:DownloadDestination = { temporaryURL, response in
            let fileURL = O2CloudFileManager.shared.cloudFileV3LocalPath(file: attachment)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        return myDest
    }
}
