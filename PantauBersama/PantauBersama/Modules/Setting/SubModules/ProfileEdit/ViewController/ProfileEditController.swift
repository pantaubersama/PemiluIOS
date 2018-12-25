//
//  ProfileEditController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 25/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class ProfileEditController: UITableViewController {
    
    var viewModel: ProfileEditViewModel!
    private let disposeBag = DisposeBag()
    
    private var tableHeaderView: HeaderEditProfile = {
       let view = HeaderEditProfile()
        return view
    }()
    
    private var tableFooterView: SubmitFooterView = {
        let view = SubmitFooterView()
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK: TableView
        tableView.registerReusableCell(TextViewCell.self)
        tableView.tableHeaderView = tableHeaderView
        tableView.tableFooterView = tableFooterView
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        viewModel.output.items
            .drive(tableView.rx.items) { tableView, row, item in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: item.reuseIdentifier) else { return UITableViewCell() }
                item.configure(cell: cell)
                return cell
            }
            .disposed(by: disposeBag)
    }
    
}
