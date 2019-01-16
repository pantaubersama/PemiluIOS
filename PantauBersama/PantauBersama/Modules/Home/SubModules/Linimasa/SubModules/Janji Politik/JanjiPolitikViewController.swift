//
//  JanjiPolitikViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import Networking

class JanjiPolitikViewController: UITableViewController,IJanpolViewController {
    
    private var headerView: BannerHeaderView!
    internal let disposeBag = DisposeBag()
    private var emptyView = EmptyView()
    
    var viewModel: IJanpolListViewModel!
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: IJanpolListViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaJanjiCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  
        
        tableView.tableFooterView = UIView()
        tableView.refreshControl = rControl
        
        bind(tableView: tableView, refreshControl: rControl, emptyView: emptyView, with: viewModel)
        
        viewModel.output.showHeaderO
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = BannerHeaderView()
                    self.tableView.tableHeaderView = self.headerView
                    self.bind(headerView: self.headerView, with: self.viewModel)
                }
            }).disposed(by: disposeBag)
        
        viewModel.input.refreshI.onNext("")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
}

