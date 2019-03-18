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
import Networking

class LiniWordstadiumViewController: UITableViewController, ILiniWordstadiumViewController {
    
    var viewModel: ILiniWordstadiumViewModel!
    internal let disposeBag = DisposeBag()
    
    private var headerView: BannerHeaderView!
    internal lazy var rControl = UIRefreshControl()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionWordstadium>!
    
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
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionWordstadium>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                switch item {
                case .live(let challenges):
                    let sectionData = dataSource.sectionModels[indexPath.section]
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumViewCell
                    cell.configureCell(item: WordstadiumViewCell.Input(challenges: challenges, viewModel: self.viewModel, sectionData: sectionData))
                    return cell
                case .standard(let challenge):
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                    cell.configureCell(item: WordstadiumItemViewCell.Input(wordstadium: challenge))
                    cell.moreMenuBtn.rx.tap
                        .map({ challenge })
                        .bind(to: self.viewModel.input.moreI)
                        .disposed(by: self.disposeBag)
                    
                    return cell
                case .empty:
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumEmptyViewCell
                    return cell
                }
        })
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { (items) in
                print("items \(items)")
                self.tableView.reloadData()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .liveNow, .inProgress:
            return 0
        default :
            return wordstadium.descriptiom.count == 0 ? 50:95
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .liveNow, .inProgress:
            return 0
        default :
            return wordstadium.seeMore == false ? 0: 30
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let wordstadium = dataSource.sectionModels[section]
        
        switch wordstadium.itemType {
        case .liveNow, .inProgress:
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
        case .liveNow, .inProgress:
            return nil
        default :
            let item = tableView.dequeueReusableCell() as SeeMoreCell
            item.configureCell(item:
                SeeMoreCell.Input(wordstadium: wordstadium,
                                  viewModel: self.viewModel))
            return item
        }
        
    }


}
