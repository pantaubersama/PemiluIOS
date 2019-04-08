//
//  RekapController.swift
//  PantauBersama
//
//  Created by asharijuang on 16/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

enum RekapType {
    case kota
    case kecamatan
    case tps
}

class RekapController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var emptyView = EmptyView()
    var viewModel: RekapViewModel!
    private var headerView = RekapHeaderView()
    
    private let disposeBag = DisposeBag()
    
    private var pageType : RekapType!
    
    convenience init(viewModel: RekapViewModel, pageType type: RekapType = .kota) {
        self.init()
        self.viewModel  = viewModel
        self.pageType   = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(RekapViewCell.self)
        tableView.rowHeight = 150.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        // table view header
        self.tableView.tableHeaderView  = headerView
        self.headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115 + 400)
        self.headerView.config(viewModel: self.viewModel)
        let footer                      = RekapFooterView()
        self.tableView.tableFooterView  = footer
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (_) in
                guard let `self` = self else { return }
                self.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                cell.configureCell(item: RekapViewCell.Input(data: item, type: self.pageType))
                return cell
            }
            .disposed(by: disposeBag)
        
    }
    
}

//extension RekapController : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 1 {
//            return self.viewModel.itemsProvince.value.count
//        }else { return 1 }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell() as SuaraCapresViewCell
//            cell.configureCell(item: SuaraCapresViewCell.Item(viewModel: self.viewModel))
//            return cell
//        }else {
//            let cell = tableView.dequeueReusableCell() as RekapViewCell
//            cell.configure(data: "", type: self.pageType)
//            return cell
//        }
//    }
//}
//
//extension RekapController : UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            return 400
//        }else { return 150.0 }
//    }
//}
