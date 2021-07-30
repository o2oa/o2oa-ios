//
//  SampleEditionManger.swift
//  O2Platform
//  演示版本 管理器
//  Created by FancyLou on 2021/7/30.
//  Copyright © 2021 zoneland. All rights reserved.
//

import CocoaLumberjack


class SampleEditionManger {
    static let shared: SampleEditionManger = {
        return SampleEditionManger()
    }()
    
    private init(){
        initConfig()
    }
    
    
    var unitList: [O2BindUnitModel] = []
    private var currentUnit: O2BindUnitModel? = nil
    
    func initConfig() {
        readUnitListFromInfoplist()
        currentUnit = readCurrentServer()
    }
    
    /// 切换环境 需要重启应用
    func setCurrent(unit: O2BindUnitModel) {
        currentUnit = unit
        O2UserDefaults.shared.sampleUnit = unit
    }
    /// 获取当前环境
    func getCurrentUnit() -> O2BindUnitModel {
        if let unit = currentUnit {
            return unit
        }
        let unit = O2BindUnitModel()
        unit.id = "sample"
        unit.centerContext = "/x_program_center"
        unit.centerHost = "sample.o2oa.net"
        unit.centerPort = 40030
        unit.httpProtocol = "https"
        unit.name = "演示环境"
        return unit
    }
     
    /// 读取Info.plist 文件中 o2SampleServerList 数据
    private func readUnitListFromInfoplist() {
        if let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"), let dic = NSDictionary(contentsOfFile: infoPath) {
            if let list = dic["o2SampleServerList"] as? NSArray {
                for item in list {
                    if let o2Server = item as? NSDictionary {
                        let id = o2Server["id"] as? String
                        let name = o2Server["name"] as? String
                        let centerHost = o2Server["centerHost"] as? String
                        let centerContext = o2Server["centerContext"] as? String
                        let centerPort = o2Server["centerPort"] as? Int
                        let httpProtocol = o2Server["httpProtocol"] as? String
                        let unit = O2BindUnitModel()
                        unit.id = id
                        unit.centerContext = centerContext
                        unit.centerHost = centerHost
                        unit.centerPort = centerPort
                        unit.httpProtocol = httpProtocol
                        unit.name = name
                        DDLogDebug("unit : \(unit.description)")
                        unitList.append(unit)
                    }
                }
            }
        }
    }
    /// 读取当前绑定的演示服务器
    private func readCurrentServer() -> O2BindUnitModel {
        if let unit = O2UserDefaults.shared.sampleUnit  {
            return unit
        } else {
            let unit = unitList[0]
            O2UserDefaults.shared.sampleUnit = unit
            return unit
        }
    }
    
}
