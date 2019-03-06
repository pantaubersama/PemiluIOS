//
//  NotificationController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Networking

class NotificationController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: NotificationViewModel!
    private let rControl = UIRefreshControl()
    var notifMenu: NotifMenu = .all
    
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifikasi"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.rowHeight = 130
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(InfoNotifCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorColor = Color.RGBColor(red: 250, green: 250, blue: 250)
        tableView.refreshControl = rControl
        
        tableView.rx.modelSelected(CellConfigurator<InfoNotifCell, InfoNotifCell.Input>.self)
            .map({ $0.item.notif })
            .bind(to: viewModel.input.itemSelected)
            .disposed(by: disposeBag)
        
        
        rControl.rx.controlEvent(.valueChanged)
            .map({ self.notifMenu })
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .do(onNext: { [unowned self] (_) in
                self.rControl.endRefreshing()
//                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.tableView.isHidden = false
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
        
        segmentedControl.rx.value
            .skip(1)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (i) in
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                self.tableView.isHidden = true
                if i == 0 {
                    self.viewModel.input.changeNotifMenuI.onNext(.all)
                } else {
                    self.viewModel.input.changeNotifMenuI.onNext(.event)
                }
            })
            .disposed(by: disposeBag)
        
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
}
