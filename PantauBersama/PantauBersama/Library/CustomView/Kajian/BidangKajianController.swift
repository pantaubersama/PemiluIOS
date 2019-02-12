//
//  BidangKajianController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class BidangKajianController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var btnClose: ImageButton!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: BidangKajianViewModel!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnClose.rx.tap
            .bind(to: viewModel.input.cancelI)
            .disposed(by: disposeBag)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 44.0
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        searchBar.rx.text
            .orEmpty
            .distinctUntilChanged()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .bind(to: viewModel.input.queryI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = UITableViewCell()
                cell.textLabel?.text = item
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
    }
    
}
