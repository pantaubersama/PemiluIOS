//
//  SettingController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import RxDataSources
import TwitterKit
import FBSDKLoginKit
import Networking

class SettingController: UITableViewController {
    
    var viewModel: ISettingViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfSettingData>!
    var data: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Setting"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        
        // MARK:- TableViews
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 44.0
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(SettingCell.self)
        tableView.tableFooterView = UIView()
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfSettingData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
                let cell = tableView.dequeueReusableCell(indexPath: indexPath) as SettingCell
                cell.configureCell(item: SettingCell.Input(data: item))
                return cell
            })
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        tableView.rx.itemSelected
            .do(onNext: { (indexPath) in
                switch indexPath.section {
                case 2:
                    let manager: FBSDKLoginManager = FBSDKLoginManager()
                    manager.logIn(withReadPermissions:  ["public_profile", "email"],
                                  from: self, handler: { [weak self] (result, error) in
                        if let error = error {
                            print(error.localizedDescription)
                            return
                        }
                        self?.viewModel.input.facebookI.onNext((result))
                    })
                    
                default: break
                }
            })
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.itemSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemTwitterO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookMeO
            .do(onNext: { (n,_,_,_,_) in
                if let username = n {
                    UserDefaults.Account.set("Connected as \(username)", forKey: .usernameFacebook)
                }
            })
            .drive()
            .disposed(by: disposeBag)
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
        viewModel.input.viewWillAppearTrigger.onNext(())
        viewModel.input.viewControllerTrigger.onNext((self.presentedViewController))
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension SettingController {
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return dataSource.sectionModels[section].header != nil ? 48.0 : 2.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionCell()
        view.button.isHidden = true
        view.label.text = dataSource.sectionModels[section].header
        return view
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.groupTableViewBackground
        return view
    }
}
