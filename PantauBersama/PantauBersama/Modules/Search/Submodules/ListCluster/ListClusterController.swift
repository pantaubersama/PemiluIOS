//
//  ListClusterController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 19/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ListClusterController: UITableViewController {

    var viewModel: ClusterSearchViewModel!
    
    private let disposeBag = DisposeBag()
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: ClusterSearchViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = nil
        tableView.delegate = nil
        tableView.rowHeight = 75.0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.registerReusableCell(ClusterSearchCell.self)
        tableView.refreshControl = rControl
        
        viewModel.output.items
            .do(onNext: { [unowned self](items) in
                self.rControl.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else { return UITableViewCell() }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.contentOffset
            .distinctUntilChanged()
            .flatMapLatest { (offset) -> Observable<Void> in
                if offset.y > self.tableView.contentSize.height -
                    (self.tableView.frame.height * 2) {
                    return Observable.just(())
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: viewModel.input.nextI)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelected)
            .disposed(by: disposeBag)
        
        viewModel.output.selected
            .drive()
            .disposed(by: disposeBag)
        
        rControl.rx.controlEvent(.valueChanged)
            .map({ "" })
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        viewModel.output.filter
            .drive(onNext: { [weak self] (_) in
                // set to top of table view after set filter
                self?.refreshControl?.sendActions(for: .valueChanged)
            })
            .disposed(by: disposeBag)
        
    }

}
