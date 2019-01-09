//
//  KategoriClusterController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 05/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class KategoriClusterController: UIViewController {
    
    private let searchBar: UISearchBar = {
       let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonAdd: Button!
    
    var viewModel: KategoriClusterViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Cari Kategori"
        navigationItem.titleView = searchBar
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.rowHeight = 44.0
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
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
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.configure(type: .pantau)
        
    }
    
}
