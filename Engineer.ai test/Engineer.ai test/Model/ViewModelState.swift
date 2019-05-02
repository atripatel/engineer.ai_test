//
//  ViewModelState.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation

enum ViewModelState<T> {
    case loading
    case failure(WebError)
    case finish(Bool)
    case success(T)
}
