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
import RxDataSources

class PublicViewController: UITableViewController {

    private let disposeBag = DisposeBag()
    private var headerView: BannerHeaderView!
    private var emptyView = EmptyView()
    private var viewModel: PublicViewModel!
    
    var rControl : UIRefreshControl?
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionWordstadium>!
    
    convenience init(viewModel: PublicViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerReusableCell(WordstadiumViewCell.self)
        tableView.registerReusableCell(SectionViewCell.self)
        tableView.registerReusableCell(SectionViewCell2.self)
        tableView.registerReusableCell(SeeMoreCell.self)
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
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
        
        viewModel.output.itemSelected
            .drive()
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionWordstadium>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                let wordstadium = dataSource.sectionModels[indexPath.section]
                
                if wordstadium.itemType == .live {
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumViewCell
                    cell.configureCell(item: WordstadiumViewCell.Input(type: ItemCollectionType.live, wordstadium: wordstadium.itemsLive))
                    cell.collectionView.reloadData()
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                    cell.configureCell(item: WordstadiumItemViewCell.Input(type: dataSource.sectionModels[indexPath.section].itemType))
                    return cell
                }
        })
        
        viewModel.output.items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        if wordstadium.itemType == .live {
            return 0
        } else {
            return wordstadium.descriptiom.count == 0 ? 50:95
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        return wordstadium.itemType == .live ? 0:30.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wordstadium = dataSource.sectionModels[section]
        
        if wordstadium.itemType == .live {
            return nil
        } else {
            if wordstadium.descriptiom.count == 0 {
                let item = tableView.dequeueReusableCell() as SectionViewCell
                item.configureCell(item:
                    SectionViewCell.Input(title: wordstadium.title,
                                          type: wordstadium.itemType))
                return item
            } else {
                let item = tableView.dequeueReusableCell() as SectionViewCell2
                item.configureCell(item:
                    SectionViewCell2.Input(title: wordstadium.title,
                                           desc: wordstadium.descriptiom))
                return item
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let wordstadium = dataSource.sectionModels[section]
        
        if wordstadium.itemType == .live {
            return nil
        } else {
            let item = tableView.dequeueReusableCell() as SeeMoreCell
            item.configureCell(item:
                SeeMoreCell.Input(wordstadium: wordstadium,
                                  viewModel: self.viewModel.seeMoreViewModel))
            return item
        }
        
    }
    

    // TODO: for testing purpose
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wordstadium = dataSource.sectionModels[indexPath.section]
        
        if wordstadium.itemType == .challenge {
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        } else {
            guard let navigationController = self.navigationController else { return }
            let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController)
            liveDebatCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }
}
