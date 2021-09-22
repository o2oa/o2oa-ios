//
//  OOApplicationAPI.swift
//  o2app
//
//  Created by 刘振兴 on 2018/3/12.
//  Copyright © 2018年 zone. All rights reserved.
//

import Foundation
import Moya


// MARK:- 所有调用的API枚举
enum OOApplicationAPI {
    case applicationList
    case applicationOnlyList
    case applicationItem(String) // 更加应用获取流程列表
    case applicationItemWithFilter(String) //新版 根据应用获取流程列表 有移动端过滤 仅pc的流程不出现在这里
    case availableIdentityWithProcess(String)
    case startProcess(String, String, String) // processId identity title
    case icon(String)
    case workDelete(String)
    case dataUpdateWithWork(String,[String:AnyObject])
    case attachmentGetWithWorkOrWorkCompleted(String, String) // workOrWorkcompleted id
    case attachmentGetWithWork(String, String)
    case attachmentGetWithWorkCompleted(String, String)
    case attachmentDownloadWithWorkCompleted(String, String, URL) // id workcompleted path
    case attachmentDownloadWithWorkId(String, String, URL) // id workId path
    case attachmentUpload(String, String, String, Data) // 上传附件 workId site fileName fileData
    case attachmentReplace(String, String, String, String, Data) // 替换附件 attachmentId workId site  fileName fileData
    case taskListNext(String, Int) //分页查询待办列表
    case taskV2ListNext(String, Int, String) //分页查询待办列表
    case taskcompletedListNext(String, Int, String) //分页查询已办列表
    case taskcompletedV2ListNext(String, Int, String) //分页查询已办列表
    case readListNext(String, Int) //分页查询待阅列表
    case readV2ListNext(String, Int, String) //分页查询待阅列表
    case readcompletedListNext(String, Int) //分页查询已阅列表
    case readcompletedV2ListNext(String, Int, String) //分页查询已阅列表
    case taskcompletedGetReference(String) //已办的所有的相关的待办已办列表数据
}

// MARK:- 上下文实现
extension OOApplicationAPI:OOAPIContextCapable {
    var apiContextKey: String {
        return "x_processplatform_assemble_surface"
    }
}


// MARK: - 是否需要加入x-token访问头
extension OOApplicationAPI:OOAccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return true
    }
}

extension OOApplicationAPI:TargetType {
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_processplatform_assemble_surface)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        case .applicationList:
            return "/jaxrs/application/list/complex"
        case .applicationOnlyList:
            return "/jaxrs/application/list"
        case .applicationItem(let appId):
            return "/jaxrs/process/list/application/\(appId)"
        case .applicationItemWithFilter(let appId):
            return "/jaxrs/process/list/application/\(appId)/filter"
        case .availableIdentityWithProcess(let processId):
            return "/jaxrs/process/list/available/identity/process/\(processId)"
        case .startProcess(let processId, _, _):
            return "/jaxrs/work/process/\(processId)"
        case .icon(let applicationId):
            return "/jaxrs/application/\(applicationId)/icon"
        case .workDelete(let workId):
            return "/jaxrs/work/\(workId)"
        case .dataUpdateWithWork(let workId, _):
            return "/jaxrs/data/work/\(workId)"
        case .attachmentGetWithWorkOrWorkCompleted(let workOrWorkcompleted, let id):
            return "/jaxrs/attachment/\(id)/workorworkcompleted/\(workOrWorkcompleted)"
        case .attachmentGetWithWork(let work, let id):
            return "/jaxrs/attachment/\(id)/work/\(work)"
        case .attachmentGetWithWorkCompleted(let workCompletedId, let id):
            return "/jaxrs/attachment/\(id)/workcompleted/\(workCompletedId)"
        case .attachmentDownloadWithWorkCompleted(let id, let workcompleted, _):
            return "/jaxrs/attachment/download/\(id)/workcompleted/\(workcompleted)"
        case .attachmentDownloadWithWorkId(let id, let workId, _):
            return "/jaxrs/attachment/download/\(id)/work/\(workId)"
        case .attachmentUpload(let workId, _, _, _):
            return "/jaxrs/attachment/upload/work/\(workId)"
        case .attachmentReplace(let id, let workId, _, _, _):
            return "/jaxrs/attachment/update/\(id)/work/\(workId)"
        case .taskListNext(let lastId, let count):
            return "/jaxrs/task/list/\(lastId)/next/\(count)"
        case .taskV2ListNext(let lastId, let count, _):
            return "/jaxrs/task/v2/list/\(lastId)/next/\(count)"
        case .taskcompletedListNext(let lastId, let count, _):
            return "/jaxrs/taskcompleted/list/\(lastId)/next/\(count)/filter"
        case .taskcompletedV2ListNext(let lastId, let count, _):
            return "/jaxrs/taskcompleted/v2/list/\(lastId)/next/\(count)"
        case .readListNext(let lastId, let count):
            return "/jaxrs/read/list/\(lastId)/next/\(count)"
        case .readV2ListNext(let lastId, let count, _):
            return "/jaxrs/read/v2/list/\(lastId)/next/\(count)"
        case .readcompletedListNext(let lastId, let count):
            return "/jaxrs/readcompleted/list/\(lastId)/next/\(count)"
        case .readcompletedV2ListNext(let lastId, let count, _):
            return "/jaxrs/readcompleted/v2/list/\(lastId)/next/\(count)"
        case .taskcompletedGetReference(let id):
            return "/jaxrs/taskcompleted/\(id)/reference"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .startProcess(_, _, _), .applicationItemWithFilter(_), .attachmentUpload(_, _, _, _), .attachmentReplace(_, _, _, _, _),
             .taskV2ListNext(_, _, _), .taskcompletedV2ListNext(_, _, _), .readV2ListNext(_, _, _), .readcompletedV2ListNext(_, _, _), .taskcompletedListNext(_,_,_):
            return .post
        case .workDelete(_):
            return .delete
        case .dataUpdateWithWork(_, _):
            return .put
        default:
            return .get
        }
    }
    
    var sampleData: Data {
        return  "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .startProcess(_, let identity, let title):
            return .requestParameters(parameters: ["identity": identity, "title": title], encoding: JSONEncoding.default)
        case .applicationItemWithFilter(_):
            let filter = O2ProcessFilter()
            filter.startableTerminal = "mobile" //移动端过滤 仅pc的流程不出现在这里
            return .requestParameters(parameters: filter.toJSON()!, encoding: JSONEncoding.default)
        case .dataUpdateWithWork(_, let data):
            return .requestParameters(parameters: data, encoding: JSONEncoding.default)
        case .attachmentDownloadWithWorkCompleted(_, _, let path):
            let myDest:DownloadDestination = { temporaryURL, response in
                //本地存储
                return (path, [.removePreviousFile, .createIntermediateDirectories])
            }
            return .downloadDestination(myDest)
        case .attachmentDownloadWithWorkId(_, _, let path):
            let myDest:DownloadDestination = { temporaryURL, response in
                //本地存储
                return (path, [.removePreviousFile, .createIntermediateDirectories])
            }
            return .downloadDestination(myDest)
        case .attachmentUpload(_, let site, let fileName, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            // site 标识
            let siteData = site.data(using: .utf8)
            let siteFormData = MultipartFormData(provider: .data(siteData!), name: "site")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData, siteFormData])
        case .attachmentReplace(_, _, let site, let fileName, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            // site 标识
            let siteData = site.data(using: .utf8)
            let siteFormData = MultipartFormData(provider: .data(siteData!), name: "site")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData, siteFormData])
        case .taskV2ListNext(_, _, let key):
            return .requestParameters(parameters: ["key": key], encoding: JSONEncoding.default)
        case .taskcompletedV2ListNext(_, _, let key):
            return .requestParameters(parameters: ["key": key], encoding: JSONEncoding.default)
        case .taskcompletedListNext(_, _, let key):
            return .requestParameters(parameters: ["key": key], encoding: JSONEncoding.default)
        case .readV2ListNext(_, _, let key):
            return .requestParameters(parameters: ["key": key], encoding: JSONEncoding.default)
        case .readcompletedV2ListNext(_, _, let key):
            return .requestParameters(parameters: ["key": key], encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
        
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

