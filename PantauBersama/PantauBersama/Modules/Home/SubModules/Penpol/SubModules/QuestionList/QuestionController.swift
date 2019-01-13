//
//  AskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common

class QuestionController: UITableViewController, IQuestionListViewController {
    
    private var headerView: HeaderAskView!
    private var emptyView = EmptyView()
    var viewModel: IQuestionListViewModel!
    internal let disposeBag = DisposeBag()
    var pageType: QuestionPageType!
    
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: IQuestionListViewModel, pageType: QuestionPageType) {
        self.init()
        self.viewModel = viewModel
        self.pageType = pageType
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AskViewCell.self)
//<<<<<<< HEAD
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 44
//        tableView.separatorStyle = .singleLine
//        tableView.separatorColor = UIColor.groupTableViewBackground
//        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.tableFooterView = UIView()
//        
//        viewModel.output.showHeader
//            .drive(onNext: { [unowned self]isHeaderShown in
//                if isHeaderShown {
//                    self.tableView.tableHeaderView = HeaderAskView(viewModel: self.viewModel)
//                }
//            })
//            .disposed(by: disposeBag)
//        
//        bindViewModel()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        viewModel.input.loadQuestionTrigger
//            .onNext(())
//        
//=======
//>>>>>>> [Bhakti][Refactor] Refactor tanya kandidat
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.tableFooterView = UIView()
        tableView.refreshControl = rControl
        
        bind(tableView: tableView, refreshControl: rControl, emptyView: emptyView, with: viewModel)
        
        if let page = self.pageType {
            switch page{
            case .allQuestion:
                headerView = HeaderAskView(viewModel: viewModel)
                tableView.tableHeaderView = headerView
            default:
                tableView.tableHeaderView = nil
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

}
