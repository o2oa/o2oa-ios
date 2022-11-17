//
//  O2MindMapViewModel.swift
//  O2Platform
//
//  Created by FancyLou on 2021/12/16.
//  Copyright © 2021 zoneland. All rights reserved.
//

import UIKit
import Promises
import Charts


class O2MindMapViewModel  {
    
    private let mindMapAPI = OOMoyaProvider<MindMapAPI>()
    private let cloudAPI = OOMoyaProvider<OOCloudStorageAPI>()
    
    
    // 创建脑图
    func createMindMap(name: String, folderId: String)-> Promise<String> {
        return Promise { fulfill, reject in
            let root = MindRootNode()
            root.template = "default"
            root.theme = "fresh-blue"
            root.version = "1"
            let node = MindNode()
            let data = MindNodeData()
            data.id = "root"
            data.text = name
            node.data = data
            node.children = []
            root.root = node
            
            let body = MindMapItem()
            body.name = name
            body.folderId = folderId
            body.content = root.toJSONString()
            body.fileVersion = 1
            
            self.mindMapAPI.request(.saveMindMap(body)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    // 创建目录
    func createFolder(name: String, parentId: String)-> Promise<String> {
        return Promise { fulfill, reject in
            let folder = MindFolder()
            folder.name = name
            folder.parentId = parentId
            self.mindMapAPI.request(.createFolder(folder)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    // 重命名目录
    func renameFolder(name: String, folder: MindFolder)-> Promise<String> {
        return Promise { fulfill, reject in
            folder.name = name
            self.mindMapAPI.request(.createFolder(folder)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    // 删除目录
    func deleteFolder(id: String) -> Promise<String> {
        return Promise { fulfill, reject in
            self.mindMapAPI.request(.deleteFolder(id)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 保存脑图
    func saveMindMap(mind: MindMapItem)-> Promise<String> {
        return Promise { fulfill, reject in
            self.mindMapAPI.request(.saveMindMap(mind)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    // 重命名脑图
    func renameMindMap(name: String, mind: MindMapItem)-> Promise<String> {
        return Promise { fulfill, reject in
            mind.name = name
            self.mindMapAPI.request(.saveMindMap(mind)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 删除脑图
    func deleteMindMap(id: String) -> Promise<String> {
        return Promise { fulfill, reject in
            self.mindMapAPI.request(.deleteMindMap(id)) { result in
                let response = OOResult<BaseModelClass<O2IdDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 上传缩略图
    func saveMindMapThumb(image: UIImage, id: String)-> Promise<String> {
        return Promise { fulfill, reject in
            if let pData = image.pngData() {
                self.cloudAPI.request(.uploadImageWithReferencetype("mind_\(id).png", "mindInfo", id, 200, pData)) { result in
                    let response = OOResult<BaseModelClass<O2UPloadImageIdsDataModel>>(result)
                    if response.isResultSuccess() {
                        if let id = response.model?.data?.id {
                            fulfill(id)
                        } else {
                            reject(OOAppError.apiEmptyResultError)
                        }
                    } else {
                        reject(response.error!)
                    }
                }
            } else {
                reject(O2APIError.o2ResponseError("图片为空！"))
            }
        }
    }
    // 节点图片上传
    func saveMindMapNodeImage(filename:String, data: Data, id:String)-> Promise<String> {
        return Promise { fulfill, reject in
            self.cloudAPI.request(.uploadImageWithReferencetype(filename, "mindInfo", id, 400, data)) { result in
                let response = OOResult<BaseModelClass<O2UPloadImageIdsDataModel>>(result)
                if response.isResultSuccess() {
                    if let id = response.model?.data?.id {
                        fulfill(id)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    // 分页查询目录下的脑图列表
    func listMindMapFilter(nextId: String, folderId: String)-> Promise<[MindMapItem]> {
        let filter = MindMapFilter()
        filter.folderId = folderId
        return Promise { fulfill, reject in
            self.mindMapAPI.request(.listNextWithFilter(nextId, filter)) { result in
                let response = OOResult<BaseModelClass<[MindMapItem]>>(result)
                if response.isResultSuccess() {
                    if let list = response.model?.data {
                        fulfill(list)
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    ///
    ///  根据id查询脑图对象
    func loadMindMapView(id: String)-> Promise<(MindMapItem, MindRootNode?)> {
        return Promise {fulfill, reject in
            self.mindMapAPI.request(.viewMindWithId(id)) { result in
                let response = OOResult<BaseModelClass<MindMapItem>>(result)
                if response.isResultSuccess() {
                    if let item = response.model?.data {
                        // 脑图json转对象
                        if let content = item.content, let node = MindRootNode.deserialize(from: content) {
                            // 特殊处理 根节点的data id设置为root 后面好判断
                            if node.root?.data?.id == nil || node.root?.data?.id == "" {
                                node.root?.data?.id = "root"
                            }
                            fulfill((item, node))
                        } else {
                            fulfill((item, nil))
                        }
                    } else {
                        reject(OOAppError.apiEmptyResultError)
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    
    //查询 目录 list
    func myFolderTree()-> Promise<[MindFolder]> {
        return Promise { fulfill, reject in
            self.mindMapAPI.request(.myFolderTree) { result in
                let response = OOResult<BaseModelClass<[MindFolder]>>(result)
                if response.isResultSuccess() {
                    if let info = response.model?.data {
                        // 把树状结构转化成List 并添加root节点
                        var newList:[MindFolder] = []
                        let root = MindFolder()
                        root.id = o2MindMapDefaultFolderRootId
                        root.name = o2MindMapDefaultFolderRoot
                        root.level = 1
                        newList.append(root)
                        let all = self.deconstructionTree(children: info, parentLevel: 1)
                        for item in all {
                            newList.append(item)
                        }
                        fulfill(newList)
                    } else {
                        fulfill([])
                    }
                } else {
                    reject(response.error!)
                }
            }
        }
    }
    
    private func deconstructionTree(children: [MindFolder], parentLevel: Int)-> [MindFolder] {
        var newChildrenList:[MindFolder] = []
        let newLevel = parentLevel + 1
        for item in children {
            item.level = newLevel
            if item.children != nil && item.children!.count > 0 {
                let newItemChildList = self.deconstructionTree(children: item.children!, parentLevel: newLevel)
                for child in newItemChildList {
                    newChildrenList.append(child)
                }
            }
            newChildrenList.append(item)
        }
        return newChildrenList
    }
    
}
