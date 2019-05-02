//
//  Post.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Post: JSONable, Equatable {
    
    let id          : String!
    let title       : String!
    let createdAt   : String!
    var isActivated : Bool = false
    
    init?(parameter: JSON) {
        id         = parameter["objectID"].stringValue
        title      = parameter["title"].stringValue
        createdAt  = parameter["created_at"].stringValue
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}
