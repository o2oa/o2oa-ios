//
//  O2SearchViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2021/5/25.
//  Copyright © 2021 zoneland. All rights reserved.
//

import Promises


class O2SearchViewModel: NSObject {
    override init() {
        super.init()
    }
    

    private let api = OOMoyaProvider<O2QuerySurfaceAPI>()
    // 流程api
    private let o2ProcessAPI = OOMoyaProvider<OOApplicationAPI>()
    
    
    private var searchResultIds:[String] = []
    private var idsTotalNumber = 0
    private var page = 1
    private var totalPage = 1
    
    
    func searchV2(key: String, page: Int) -> Promise<O2SearchV2PageModel?> {
        return Promise { fulfill, reject in
            let form = O2SearchV2Form()
            form.page = page
            form.query = key
            self.api.request(.search(form)) { result in
                let response = OOResult<BaseModelClass<O2SearchV2PageModel>>(result)
                if response.isResultSuccess() {
                    fulfill(response.model?.data)
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    /// 根据job查询工作列表
    func loadWorkByJob(jobId: String) -> Promise<WorkOrWorkcompleted> {
        return Promise { fulfill, reject in
            self.o2ProcessAPI.request(.workOrWorkcompletedByJob(jobId)) { result in
                let myResult = OOResult<BaseModelClass<WorkOrWorkcompleted>>(result)
                if myResult.isResultSuccess() {
                     if let item = myResult.model?.data {
                         fulfill(item)
                     } else {
                         reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                     reject(myResult.error!)
                }
            }
        }
    }
    
    func search(key: String) -> Promise<O2SearchPageModel> {
        return Promise {fulfill, reject in
            self.api.request(.segmentSearch(key), completion: { result in
                let response = OOResult<BaseModelClass<O2SearchIdsEntry>>(result)
                if response.isResultSuccess() {
                    if let data = response.model?.data {
                        self.searchResultIds = data.valueList
                        self.idsTotalNumber = data.count
                        if self.searchResultIds.count > O2.defaultPageSize {
                            let m = self.searchResultIds.count % O2.defaultPageSize
                            if m > 0 {
                                self.totalPage = (self.searchResultIds.count / O2.defaultPageSize) + 1
                            } else {
                                self.totalPage = (self.searchResultIds.count / O2.defaultPageSize)
                            }
                        } else {
                            self.totalPage = 1
                        }
                        self.page = 1
                        self.loadListEntry().then { (list)  in
                            var model = O2SearchPageModel()
                            model.page = self.page
                            model.totalPage = self.totalPage
                            model.list = list
                            fulfill(model)
                        }.catch { (err) in
                            reject(err)
                        }
                    } else {
                        reject(OOAppError.jsonMapping(message: "返回数据为空！！", statusCode: 1024, data: nil))
                    }
                } else {
                    reject(response.error!)
                }
                
            })
        }
    }
    
    /// 下一页
    func nextPage() -> Promise<O2SearchPageModel> {
        return Promise { fulfill, reject in
            if self.page < self.totalPage {
                self.page += 1
                self.loadListEntry().then { (list)  in
                    var model = O2SearchPageModel()
                    model.page = self.page
                    model.totalPage = self.totalPage
                    model.list = list
                    fulfill(model)
                }.catch { (err) in
                    reject(err)
                }
            } else {
                reject(OOAppError.apiEmptyResultError)
            }
        }
    }
    
    /// 根据ids 查询结果集
    private func loadListEntry() -> Promise<[O2SearchEntry]> {
        return Promise{ fulfill, reject in
            if self.searchResultIds.count == 0 {
                fulfill([])
            } else {
                let start = (self.page - 1) * O2.defaultPageSize
                var end = start + O2.defaultPageSize
                if end > self.searchResultIds.count {
                    end = self.searchResultIds.count
                }
                let subList = self.searchResultIds[start..<end]
                let a = subList.map { (s) -> String in
                    return s
                }
                self.api.request(.segmentListEntry(a), completion: {result in
                    let response = OOResult<BaseModelClass<[O2SearchEntry]>>(result)
                    if response.isResultSuccess() {
                        if let list = response.model?.data {
                            fulfill(list)
                        }else {
                            reject(OOAppError.jsonMapping(message: "返回数据为空！！", statusCode: 1024, data: nil))
                        }
                    } else {
                        reject(response.error!)
                    }
                })
            }
        }
    }
    
}
