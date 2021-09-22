//
//  O2MeetingAPI.swift
//  o2app
//
//  Created by 刘振兴 on 2018/1/16.
//  Copyright © 2018年 zone. All rights reserved.
//

import Foundation
import Moya


// MARK:- 所有调用的API枚举
enum O2MeetingAPI {
    //会议地点
    case buildByCreate
    case buildSearchByPingYin(String)
    case buildListByAll
    case buildListBySearchKey(String)
    case buildListByPinYinInitialSearch(String)
    case buildListByStartAndCompletedDate(String,String)
    case buildItemById(String)
    
    //会议房间
    case roomByCreate
    case roomSearchByPinYin(String)
    case roomListByAll
    case roomListBySearchKey(String)
    case roomListByPinYinInitialSearch(String)
    case roomItemById(String)
    
    //会议按年月列表
    case meetingListByYearMonth(String,String)
    case meetingListByYearMonthDay(String,String,String)
    case meetingListByAccept
    case meetingListByApplied
    case meetingListForDayCount(String)
    
    case meetingItemById(String)
    case meetingItemAcceptById(String)
    case meetingItemAddInvitedById(String)
    case meetingItemConfirmAllowById(String)
    case meetingItemConfirmDenyById(String)
    case meetingItemCompletedById(String)
    case meetingItemRejectById(String)
    
    case meetingItemByCreate(OOMeetingFormBean)
    case meetingCreate(OOMeetingInfo)
    case meetingItemUpdate(OOMeetingInfo)
    case meetingItemDelete(String)
    case meetingUploadFile(String, String, Data)
    case meetingAttachmentList(String)
    case meetingAttachmentDelete(String)
    case meetingAttachmentDownload(OOMeetingAttachmentList)
    
    
    
    
    
}

// MARK:- 上下文实现
extension O2MeetingAPI:OOAPIContextCapable {
    var apiContextKey: String {
        return "x_meeting_assemble_control"
    }
}


// MARK: - 是否需要加入x-token访问头
extension O2MeetingAPI:OOAccessTokenAuthorizable {
    public var shouldAuthorize: Bool {
        return true
    }
}

extension O2MeetingAPI:TargetType{
    var baseURL: URL {
        let model = O2AuthSDK.shared.o2APIServer(context: .x_meeting_assemble_control)
        let baseURLString = "\(model?.httpProtocol ?? "http")://\(model?.host ?? ""):\(model?.port ?? 80)\(model?.context ?? "")"
        if let trueUrl = O2AuthSDK.shared.bindUnitTransferUrl2Mapping(url: baseURLString) {
            return URL(string: trueUrl)!
        }
        return URL(string: baseURLString)!
    }
    
    var path: String {
        switch self {
        //会议地点
        case .buildByCreate:
            return "/jaxrs/building"
        case .buildSearchByPingYin(let pinyin):
            return "/jaxrs/building/list/like/pinyin/\(pinyin.urlEscaped)"
        case .buildListByAll:
            return "/jaxrs/building/list"
        case .buildListBySearchKey(let searchKey):
            return "/jaxrs/building/list/like/\(searchKey.urlEscaped)"
        case .buildListByPinYinInitialSearch(let pinyininitial):
            return "/jaxrs/building/list/pinyininitial/\(pinyininitial.urlEscaped)"
        case .buildListByStartAndCompletedDate(let start,let completed):
            return "/jaxrs/building/list/start/\(start)/completed/\(completed)"
        case .buildItemById(let id):
            return "/jaxrs/building/\(id)"
            
        //会议房间
        case .roomByCreate:
            return "/jaxrs/room"
        case .roomSearchByPinYin(let pinyin):
            return "/jaxrs/room/list/like/pinyin/\(pinyin)"
        case .roomListByAll:
            return "/jaxrs/room/list"
        case .roomListBySearchKey(let searchkey):
            return "/jaxrs/room/list/like/\(searchkey)"
        case .roomListByPinYinInitialSearch(let pinyininitial):
            return "/jaxrs/room/list/pinyininitial/\(pinyininitial)"
        case .roomItemById(let id):
            return "/jaxrs/room/\(id)"
            
        //会议按年月列表
        case .meetingListByYearMonth(let year,let month):
            return "/jaxrs/meeting/list/year/\(year)/month/\(month)"
        case .meetingListByYearMonthDay(let year,let month,let day):
            return "/jaxrs/meeting/list/year/\(year)/month/\(month)/day/\(day)"
        case .meetingListByAccept:
            return "/jaxrs/meeting/list/wait/accept"
        case .meetingListByApplied:
            return "/jaxrs/meeting/list/applied/wait"
        case .meetingListForDayCount(let day):
            return "/jaxrs/meeting/list/coming/day/\(day)"
            
        case .meetingItemById(let id):
            return "/jaxrs/meeting/\(id)"
        case .meetingItemAcceptById(let id):
            return "/jaxrs/meeting/\(id)/accept"
        case .meetingItemAddInvitedById(let id):
            return "/jaxrs/meeting/\(id)/add/invite"
        case .meetingItemConfirmAllowById(let id):
            return "/jaxrs/meeting/\(id)/confirm/allow"
        case .meetingItemConfirmDenyById(let id):
            return "/jaxrs/meeting/\(id)/confirm/deny"
        case .meetingItemCompletedById(let id):
            return "/jaxrs/meeting/\(id)/manual/completed"
        case .meetingItemRejectById(let id):
            return "/jaxrs/meeting/\(id)/reject"
        case .meetingItemByCreate(_), .meetingCreate(_):
            return "/jaxrs/meeting"
        case .meetingItemUpdate(let form):
            return "/jaxrs/meeting/\(form.id!)"
        case .meetingItemDelete(let id):
            return "/jaxrs/meeting/\(id)"
        case .meetingUploadFile(let meetingId, _, _):
            return "/jaxrs/attachment/meeting/\(meetingId)/upload/false"
        case .meetingAttachmentList(let meetingId):
            return "/jaxrs/attachment/list/meeting/\(meetingId)"
        case .meetingAttachmentDelete(let id):
            return "/jaxrs/attachment/\(id)"
        case .meetingAttachmentDownload(let atta):
            return "/jaxrs/attachment/\(atta.id!)/download/false"
        }
            
    }
    
    var method: Moya.Method {
        switch self {
        //会议地点
        case .buildByCreate:
            return .put
        case .buildSearchByPingYin(_):
            return .get
        case .buildListByAll:
            return .get
        case .buildListBySearchKey(_):
            return .get
        case .buildListByPinYinInitialSearch(_):
            return .get
        case .buildListByStartAndCompletedDate(_,_):
            return .get
        case .buildItemById(_):
            return .get
            
        //会议房间
        case .roomByCreate:
            return .put
        case .roomSearchByPinYin(_):
            return .get
        case .roomListByAll:
            return .get
        case .roomListBySearchKey(_):
            return .get
        case .roomListByPinYinInitialSearch(_):
            return .get
        case .roomItemById(_):
            return .get
            
        //会议按年月列表
        case .meetingListByYearMonth(_,_):
            return .get
        case .meetingListByYearMonthDay(_,_,_):
            return .get
        case .meetingListByAccept:
            return .get
        case .meetingListByApplied:
            return .get
        case .meetingListForDayCount(_):
            return .get
            
        case .meetingItemById(_):
            return .get
        case .meetingItemAcceptById(_):
            return .get
        case .meetingItemAddInvitedById(_):
            return .get
        case .meetingItemConfirmAllowById(_):
            return .get
        case .meetingItemConfirmDenyById(_):
            return .get
        case .meetingItemCompletedById(_):
            return .get
        case .meetingItemRejectById(_):
            return .get
        case .meetingItemByCreate(_), .meetingCreate(_):
            return .post
        case .meetingItemUpdate(_):
            return .put
        case .meetingItemDelete(_):
            return .delete
        case .meetingUploadFile(_, _, _):
            return .post
        case .meetingAttachmentList(_):
            return .get
        case .meetingAttachmentDelete(_):
            return .delete
        case .meetingAttachmentDownload(_):
            return .get
        }
    }
    
    var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case .meetingItemByCreate(let mBean):
            return .requestParameters(parameters: mBean.toJSON()!, encoding: JSONEncoding.default)
        case .meetingCreate(let mBean):
            return .requestParameters(parameters: mBean.toJSON()!, encoding: JSONEncoding.default)
        case .meetingItemUpdate(let meeting):
            return .requestParameters(parameters: meeting.toJSON()!, encoding: JSONEncoding.default)
        case .meetingUploadFile(_, let fileName, let data):
            //字符串类型 文件名
            let strData = fileName.data(using: .utf8)
            let fileNameData = MultipartFormData(provider: .data(strData!), name: "fileName")
            //文件类型
            let fileData = MultipartFormData(provider: .data(data), name: "file", fileName: fileName)
            return .uploadMultipart([fileData, fileNameData])
        case .meetingAttachmentDownload(let atta):
            let myDest:DownloadDestination = { temporaryURL, response in
                let fileName = "\(atta.name ?? "untitle").\(atta.extension ?? "png")"
                let fileURL = O2.meetingFileLocalFolder().appendingPathComponent(fileName)
                return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
            }
            return .downloadDestination(myDest)
        default:
            return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        return nil
    }
    
    
}

