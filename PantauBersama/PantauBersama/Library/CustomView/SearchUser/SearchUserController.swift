//
//  SearchUserController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class SearchUserController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnClose: ImageButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: SearchUserViewModel!
    var type: SearchUserType = .default
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let rControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(UserChallengeCell.self)
        tableView.rowHeight = 60.0
        
        btnClose.rx.tap
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = rControl
        } else {
            tableView.addSubview(rControl)
        }
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.queryI)
            .disposed(by: disposeBag)
        
        searchBar.returnKeyType = .done
        searchBar.rx.searchButtonClicked.bind { [unowned self] in
            self.searchBar.endEditing(true)
        }.disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (_) in
                self?.rControl.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell() as UserChallengeCell
                cell.configure(data: item)
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
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        rControl.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        switch type {
        case .userTwitter:
            self.searchBar.placeholder = "Cari akun Twitter..."
        default:
            self.searchBar.placeholder = "Cari..."
        }
    }
}
