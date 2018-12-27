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
import RxDataSources

class ProfileEditController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: ProfileEditViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfProfileEditData>!
    
    private var tableHeaderView: HeaderEditProfile!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Profile"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        // MARK: TableView
        tableView.registerReusableCell(TextViewCell.self)
        tableHeaderView = HeaderEditProfile()
        tableView.tableHeaderView = tableHeaderView
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.allowsSelection = false
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfProfileEditData>(configureCell: { (dataSource, tableView, indexPath, item) in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TextViewCell
            cell.configureCell(item: TextViewCell.Input(viewModel: self.viewModel, data: item))
            return cell
        })
        
        viewModel.output.items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppearI.onNext(())
        
    }
}

extension ProfileEditController: UITableViewDelegate {
    
}
