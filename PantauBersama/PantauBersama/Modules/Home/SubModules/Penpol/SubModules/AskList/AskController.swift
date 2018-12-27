//
//  AskController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 19/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AskController: UITableViewController {

    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: AskViewModel!
    
    convenience init(viewModel: AskViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.registerReusableCell(BannerInfoAskCell.self)
        tableView.registerReusableCell(HeaderAskCell.self)
        tableView.registerReusableCell(AskViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        viewModel.output.createSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)

        viewModel.output.moreSelected
            .asObservable()
            .flatMapLatest({ [weak self] (ask) -> Observable<AskType> in
                return Observable.create({ (observer) -> Disposable in

                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(AskType.hapus)
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(AskType.salin)
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(AskType.bagikan(ask: ask))
                        observer.on(.completed)
                    })
                    let laporkan = UIAlertAction(title: "Laporkan", style: .default, handler: { (_) in
                        observer.onNext(AskType.laporkan)
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    alert.addAction(hapus)
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
            .bind(to: viewModel.input.moreMenuTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuSelected
            .drive()
            .disposed(by: disposeBag)
        
    }

}


extension AskController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 15 : 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as BannerInfoAskCell
            cell.bind(viewModel: viewModel)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as HeaderAskCell
            cell.bind(viewModel: viewModel)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as AskViewCell
            cell.ask = "ask"
            cell.bind(viewModel: viewModel)
            return cell
        }
    }
}
