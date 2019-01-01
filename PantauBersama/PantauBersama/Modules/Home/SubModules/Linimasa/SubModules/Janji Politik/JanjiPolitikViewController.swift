//
//  JanjiPolitikViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common

class JanjiPolitikViewController: UITableViewController {
    
    private var headerView: LinimasaHeaderView!
    private var viewModel: JanjiPolitikViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    convenience init(viewModel: JanjiPolitikViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaJanjiCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerView = LinimasaHeaderView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.janpolCells
            .do(onNext: { [weak self] (_) in
                self?.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (pilpres) -> Observable<JanjiType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.hapus)
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.salin)
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.bagikan)
                        observer.on(.completed)
                    })
                    let lapor = UIAlertAction(title: "Laporkan", style: .default, handler: { (_) in
                        observer.onNext(JanjiType.laporkan)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    alert.addAction(hapus)
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(lapor)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            })
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .drive()
            .disposed(by: disposeBag)
    }
    
}


// Dummy

//extension JanjiPolitikViewController {
//    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 15
//    }
//    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 226.0
//    }
//    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LinimasaJanjiCell
//        cell.bind(viewModel: viewModel)
//        return cell
//    }
//    
//    // dummy sembari nunggu API lewat sini dulu
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let detail = DetailJanjiController()
//        detail.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(detail, animated: true)
//    }
//}
