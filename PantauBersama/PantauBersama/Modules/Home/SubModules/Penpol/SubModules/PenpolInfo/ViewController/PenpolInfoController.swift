//
//  PenpolInfoController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PenpolInfoController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: UIButton!
    
    var viewModel: PenpolInfoViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.registerReusableCell(PenpolInfoCell.self)
        
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        viewModel.output.quizInfoCell
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

extension PenpolInfoController: UITableViewDelegate {
   
}
