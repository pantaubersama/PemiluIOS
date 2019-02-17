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

class RekapController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    private var emptyView = EmptyView()
    private var viewModel: RekapViewModel!
    
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: RekapViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.input.loadDataTrigger.onNext(())
        
//        let button = UIButton()
//        button.rx.tap
//            .bind(to: viewModel.input.loadDataTrigger)
//            .disposed(by: disposeBag)
        tableView.estimatedRowHeight = 160.0
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        tableView.registerReusableCell(RekapViewCell.self)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        viewModel.output.items.drive(tableView.rx.items) { table, row, item -> UITableViewCell in
            let cell = table.dequeueReusableCell() as RekapViewCell
            
            return cell
        }
        .disposed(by: disposeBag)
        
        let a = tableView.rx.itemSelected
        a.bind { [unowned self](indexPath) in
            self.viewModel.input.launchDetailTrigger.onNext(())
        }
        .disposed(by: disposeBag)
        
        viewModel.output.launchDetail.drive().disposed(by: disposeBag)
    }
    
}

//extension RekapController : UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell() as RekapViewCell
//
//        return cell
//    }
//}
//
//extension RekapController : UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 160.0
//    }
//}
