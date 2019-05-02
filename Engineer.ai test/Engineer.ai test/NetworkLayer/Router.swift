//
//  Router.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON

protocol JSONable {
    init?(parameter: JSON)
}

protocol Routable {
    var path        : String { get }
    var method      : HTTPMethod { get }
    var parameters  : Parameters? { get }
    var type        : JSONable.Type? { get }
    var dataKey     : String? { get }
}


enum Router: Routable, Equatable {
    
    case posts(Int)
    
    static func ==(lhs: Router, rhs: Router) -> Bool {
        return lhs.path == rhs.path
    }
}

extension Router {
    var path: String {
        var endPoint = ""
        
        switch self {
        case .posts:
            endPoint = "search_by_date"
        }
        return "https://hn.algolia.com/api/v1/" + endPoint
    }
    
}

extension Router {
    var method: HTTPMethod {
        return .get
    }
}

extension Router {
    var parameters: Parameters? {
        switch self {
        case .posts(let page):
            return ["tags" : "story", "page" : page]
        }
    }
}

extension Router {
    var type: JSONable.Type? {
        switch self {
        case .posts:
            return Post.self
        }
    }
}

extension Router {
    var dataKey: String? {
        switch self {
        case .posts:
            return "hits"
        }
    }
}
