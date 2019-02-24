//
//  LiniWordstadiumViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import RxDataSources

class LiniWordstadiumViewController: UITableViewController, ILiniWordstadiumViewController {
    
    var viewModel: ILiniWordstadiumViewModel!
    internal let disposeBag = DisposeBag()
    
    private var headerView: BannerHeaderView!
    internal lazy var rControl = UIRefreshControl()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionChallenge>!
    
    convenience init(viewModel: ILiniWordstadiumViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()

        if #available(iOS 10.0, *) {
            tableView.refreshControl = rControl
        } else {
            tableView.addSubview(rControl)
        }
        
        registerCells(with: tableView)
        
        bind(tableView: tableView, refreshControl: rControl, with: viewModel)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.input.refreshI.onNext(())
        
        viewModel.output.showHeaderO
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = BannerHeaderView()
                    self.tableView.tableHeaderView = self.headerView
                    
                    self.viewModel.output.bannerO
                        .drive(onNext: { (banner) in
                            self.bind(headerView: self.headerView, with: self.viewModel)
                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionChallenge>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                let wordstadium = dataSource.sectionModels[indexPath.section]
                
                switch wordstadium.itemType {
                case .live,.inProgress :
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumViewCell
                    cell.configureCell(item: WordstadiumViewCell.Input(wordstadium: wordstadium, viewModel: self.viewModel))
                    cell.collectionView.reloadData()
                    return cell
                default:
                    let itemWordstadium = wordstadium.items[indexPath.row]
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                    cell.configureCell(item: WordstadiumItemViewCell.Input(type: wordstadium.itemType, wordstadium: itemWordstadium))
                    cell.moreMenuBtn.rx.tap
                        .map({ itemWordstadium })
                        .bind(to: self.viewModel.input.moreI)
                        .disposed(by: self.disposeBag)
                    return cell
                }
        })
        
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .drive(onNext: { [unowned self](item) in
                print("ahhahaha \(item)")
            })
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .live, .inProgress:
            return 0
        default :
            return wordstadium.descriptiom.count == 0 ? 50:95
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .live, .inProgress:
            return 0
        default :
            return 30
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .live, .inProgress:
            return nil
        default :
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
        
        switch wordstadium.itemType {
        case .live, .inProgress:
            return nil
        default :
            let item = tableView.dequeueReusableCell() as SeeMoreCell
            item.configureCell(item:
                SeeMoreCell.Input(wordstadium: wordstadium,
                                  viewModel: self.viewModel))
            return item
        }
        
    }
    
    
    // TODO: for testing purpose
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let wordstadium = dataSource.sectionModels[indexPath.section].itemType
        
        switch wordstadium {
        case .live, .inProgress:
            guard let navigationController = self.navigationController else { return }
            let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController, viewType: .myTurn)
            liveDebatCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .challenge, .privateChallenge:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .challenge)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .comingsoon, .privateComingsoon:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .soon)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        case .done, .privateDone:
            guard let navigationController = self.navigationController else { return }
            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .done)
            challengeCoordinator
                .start()
                .subscribe()
                .disposed(by: disposeBag)
        }
    }


}
