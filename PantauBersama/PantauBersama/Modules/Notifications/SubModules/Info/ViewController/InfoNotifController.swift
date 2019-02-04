//
//  InfoNotifController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class InfoNotifController: UITableViewController {

    private var viewModel: InfoNotifViewModel!
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: InfoNotifViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 130
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(InfoNotifCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorColor = Color.RGBColor(red: 250, green: 250, blue: 250)
        tableView.refreshControl = UIRefreshControl()
        
        viewModel.output.items
            .do(onNext: { [unowned self] (_) in
                self.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else {
                    return UITableViewCell()
                }
                cell.tag = row
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
}
