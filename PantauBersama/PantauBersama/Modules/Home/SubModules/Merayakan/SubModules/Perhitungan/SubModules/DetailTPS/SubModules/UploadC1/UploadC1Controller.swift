//
//  UploadC1Controller.swift
//  PantauBersama
//
//  Created by Nanang Rafsanjani on 04/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class UploadC1Controller: UIViewController {
    var viewModel: UploadC1ViewModel!
    
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var header = UIView.nib(withType: UploadC1Header.self)
    
    var titles = [
        "1. Model C1-PPWP (Presiden)",
        "2. Model C1-DPR RI",
        "3. Model C1-DPD",
        "4. Model C1-DPRD Provinsi",
        "5. Model C1-DPRD Kabupaten/Kota",
        "6. Suasana TPS"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Upload"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        tableView.setTableHeaderView(headerView: header)
        tableView.registerReusableCell(C1PhotoCell.self)
        tableView.registerReusableHeaderCell(C1PhotoHeader.self)
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.updateHeaderViewFrame()
    }
}

extension UploadC1Controller: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooter() as C1PhotoHeader
        header.lblTitle.text = titles[section]
        return header
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = Color.grey_one
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell() as C1PhotoCell
        return cell
    }
}
