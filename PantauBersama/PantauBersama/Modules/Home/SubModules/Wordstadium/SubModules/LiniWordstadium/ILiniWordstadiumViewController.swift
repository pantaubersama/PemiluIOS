//
//  ILiniWordstadiumViewViewController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 22/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common

protocol ILiniWordstadiumViewController where Self: UIViewController {
    var viewModel: ILiniWordstadiumViewModel! { get }
    var disposeBag: DisposeBag { get }
    
    func registerCells(with tableView: UITableView)
    func bind(headerView: BannerHeaderView, with viewModel: ILiniWordstadiumViewModel)
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, with viewModel: ILiniWordstadiumViewModel)
}

extension ILiniWordstadiumViewController {
    func registerCells(with tableView: UITableView) {
        tableView.registerReusableCell(WordstadiumViewCell.self)
        tableView.registerReusableCell(WordstadiumEmptyViewCell.self)
        tableView.registerReusableCell(SectionViewCell.self)
        tableView.registerReusableCell(SectionViewCell2.self)
        tableView.registerReusableCell(SeeMoreCell.self)
        tableView.registerReusableCell(WordstadiumItemViewCell.self)
    }
    
    func bind(tableView: UITableView, refreshControl: UIRefreshControl, with viewModel: ILiniWordstadiumViewModel){
        
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
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelectedO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        viewModel.output.isLoading
            .drive(onNext: { (isLoading) in
                if !isLoading {
                    refreshControl.endRefreshing()
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
    
    func bind(headerView: BannerHeaderView, with viewModel: ILiniWordstadiumViewModel) {
        viewModel.output.bannerO
            .drive(onNext: { (banner) in
                headerView.config(banner: banner, viewModel: self.viewModel.headerViewModel)
            })
            .disposed(by: disposeBag)

    }
}
