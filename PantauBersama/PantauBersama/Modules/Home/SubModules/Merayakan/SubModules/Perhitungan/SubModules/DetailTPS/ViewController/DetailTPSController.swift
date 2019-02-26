//
//  DetailTPSController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma Setya Putra on 26/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class DetailTPSController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnAction: Button!
    
    var viewModel: DetailTPSViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.registerReusableCell(DetailTPSCell.self)

        title = "Perhitungan"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnAction.rx.tap
            .bind(to: viewModel.input.sendDataActionI)
            .disposed(by: disposeBag)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.sendDataActionO
            .drive()
            .disposed(by: disposeBag)
    }
}

extension DetailTPSController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as DetailTPSCell
        cell.configureCell(item: DetailTPSCell.Input(viewModel: self.viewModel))
        
        return cell
    }
}
