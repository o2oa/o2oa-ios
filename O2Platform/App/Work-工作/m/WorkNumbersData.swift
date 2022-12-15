//
//  WorkNumbersData.swift
//  O2Platform
//
//  Created by FancyLou on 2022/12/14.
//  Copyright © 2022 zoneland. All rights reserved.
//

import Foundation
import ObjectMapper

class WorkNumbersData: NSObject, NSCoding, Mappable{
    
    var task : Int?
    var taskCompleted : Int?
    var read : Int?
    var readCompleted : Int?
    var review :Int?
     
    required init?(map: Map){}
    private override init(){}

    func mapping(map: Map)
    {
        task <- map["task"]
        taskCompleted <- map["taskCompleted"]
        read <- map["read"]
        readCompleted <- map["readCompleted"]
        review <- map["review"]
    }

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
    {
        task = aDecoder.decodeObject(forKey: "task") as? Int
        taskCompleted = aDecoder.decodeObject(forKey: "taskCompleted") as? Int
        read = aDecoder.decodeObject(forKey: "read") as? Int
        readCompleted = aDecoder.decodeObject(forKey: "readCompleted") as? Int
        review = aDecoder.decodeObject(forKey: "review") as? Int
         

    }

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
    {
        if task != nil{
            aCoder.encode(task, forKey: "task")
        }
        if taskCompleted != nil{
            aCoder.encode(taskCompleted, forKey: "taskCompleted")
        }
        if read != nil{
            aCoder.encode(read, forKey: "read")
        }
        if readCompleted != nil{
            aCoder.encode(readCompleted, forKey: "readCompleted")
        }
        if review != nil{
            aCoder.encode(review, forKey: "review")
        }
        
    }
    
    
}
