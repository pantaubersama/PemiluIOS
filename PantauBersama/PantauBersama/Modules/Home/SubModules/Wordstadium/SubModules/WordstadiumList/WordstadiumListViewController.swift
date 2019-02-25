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
                let wordstadium = dataSource.sectionModels[indexPath.section]
                
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                cell.configureCell(item: WordstadiumItemViewCell.Input(type: wordstadium.type ,itemType: wordstadium.itemType, wordstadium: wordstadium.items[indexPath.row]))
                return cell
        })
        
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
    }

    // TODO: for testing purpose
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let wordstadium = dataSource.sectionModels[indexPath.section]
//        
//        switch wordstadium.itemType {
//        case .privateChallenge, .challenge, .inProgress:
//            guard let navigationController = self.navigationController else { return }
////            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: wordstadium.items[indexPath.row].type)
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .challenge)
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .privateComingsoon, .comingsoon:
//            guard let navigationController = self.navigationController else { return }
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .soon)
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .privateDone, .done:
//            guard let navigationController = self.navigationController else { return }
//            let challengeCoordinator = ChallengeCoordinator(navigationController: navigationController, type: .done)
//            challengeCoordinator
//                .start()
//                .subscribe()
//                .disposed(by: disposeBag)
//        case .live:
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
