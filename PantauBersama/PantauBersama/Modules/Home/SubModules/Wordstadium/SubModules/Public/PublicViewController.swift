//
//  PublicViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PublicViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private var headerView: BannerHeaderView!
    private var emptyView = EmptyView()
    private var viewModel: PublicViewModel!
    
    var rControl : UIRefreshControl?
    
    convenience init(viewModel: PublicViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(WordstadiumViewCell.self)
        tableView.registerReusableCell(SectionViewCell.self)
        tableView.registerReusableCell(SeeMoreCell.self)
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
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

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0:50.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 0:20.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= 1 {
            let section = tableView.dequeueReusableCell() as SectionViewCell
            return section
        } else { return nil}
        
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section >= 1 {
            let footer = tableView.dequeueReusableCell() as SeeMoreCell
            return footer
        } else { return nil}
        
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return section == 0 ? 1:3
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumViewCell
            cell.collectionView.reloadData()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
            return cell
        }
        
    }

    // TODO: for testing purpose
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController)
        liveDebatCoordinator
            .start()
            .subscribe()
            .disposed(by: disposeBag)
    }
}
