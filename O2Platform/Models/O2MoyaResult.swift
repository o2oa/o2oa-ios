//
//  O2MoyaResult.swift
//  O2OA_SDK_Framwork
//
//  Created by FancyLou on 2018/11/8.
//

import Foundation
import Moya

public enum O2APIError: Error {
    case o2ResponseError(String)
    case jsonTransformError(String)
    case moyaResponseError(Error)
    case unknownError(Error)
}


public final class O2MoyaResult<T: IBaseO2ResponseData> {

    var model: T?
    var error: O2APIError?
    
    init(_ result:Result<Response,MoyaError>) {
        switch result {
        case .success(let data):
            model = data.mapObject(T.self)
            if let _ = model  {
                if model?.isSuccess() == false {
                    self.error = O2APIError.o2ResponseError(model?.message ?? "")
                }
            }else {
                self.error = O2APIError.jsonTransformError("response:\(data.description)")
            }
            break
        case .failure(let err):
            self.error = O2APIError.moyaResponseError(err)
            break
        }
    }
    
    func isResultSuccess() -> Bool {
        guard let _ = error else {
            return true
        }
        return false
    }
}


