//
//  JanjiPolitikViewController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 18/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Common
import Networking

class JanjiPolitikViewController: UITableViewController,IJanpolViewController {

    private var headerView: BannerHeaderView!
    internal let disposeBag = DisposeBag()
    private var emptyView = EmptyView()
    private var createBtn = UIButton()
    private var createIsHidden = true
    
    var viewModel: IJanpolListViewModel!
    internal lazy var rControl = UIRefreshControl()
    
    convenience init(viewModel: IJanpolListViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(LinimasaJanjiCell.self)
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
  
        
        tableView.tableFooterView = UIView()
        tableView.refreshControl = rControl
        
        self.buttonProperties()
        
        bind(tableView: tableView, refreshControl: rControl, emptyView: emptyView, with: viewModel)
        
        createBtn.rx.tap
            .bind(to: viewModel.input.createI)
            .disposed(by: disposeBag)
        
        viewModel.output.showHeaderO
            .drive(onNext: { [unowned self](isHeaderShown) in
                if isHeaderShown {
                    self.headerView = BannerHeaderView()
                    self.tableView.tableHeaderView = self.headerView
                    self.bind(headerView: self.headerView, with: self.viewModel)
                }
                self.createIsHidden = isHeaderShown
            }).disposed(by: disposeBag)
        
        viewModel.input.refreshI.onNext("")
        
        viewModel.output.createO
            .drive(onNext: { (response) in
                print("Create Janpol: \(response)")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    self.viewModel.input.refreshI.onNext("")
                })
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.userO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                let user = response.user
                self.createBtn.isHidden = !(user.cluster != nil && user.cluster?.isEligible == true && self.createIsHidden == true)
            })
            .disposed(by: disposeBag)

        
    }
    
    private func buttonProperties() {
        let image = UIImage(named: "icCreate") as UIImage?
        createBtn = UIButton.init(type: .custom)
        createBtn.setImage(image, for: .normal)
        createBtn.frame.size = CGSize(width: 60, height: 60)
        createBtn.isHidden = createIsHidden

        self.view.addSubview(createBtn)
        
        //set constrains
        createBtn.translatesAutoresizingMaskIntoConstraints = false
    
        if #available(iOS 11.0, *) {
            createBtn.rightAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.rightAnchor, constant: -20).isActive = true
            createBtn.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        } else {
            createBtn.rightAnchor.constraint(equalTo: tableView.layoutMarginsGuide.rightAnchor, constant: -20).isActive = true
            createBtn.bottomAnchor.constraint(equalTo: tableView.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.input.viewWillAppearI.onNext(())

    }
    
}

