//
//  OpenChallengeController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 12/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import RxDataSources

class OpenChallengeController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnNext: ImageButton!
    private let disposeBag = DisposeBag()
    
    var dataSource: RxTableViewSectionedReloadDataSource<SectionOfTantanganData>!
    
    var viewModel: OpenChallengeViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Open challenge"
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        tableView.estimatedRowHeight = 77.0
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.registerReusableCell(TantanganCell.self)
        tableView.tableHeaderView = HeaderTantanganView()
        tableView.separatorInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        
        
        dataSource = RxTableViewSectionedReloadDataSource<SectionOfTantanganData>(configureCell: { (dataSource, tableView, indexPath, item) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(indexPath: indexPath) as TantanganCell
            cell.configureCell(item: TantanganCell.Input(data: item, active: dataSource.sectionModels.first?.isActive ?? false))
            
            return cell
        })
        
    
        viewModel.output.itemsO
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
        
        viewModel.input.kajianI.onNext(false)
    }
    
}
