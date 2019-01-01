//
//  BannerInfoController.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class BannerInfoController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    var viewModel: BannerInfoViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.registerReusableCell(BannerInfoViewCell.self)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        viewModel.output.bannerInfoCell
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }.disposed(by: disposeBag)
        
        btnClose.rx.tap
            .bind(to: viewModel.input.finishTrigger)
            .disposed(by: disposeBag)
    }

}

extension BannerInfoController: UITableViewDelegate {
    
}
