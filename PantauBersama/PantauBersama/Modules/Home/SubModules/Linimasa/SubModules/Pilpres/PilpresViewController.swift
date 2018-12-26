//
//  PilpresViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class PilpresViewController: UITableViewController {
    
    private let disposeBag = DisposeBag()
    private var headerView: LinimasaHeaderView!
    
    private var viewModel: PilpresViewModel!
    
    convenience init(viewModel: PilpresViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        headerView = LinimasaHeaderView()
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        
        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (pilpres) -> Observable<PilpresType> in
                return Observable.create({ (observer) -> Disposable in
                    
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(PilpresType.salin)
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(PilpresType.bagikan)
                        observer.on(.completed)
                    })
                    let twitter = UIAlertAction(title: "Buka di Aplikasi Twitter", style: .default, handler: { (_) in
                        observer.onNext(PilpresType.twitter)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(twitter)
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

extension PilpresViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as LinimasaCell
        cell.pilpres = "pilpres"
        cell.bind(viewModel: viewModel)
        return cell
    }
}
