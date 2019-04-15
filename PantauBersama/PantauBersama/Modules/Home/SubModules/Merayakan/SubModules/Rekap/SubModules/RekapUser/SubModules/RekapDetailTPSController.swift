//
//  RekapDetailTPSController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources

class RekapDetailTPSController: UITableViewController {
    
    var viewModel: RekapDetailTPSViewModel!
    private let disposeBag = DisposeBag()
    private let headerView = SummaryPresidenTPSView()
    private let footerView = RekapDetailTPSFooter()
    private var dataSource: RxTableViewSectionedReloadDataSource<SectionModelsTPSImages>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 64.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.registerReusableCell(RekapDetailPhotosCell.self)
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = footerView
        
        title = "TPS"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionModelsTPSImages>(configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as RekapDetailPhotosCell
            cell.configureCell(item: RekapDetailPhotosCell.Input(data: item, title: "Gambar \(indexPath.row)"))
            return cell
        })
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelected)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsImageO
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.tableView.reloadData()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        dataSource.titleForHeaderInSection = { dataSource, indexPath in
            return dataSource.sectionModels[indexPath].title
        }
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { [weak self] (offset) -> Observable<Void> in
                guard let `self` = self else { return Observable.empty() }
                if offset.y > self.tableView.contentSize.height - (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextI)
            .disposed(by: disposeBag)
        
    
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.summaryPresidenO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.headerView.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.c1SummaryO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                self.footerView.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        /// Just show dummy c1
        viewModel.output.isDataDummyC1O
            .drive(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.footerView.configureDummy()
            })
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
