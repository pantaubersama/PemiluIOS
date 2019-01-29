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
    
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: IQuestionListViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(AskViewCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        tableView.tableFooterView = UIView()
        tableView.refreshControl = rControl
        
        bind(tableView: tableView, refreshControl: rControl, emptyView: emptyView, with: viewModel)
        
        viewModel.output.showHeaderO
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = HeaderAskView(viewModel: self.viewModel)
                    self.tableView.tableHeaderView = self.headerView
                }
            }).disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

}
