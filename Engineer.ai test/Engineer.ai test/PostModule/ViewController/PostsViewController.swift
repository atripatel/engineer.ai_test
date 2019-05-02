//
//  PostsViewController.swift
//  Engineer.ai test
//
//  Created by Atri Patel on 02/05/19.
//  Copyright © 2019 MAC237. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import DZNEmptyDataSet

final class PostsViewController: UIViewController {
    
    //MARK:- outlets
    @IBOutlet private weak var tblView: UITableView!
    @IBOutlet private weak var lblActivatePostCount: UILabel!
    
    //MARK:- Variables
    private var viewModel = PostsViewModel()
    let disposeBag = DisposeBag()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        return refreshControl
    }()
    
    //MARK:- ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareBinding()
        getPosts()
    }
    
    //MARK:- View Methods
    private func prepareBinding() {
        tblView.tableFooterView = UIView()
        tblView.addSubview(refreshControl)
        viewModel.posts.asObservable().bind(to: tblView.rx.items(cellIdentifier: "PostCell", cellType: PostCell.self)) { row, element, cell in
            cell.post = element
            }.disposed(by: disposeBag)
        
        tblView.rx.itemSelected.subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            self.lblActivatePostCount.text = "Selected: \(self.viewModel.selectPost(index: indexPath.row))"
        }).disposed(by: disposeBag)
    }
    
    //MARK:- Webservice Methods
    private func getPosts() {
        viewModel.state.observeOn(MainScheduler.instance).subscribe(onNext: { state in
            switch state {
            case .loading:
                self.tblView.startLoading()
            case .finish(let finishPaging):
                if finishPaging {
                    UIView.performWithoutAnimation {
                        self.tblView.finishInfiniteScroll()
                    }
                } else {
                    self.tblView.stopLoading()
                }
            case .failure(let error):
                print(error.localizedDescription)
            case .success:
                if self.viewModel.nextPage == 1 { //Only for paging
                    self.tblView.emptyDataSetSource = self
                    self.tblView.emptyDataSetDelegate = self
                    self.tblView.reloadData()
                    self.tblView.addInfiniteScroll(handler: { tableView in
                        self.viewModel.getPosts()
                    })
                    self.refreshControl.endRefreshing()
                }
            }
        }).disposed(by: disposeBag)
        
        viewModel.getPosts()
    }
    
    //MARK:- Action Methods
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.viewModel.resetPaging()
        lblActivatePostCount.text = "Selected: 0"
    }
}

extension PostsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let emptyMsg = "No data found"
        let myAttribute = [NSAttributedString.Key.foregroundColor: UIColor.gray, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0)]
        let myAttrString = NSAttributedString(string: emptyMsg, attributes: myAttribute)
        return myAttrString
    }
}
