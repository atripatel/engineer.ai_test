//
//  TTResponse.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    
    func to<T>(type: T?) -> Any? {
        if let baseObj = type as? JSONable.Type {
            guard self.type != .null, self.type != .unknown else {
                return nil
            }
            
            if self.type == .array {
                var arrObject: [Any] = []
                arrObject = self.arrayValue.map { baseObj.init(parameter: $0)! }
                return arrObject
            } else {
                let object = baseObj.init(parameter: self)!
                return object
            }
        }
        return nil
    }
}

struct TTResponse {
    var status      : Bool!
    var data        : Any!
    
    init() {
        status     = false
        data       = nil
    }
    
    init<T>(parameter: JSON, dataKey: String?, type: T? = nil) {
        status     = true
        if let t = type, let key = dataKey, let d = parameter[key].to(type: t) {
            data = d
        } else {
            data = parameter
        }
    }
    
    static var noInternetResponse: TTResponse {
        var response        = TTResponse()
        response.status     = false
        response.data       = nil
        return response
    }
}
