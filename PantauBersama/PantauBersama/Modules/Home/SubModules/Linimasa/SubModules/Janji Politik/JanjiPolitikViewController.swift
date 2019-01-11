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
    var pageType: JanpolPageType!
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: IJanpolListViewModel, pageType: JanpolPageType) {
        self.init()
        self.viewModel = viewModel
        self.pageType  = pageType
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
        
        if let page = self.pageType {
            switch page{
            case .allJanpol:
                headerView = BannerHeaderView()
                tableView.tableHeaderView = headerView
                bind(headerView: headerView, with: viewModel)
            default:
                tableView.tableHeaderView = nil
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
}

