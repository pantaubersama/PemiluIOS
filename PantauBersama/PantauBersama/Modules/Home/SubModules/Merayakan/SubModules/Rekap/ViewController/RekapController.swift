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
    var viewModel: RekapViewModel!
    private var headerView = RekapHeaderView()
    private let emptyView = RekapEmptyView()
    
    private let disposeBag = DisposeBag()
    
    private var pageType : RekapType!
    private var tap: UITapGestureRecognizer = UITapGestureRecognizer()
    
    internal lazy var rControl = UIRefreshControl()
    
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
        // table view header
        self.headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 115 + 420)
        self.tableView.tableHeaderView  = headerView
        self.headerView.config(viewModel: self.viewModel, tableView: self.tableView)
        let footer                      = RekapFooterView()
        footer.addGestureRecognizer(tap)
        footer.isUserInteractionEnabled = true
        self.tableView.tableFooterView  = footer
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = rControl
        } else {
            tableView.addSubview(rControl)
        }
        
        rControl.rx.controlEvent(.valueChanged)
            .map({ (_) -> String in
                return ""
            })
            .bind(to: viewModel.input.refreshTrigger)
            .disposed(by: disposeBag)
        
        tap.rx.event
            .bind(to: viewModel.input.linkSelected)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (items) in
                guard let `self` = self else { return }
                self.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell() as RekapViewCell
                cell.configureCell(item: RekapViewCell.Input(data: item, type: self.pageType))
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .bind(to: self.viewModel.input.itemSelected)
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelectedO
            .drive()
            .disposed(by: disposeBag)
        
      
        viewModel.output.linkSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        /// Create tableView empty view first
        self.emptyView.frame = self.tableView.bounds
        self.tableView.backgroundView = self.emptyView
        self.tableView.tableHeaderView?.isHidden = true
        self.tableView.tableFooterView?.isHidden = true
        self.tableView.isScrollEnabled = false
    }
    
}
