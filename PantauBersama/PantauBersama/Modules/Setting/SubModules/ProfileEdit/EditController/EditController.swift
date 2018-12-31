//
//  EditController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 01/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class EditController: UITableViewController {
    
    var viewModel: EditViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        let save = UIBarButtonItem(image: #imageLiteral(resourceName: "baselineCheck24Px"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationItem.rightBarButtonItem = save
        navigationController?.navigationBar.configure(with: .white)
        
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = Color.groupTableViewBackground
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 90.0
        tableView.tableFooterView = UIView()
        tableView.registerReusableCell(TextViewCell.self)
        
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        save.rx.tap
            .bind(to: viewModel.input.doneTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.output.isEnabled
            .do(onNext: { (isEnabled) in
                self.navigationItem.rightBarButtonItem = isEnabled ? save : save
            })
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else { return UITableViewCell() }
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.errorTracker
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    
}
