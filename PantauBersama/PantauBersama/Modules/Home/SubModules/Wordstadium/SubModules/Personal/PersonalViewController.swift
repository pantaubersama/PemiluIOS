//
//  PersonalViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PersonalViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private var headerView: BannerHeaderView!
    private var emptyView = EmptyView()
    private var viewModel: PersonalViewModel!
    
    var rControl : UIRefreshControl?
    
    convenience init(viewModel: PersonalViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(WordstadiumViewCell.self)
//        tableView.delegate = nil
//        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        viewModel.output.showHeader
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = BannerHeaderView()
                    self.tableView.tableHeaderView = self.headerView
                    
                    self.viewModel.output.bannerInfo
                        .drive(onNext: { (banner) in
                            self.headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumViewCell
        cell.collectionView.reloadData()
        return cell
    }
 


}
