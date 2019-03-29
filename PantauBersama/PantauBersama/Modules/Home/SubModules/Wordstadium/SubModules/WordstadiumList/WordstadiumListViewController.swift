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
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { [unowned self] (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height -
                    (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextTrigger)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionWordstadium>(
            configureCell: { (dataSource, tableView, indexPath, item) in
                switch item {
                case .standard(let challenge):
                    let cell = tableView.dequeueReusableCell(indexPath: indexPath) as WordstadiumItemViewCell
                    cell.configureCell(item: WordstadiumItemViewCell.Input( wordstadium: challenge))
                    
                    cell.moreMenuBtn.rx.tap
                        .map({ challenge })
                        .bind(to: self.viewModel.input.moreTrigger)
                        .disposed(by: self.disposeBag)
                    
                    return cell
                default:
                    return UITableViewCell(style: .default, reuseIdentifier: "Cell")
                }

        })
        
        tableView.rx.itemSelected
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
        
        viewModel.output.moreSelectedO
            .asObservable()
            .flatMapLatest({ [weak self] (wordstadium) -> Observable<WordstadiumType> in
                return Observable.create({ (observer) -> Disposable in
                    let me = AppState.local()?.user
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus Challenge", style: .default, handler: { (_) in
                        observer.onNext(WordstadiumType.hapus(data: wordstadium.id))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(WordstadiumType.salin(data: wordstadium))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(WordstadiumType.bagikan(data: wordstadium))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    /// Check if challenge audience just one and user id is match
                    let challenger = wordstadium.audiences.filter({ $0.role == .challenger }).first
                    let isMyChallenge = me?.email == (challenger?.email ?? "")
                    if isMyChallenge && wordstadium.progress == .waitingOpponent && wordstadium.type == .openChallenge {
                        alert.addAction(hapus)
                    }
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelectedO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.configure(with: .white)
    }
    
}
