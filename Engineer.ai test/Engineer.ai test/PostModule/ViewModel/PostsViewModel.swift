//
//  PostsViewModel.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class PostsViewModel {
    
    let disposeBag = DisposeBag()
    
    var posts = BehaviorRelay<[Post]>(value: [])
    
    // State
    var state = PublishSubject<ViewModelState<PostsViewModel>>()
    
    var nextPage: Int = 1
}

extension PostsViewModel {
    
    func selectPost(index: Int) -> Int {
        var postsTemp = self.posts.value
        postsTemp[index].isActivated = !postsTemp[index].isActivated
        self.posts.accept(postsTemp)
        return postsTemp.filter { $0.isActivated }.count
    }
    
    func resetPaging() {
        nextPage = 1
        getPosts(isPullToRefresh: true)
    }
    
    func getPosts(isPullToRefresh: Bool = false) {
        if nextPage == 1 {
            if isPullToRefresh == false {
                state.onNext(.loading)
            }
            
            PostsViewInteractor.getPosts(page: nextPage).subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                if let posts = response.data as? [Post] {
                    self.posts.accept(posts)
                    self.state.onNext(.success(self))
                    self.nextPage = self.nextPage + 1
                } else {
                    self.posts.accept([])
                    self.state.onNext(.failure(.noData))
                }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.posts.accept([])
                    self.state.onNext(.failure(error as! WebError))
                }, onCompleted: { [weak self] in
                    guard let `self` = self else { return }
                    self.state.onNext(.finish(false))
            }).disposed(by: disposeBag)
        } else {
            
            PostsViewInteractor.getPosts(page: nextPage).subscribe(onNext: { [weak self] response in
                guard let `self` = self else { return }
                if let posts = response.data as? [Post], posts.count > 0 {
                    self.posts.accept(self.posts.value + posts)
                    self.state.onNext(.success(self))
                    self.nextPage = self.nextPage + 1
                } else {
                    self.state.onNext(.finish(true))
                }
                }, onError: { [weak self] error in
                    guard let `self` = self else { return }
                    self.state.onNext(.failure(error as! WebError))
                }, onCompleted: { [weak self] in
                    guard let `self` = self else { return }
                    self.state.onNext(.finish(true))
            }).disposed(by: disposeBag)
        }
    }
}
