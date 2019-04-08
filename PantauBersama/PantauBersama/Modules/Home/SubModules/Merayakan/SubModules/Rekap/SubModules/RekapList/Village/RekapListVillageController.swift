//
//  RekapListVillageController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RekapListVillageController: UITableViewController {
    
    var viewModel: RekapListVillageViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 150.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.registerReusableCell(RekapViewCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                cell.configureVillage(data: item, type: .kota)
                return cell
            }.disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.titleO
            .drive(onNext: { [weak self] (name) in
                guard let `self` = self else { return }
                self.navigationItem.title = name
            })
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
}
