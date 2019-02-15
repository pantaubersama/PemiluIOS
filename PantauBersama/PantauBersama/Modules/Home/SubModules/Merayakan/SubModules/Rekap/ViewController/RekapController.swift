//
//  RekapController.swift
//  PantauBersama
//
//  Created by asharijuang on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class RekapController: UITableViewController {
    private var emptyView = EmptyView()
    private var viewModel: RekapViewModel!
    
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: RekapViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.registerReusableCell(RekapViewCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        self.refreshControl?.rx.controlEvent(.valueChanged)
            .map({ (_) -> String in
                return ""
            })
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.feedsCells
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.tableView.backgroundView = nil
                if items.count == 0 {
                    self.emptyView.frame = self.tableView.bounds
                    self.tableView.backgroundView = self.emptyView
                } else {
                    self.tableView.backgroundView = nil
                }
                self.refreshControl?.endRefreshing()
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
    }

}
