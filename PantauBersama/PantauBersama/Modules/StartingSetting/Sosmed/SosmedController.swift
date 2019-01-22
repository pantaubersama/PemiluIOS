//
//  SosmedController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 03/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Common
import FBSDKLoginKit

class SosmedController: UIViewController {
    
    @IBOutlet weak var btnSubmit: Button!
    @IBOutlet weak var tableView: UITableView!
    var viewModel: SosmedViewModel!
    private let disposeBag = DisposeBag()
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfSettingData>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Connect"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.rowHeight = 44.0
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(SettingCell.self)
        tableView.tableFooterView = UIView()
        tableView.refreshControl = UIRefreshControl()
        
        tableView.refreshControl?.rx.controlEvent(.valueChanged)
            .bind(to: viewModel.input.refreshI)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnSubmit.rx.tap
            .bind(to: viewModel.input.doneI)
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
            .do(onNext: { [weak self] (indexPath) in
                switch indexPath.section {
                case 1:
                    let manager: FBSDKLoginManager = FBSDKLoginManager()
                    manager.logIn(
                        withReadPermissions:  ["public_profile", "email"],
                        from: self, handler: { [weak self] (result, error) in
                            if error != nil {
                            }
                            guard let result = result else { return }
                            if result.isCancelled == true {
                                
                            } else {
                                guard let token = result.token.tokenString else { return }
                                self?.viewModel.input.facebookI.onNext((token))
                                self?.viewModel.input.facebookGraphI.onNext(())
                            }
                    })
                default: break
                }
            })
            .bind(to: viewModel.input.itemSelectedI)
            .disposed(by: disposeBag)
        
        viewModel.output.itemsO
            .do(onNext: { [weak self] (_) in
                self?.tableView.refreshControl?.endRefreshing()
            })
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        viewModel.output.doneO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.itemsSelectedO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.loadingO
            .drive(onNext: { [unowned self](loading) in
                self.tableView.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.facebookO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.facebookMeO
            .do(onNext: { [weak self] (n,_,_,_,_) in
                self?.tableView.refreshControl?.sendActions(for: .valueChanged)
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
        viewModel.input.viewWillAppearI.onNext(())
        viewModel.input.refreshI.onNext(())
    }
    
}

extension SosmedController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SectionCell()
        view.button.isHidden = true
        view.label.text = dataSource.sectionModels[section].header
        return view
    }
}
