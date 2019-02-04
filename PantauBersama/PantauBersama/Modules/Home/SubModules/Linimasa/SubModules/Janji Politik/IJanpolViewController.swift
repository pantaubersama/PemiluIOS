//
//  IJanpolViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 11/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol IJanpolViewController where Self: UIViewController {
    var viewModel: IJanpolListViewModel! { get }
    var disposeBag: DisposeBag { get }
    
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, emptyView: EmptyView, with viewModel: IJanpolListViewModel)
    func bind(headerView: BannerHeaderView, with viewModel: IJanpolListViewModel)
}

extension IJanpolViewController {
    
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, emptyView: EmptyView, with viewModel: IJanpolListViewModel) {
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .filter({ $0.y > tableView.contentSize.height - (tableView.frame.height * 2) })
            .mapToVoid()
            .bind(to: viewModel.input.nextPageI)
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .do(onNext: { (items) in
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
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map({ "" })
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        viewModel.output.filterO
            .drive(onNext: { (_) in
                // set to top of table view after set filter
                refreshControl.sendActions(for: .valueChanged)
                
//                let indexPath = IndexPath(row: 0, section: 0)
//                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelectedO
            .asObservable()
            .flatMapLatest({ [weak self] (janpol) -> Observable<JanjiType> in
                return Observable.create({ (observer) -> Disposable in
                    let my = AppState.local()?.user
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.hapus(id: janpol.id))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.salin(data: janpol))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.bagikan(data: janpol))
                        observer.on(.completed)
                    })
//                    let lapor = UIAlertAction(title: "Laporkan", style: .default, handler: { (_) in
//                        observer.onNext(JanjiType.laporkan)
//                        observer.on(.completed)
//                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    if janpol.creator.cluster?.id == my?.cluster?.id && janpol.creator.id == my?.id && my?.cluster?.isEligible == true {
                        alert.addAction(hapus)
                    }
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
//                    alert.addAction(lapor)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.error
            .drive(onNext: { [weak self] (error) in
                guard let `self` = self else { return }
                guard let alert = UIAlertController.alert(with: error) else { return }
                self.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelectedO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
    }
    
    
    func bind(headerView: BannerHeaderView, with viewModel: IJanpolListViewModel) {
        viewModel.output.bannerO
            .drive(onNext: { (banner) in
                headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.bannerSelectedO
            .drive()
            .disposed(by: disposeBag)
    }
    
}
