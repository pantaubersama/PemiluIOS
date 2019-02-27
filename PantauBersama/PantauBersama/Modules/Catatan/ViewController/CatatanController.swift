//
//  CatatanController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 04/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common

class CatatanController: UIViewController {
    
    var viewModel: CatatanViewModel!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.configure(with: .white)
        title = "Catatan Pilihanku"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        
        // MARK
        // Register tableview
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.registerReusableCell(PaslonCaraouselCell.self)
        
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
//        viewModel.output.enableO
//            .do(onNext: { [weak self] (enable) in
//                guard let `self` = self else { return }
//                self.btnUpdate.backgroundColor = enable ? Color.primary_red : Color.grey_one
//            })
//            .drive(btnUpdate.rx.isEnabled)
//            .disposed(by: disposeBag)
        
       viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}

extension CatatanController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell() as PaslonCaraouselCell
            return cell
        case 1:
            let cell = UITableViewCell()
            cell.backgroundColor = Color.blue
            return cell
        default:
            let cell = UITableViewCell()
            return cell
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350.0 // case for sreen iphone 6s
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let view = HeaderCatatanView()
            view.lblContent.text = "Siapakah yang saat ini cocok dengan pilihan kamu?"
            return view
        case 1:
            let view = HeaderCatatanView()
            view.lblContent.text = "Partai mana yang cocok dengan pilihan kamu?"
            return view
        default:
            let view = UIView()
            return view
        }
    }
}
