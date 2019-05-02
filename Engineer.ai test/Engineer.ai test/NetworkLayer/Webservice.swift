//
//  Webservice.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Alamofire
import Foundation
import SwiftyJSON
import RxSwift
import RxCocoa

enum WebError: Error {
    
    /// Throws when server don't give any response
    case noData
    
    /// Throws when internet isn't connected
    case noInternet
    
    /// Throws when server is down because of any reason
    case hostFail
    
    /// Throws when response is not as per predefined json format
    case parseFail
    
    /// Throws when request timeout occurs
    case timeout
    
    /// Throws when server unauthorise user
    case unAuthorise
    
    /// Throws when application cancel running request
    case cancel
    
    /// Throws when error is none of the above
    case unknown
}


final class Webservice: SessionManager {
    
    // Custom header field
    var header = [
        "Content-Type":"application/json"
    ]
    
    static let API: Webservice = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForResource = 60
        configuration.timeoutIntervalForRequest  = 60
        
        var webService = Webservice(configuration: configuration)
        //webService.startRequestsImmediately = false
        return webService
    }()
    
    /// Set Bearer Token here
    ///
    /// - parameter token: string without bearer prefix for `token`
    func set(authorizeToken token: String?) {
        header[""] = token!
    }
    
    /// Remove Bearer token with this method
    func removeAuthorizeToken() {
        header.removeValue(forKey: "")
    }
    
    func cancelAllTasks() {
        
        self.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            dataTasks.forEach { $0.cancel() }
            uploadTasks.forEach { $0.cancel() }
            downloadTasks.forEach { $0.cancel() }
        }
    }
    
    @discardableResult
    func sendRequest(_ route: Router) -> Observable<TTResponse> {
        
        return Observable<TTResponse>.create { observer -> Disposable in
            
            guard AppDelegate.isReachable == true else {
                observer.onError(WebError.noInternet)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let path = route.path.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
            
            var parameter = route.parameters
            if route.parameters == nil {
                parameter = [:]
            }
            
            var encoding: ParameterEncoding = JSONEncoding.default
            if route.method == .get {
                encoding = URLEncoding.default
            }
            
            let request = self.request(path!, method: route.method, parameters: parameter!, encoding: encoding, headers: self.header)
            
            request.responseJSON { response in
                
                switch response.result {
                case .success:
                    if let _ = response.result.value {
                        
                        let jsonResult: JSON = JSON(response.result.value!)
                        
                        guard jsonResult.type != .null else {
                            observer.onError(WebError.parseFail)
                            observer.onCompleted()
                            return
                        }
                        
                        let resp = TTResponse(parameter: jsonResult, dataKey: route.dataKey, type: route.type)
                        observer.onNext(resp)
                        
                    } else {
                        observer.onError(WebError.noData)
                    }
                    
                case .failure(let error):
                    print("Error: \(error)")
                    if error._code == NSURLErrorTimedOut {//
                        observer.onError(WebError.timeout)
                    } else if error._code == NSURLErrorCannotConnectToHost {
                        observer.onError(WebError.hostFail)
                    } else if error._code == NSURLErrorCancelled {
                        observer.onError(WebError.cancel)
                    } else if error._code == NSURLErrorNetworkConnectionLost {
                        if AppDelegate.isReachable == true {
                            //Slow Internet connection
                        } else {
                            //Internet disconnected before completion of request
                        }
                        observer.onError(WebError.unknown)
                    } else {//
                        observer.onError(WebError.unknown)
                    }
                }
                
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
