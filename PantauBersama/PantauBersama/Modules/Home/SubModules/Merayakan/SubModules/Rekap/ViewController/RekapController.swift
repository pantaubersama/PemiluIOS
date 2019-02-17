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
    
    private let disposeBag = DisposeBag()
    
    private var pageType : RekapType!
    
    convenience init(viewModel: RekapViewModel, pageType type: RekapType = .kota) {
        self.init()
        self.viewModel  = viewModel
        self.pageType   = type
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // viewModel.input.loadDataTrigger.onNext(())
        
        tableView.estimatedRowHeight = 150.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        tableView.registerReusableCell(RekapViewCell.self)
        tableView.registerReusableCell(SuaraCapresViewCell.self)
        
        tableView.delegate = self
        tableView.dataSource = self
//        viewModel.output.items.drive(tableView.rx.items) { table, row, item -> UITableViewCell in
//            let cell = table.dequeueReusableCell() as RekapViewCell
//
//            return cell
//        }
//        .disposed(by: disposeBag)
        
//        let a = tableView.rx.itemSelected
//        a.bind { [unowned self](indexPath) in
//            self.viewModel.input.kecamatanTrigger.onNext(())
//        }
//        .disposed(by: disposeBag)
        
//        viewModel.output.kecamatanO.drive().disposed(by: disposeBag)
    }
    
}

extension RekapController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 3
        }else { return 1 }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell() as SuaraCapresViewCell
            cell.configureCell(item: (Any).self)
            return cell
        }else {
            let cell = tableView.dequeueReusableCell() as RekapViewCell
            cell.configure(data: "", type: self.pageType)
            return cell
        }
    }
}

extension RekapController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let navigationController = self.navigationController else { return }
        if indexPath.section == 1 {
            let rekapCoordinator    = RekapCoordinator(navigationController: navigationController)
            rekapCoordinator
            .start()
            .subscribe()
            .disposed(by: disposeBag)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 400
        }else { return 150.0 }
    }
}
