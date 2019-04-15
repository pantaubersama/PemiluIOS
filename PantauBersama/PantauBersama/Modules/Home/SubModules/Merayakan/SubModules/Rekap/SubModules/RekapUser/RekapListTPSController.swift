//
//  RekapListTPSController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 08/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RekapListTPSController: UITableViewController {
    
    var viewModel: RekapListTPSViewModel!
    private let disposeBag = DisposeBag()
    
    private lazy var emptyView = EmptyView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 120.0
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        tableView.registerReusableCell(RekapTPSUserCell.self)
        tableView.tableFooterView = UIView()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell() as RekapTPSUserCell
                cell.configureCell(item: RekapTPSUserCell.Input(data: item))
                cell.selectionStyle = .none
                return cell
            }
            .disposed(by: disposeBag)
        
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
