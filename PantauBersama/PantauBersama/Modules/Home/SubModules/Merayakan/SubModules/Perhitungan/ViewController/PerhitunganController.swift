//
//  PerhitunganController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class PerhitunganController: UITableViewController {
    private lazy var headerView =  BannerHeaderView()
    private lazy var btnCreate: UIButton = {
       let btn = UIButton()
        btn.adjustsImageWhenHighlighted = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "icCreate"), for: .normal)
        
        return btn
    }()
    
    private var viewModel: PerhitunganViewModel!
    private let disposeBag = DisposeBag()
    
    convenience init(viewModel: PerhitunganViewModel) {
        self.init()
        self.viewModel = viewModel
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(btnCreate)
        configureConstraint()
        tableView.registerReusableCell(PerhitunganCell.self)
        tableView.tableHeaderView = headerView
        
        btnCreate.rx.tap
            .bind(to: viewModel.input.createPerhitunganI)
            .disposed(by: disposeBag)
        
        viewModel.output.createPerhitunganO
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func configureConstraint() {
        if #available(iOS 11.0, *) {
            NSLayoutConstraint.activate([
                btnCreate.heightAnchor.constraint(equalToConstant: 60),
                btnCreate.widthAnchor.constraint(equalToConstant: 60),
                btnCreate.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                btnCreate.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20)
                ])
        } else {
            // Fallback on earlier versions
            NSLayoutConstraint.activate([
                btnCreate.heightAnchor.constraint(equalToConstant: 60),
                btnCreate.widthAnchor.constraint(equalToConstant: 60),
                btnCreate.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20),
                btnCreate.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 20)
                ])
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 168
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as PerhitunganCell
        
        return cell
    }

}
