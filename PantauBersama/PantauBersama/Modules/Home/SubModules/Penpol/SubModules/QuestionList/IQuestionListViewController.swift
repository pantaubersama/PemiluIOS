//
//  IQuestionListViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol IQuestionListViewController where Self: UIViewController {
    var viewModel: IQuestionListViewModel! { get }
    var disposeBag: DisposeBag { get }
    
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, emptyView: EmptyView, with viewModel: IQuestionListViewModel)
}

extension IQuestionListViewController {
    
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, emptyView: EmptyView, with viewModel: IQuestionListViewModel) {
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map({ "" })
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .do(onNext: {  (items) in
                tableView.backgroundView = nil
                if items.count == 0 {
                    emptyView.frame = tableView.bounds
                    tableView.backgroundView = emptyView
                } else {
                    tableView.backgroundView = nil
                }
                refreshControl.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { (offset) -> Observable<Void> in
                if offset.y > tableView.contentSize.height -
                    (tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextPageI)
            .disposed(by: disposeBag)
        
        viewModel.output.filterO
            .drive(onNext: { (_) in
                // set to top of table view after set filter
                refreshControl.sendActions(for: .valueChanged)
                
                let indexPath = IndexPath(row: 0, section: 0)
                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.createO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.bannerSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelectedO
            .asObservable()
            .flatMapLatest({ [weak self] (question) -> Observable<QuestionType> in
                return Observable.create({ (observer) -> Disposable in
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.hapus(question: question))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.salin(question: question))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.bagikan(question: question))
                        observer.on(.completed)
                    })
                    let laporkan = UIAlertAction(title: "Laporkan Sebagai Spam", style: .default, handler: { (_) in
                        observer.onNext(QuestionType.laporkan(question: question))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    if question.isMyQuestion {
                        alert.addAction(hapus)
                    }
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(laporkan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelectedO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)

        
        viewModel.output.error
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
    }
    
}
