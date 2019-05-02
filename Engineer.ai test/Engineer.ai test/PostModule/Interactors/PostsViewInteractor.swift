//
//  PostsViewInteractor.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct PostsViewInteractor {
    
    //MARK:- Webservice Methods
    static func getPosts(page: Int) -> Observable<TTResponse> {
        return Webservice.API.sendRequest(.posts(page))
    }
}
