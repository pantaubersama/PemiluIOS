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

class ProfileEditController: UITableViewController {
    
    var viewModel: ProfileEditViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfProfileInfoData>!
    
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
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorColor = UIColor.groupTableViewBackground
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.title
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfProfileInfoData>(configureCell: { (dataSource, tableView, indexPath, item) in
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

extension ProfileEditController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 140.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 47.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableHeaderView
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = tableFooterView
        return view
    }
}
