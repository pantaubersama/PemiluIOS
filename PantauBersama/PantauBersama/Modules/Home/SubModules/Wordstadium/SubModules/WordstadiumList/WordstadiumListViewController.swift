//
//  WordstadiumListViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 15/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Networking

class WordstadiumListViewController: UITableViewController {

    var viewModel: WordstadiumListViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    lazy var tableHeaderView = WordstadiumListHeaderView()
    
    internal lazy var rControl = UIRefreshControl()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionWordstadium>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.configure(with: .white)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = tableHeaderView
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = rControl
        } else {
            tableView.addSubview(rControl)
        }
        
        back.rx.tap
            .bind(to: viewModel.input.backTriggger)
            .disposed(by: disposeBag)

        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionWordstadium>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                cell.configureCell(item: WordstadiumItemViewCell.Input( wordstadium: item))
                return cell
        })
        
        tableView.rx.modelSelected(Challenge.self)
            .bind(to: viewModel.input.itemSelectedTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .do(onNext: { (items) in
                let section = items[0]
                self.title = section.title
                self.tableHeaderView.config(description: section.descriptiom)
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        rControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { (isLoading) in
                if !isLoading {
                    self.rControl.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelected
            .drive()
            .disposed(by: disposeBag)
    }

    // TODO: for testing purpose
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let wordstadium = dataSource.sectionModels[indexPath.section]
//        
//        switch wordstadium.itemType {
//        case .challenge:
//            guard let navigationController = self.navigationController else { return }
////            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: wordstadium.items[indexPath.row].type)
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: wordstadium.items[indexPath.row])
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .comingSoon:
//            guard let navigationController = self.navigationController else { return }
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: wordstadium.items[indexPath.row])
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .done:
//            guard let navigationController = self.navigationController else { return }
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, data: wordstadium.items[indexPath.row])
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .liveNow:
//            guard let navigationController = self.navigationController else { return }
//            let liveDebatCoordinator = LiveDebatCoordinator(navigationController: navigationController, viewType: .watch)
//            liveDebatCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        }
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.configure(with: .white)
    }
    
}
