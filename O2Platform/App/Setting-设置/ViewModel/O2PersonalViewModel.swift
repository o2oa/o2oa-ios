//
//  O2PersonalViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2018/11/21.
//  Copyright © 2018 zoneland. All rights reserved.
//

import CocoaLumberjack
import Promises

class O2PersonalViewModel {
    
    private let personalAPI = OOMoyaProvider<PersonalAPI>()
    
    
    
    ///
    /// 获取个人信息
    ///
    func loadMyInfo() -> Promise<O2PersonInfo> {
        return Promise<O2PersonInfo> { fulfill,reject in
            self.personalAPI.request(.personInfo, completion: { (result) in
                let response = OOResult<BaseModelClass<O2PersonInfo>>(result)
                if response.isResultSuccess() {
                    if let person = response.model?.data {
                        fulfill(person)
                    }else {
                        reject(OOAppError.apiResponseError("没有获取到用户信息！"))
                    }
                }else {
                    reject(response.error!)
                }
            })
        }
    }
    
    /// 更新个人信息
    ///
    /// - Parameter person: 个人信息O2PersonInfo
    /// - Returns: Bool
    func updateMyInfo(person: O2PersonInfo) -> Promise<Bool> {
        return Promise<Bool> { fulfill,reject in
            self.personalAPI.request(.updatePersonInfo(person), completion: { (result) in
                let response = OOResult<BaseModelClass<OOCommonIdModel>>(result)
                if response.isResultSuccess() {
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            })
        }
    }
    
    /// 更新用户头像
    ///
    /// - Parameter icon: 用户头像
    /// - Returns: Bool
    func updateMyIcon(icon: UIImage) -> Promise<Bool>  {
        return Promise<Bool> { fulfill,reject in
            self.personalAPI.request(.updatePersonIcon(icon), completion: { (result) in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
                
            })
        }
    }
    
    ///
    /// 我的委托
    ///
    func empowerList() -> Promise<[EmpowerData]> {
        return Promise<[EmpowerData]> { fulfill, reject in
            self.personalAPI.request(.empowerList) { result in
                let response = OOResult<BaseModelClass<[EmpowerData]>>(result)
                if response.isResultSuccess() {
                    let list = response.model?.data ?? []
                    fulfill(list)
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    ///
    /// 收到的委托
    /// 
    func empowerListTo() -> Promise<[EmpowerData]> {
        return Promise<[EmpowerData]> { fulfill, reject in
            self.personalAPI.request(.empowerListTo) { result in
                let response = OOResult<BaseModelClass<[EmpowerData]>>(result)
                if response.isResultSuccess() {
                    let list = response.model?.data ?? []
                    fulfill(list)
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    ///
    /// 创建授权
    ///
    func empowerCreate(body: EmpowerData) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            self.personalAPI.request(.empowerCreate(body)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    ///
    /// 删除授权
    func empowerDelete(id: String) -> Promise<Bool> {
        return Promise<Bool> { fulfill, reject in
            self.personalAPI.request(.empowerDelete(id)) { result in
                let response = OOResult<BaseModelClass<OOCommonValueBoolModel>>(result)
                if response.isResultSuccess() {
                    fulfill(true)
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
    func newMyInfo() -> Promise<O2PersonInfo> {
        return Promise<O2PersonInfo> { fulfill, reject in
            self.personalAPI.request(.personInfo) { result in
                let response = OOResult<BaseModelClass<O2PersonInfo>>(result)
                if response.isResultSuccess() {
                    if let person = response.model?.data {
                        fulfill(person)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                     
                }else {
                    reject(response.error!)
                }
            }
        }
    }
    
}
