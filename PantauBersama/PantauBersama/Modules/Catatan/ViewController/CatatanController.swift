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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var btnUpdate: Button!
    @IBOutlet weak var container: UIView!
    
    lazy var catatanPilpresViewModel = CatatanPilpresViewModel()
    lazy var catatanPartyViewModel = CatatanPartyViewModel()
    
    private lazy var catatanPilpresController = CatatanPilpresController(viewModel: catatanPilpresViewModel)
    private lazy var catatanPartyController = CatatanPartyController(viewModel: catatanPartyViewModel)
    
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.configure(with: .white)
        title = "Catatan Pilihanku"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnUpdate.rx.tap
            .bind(to: viewModel.input.updateI)
            .disposed(by: disposeBag)
    
        add(childViewController: catatanPilpresController, context: container)
        add(childViewController: catatanPartyController, context: container)
        
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.catatanPilpresController.view.alpha = 1.0
                        self.catatanPartyController.view.alpha = 0.0
                        let values = self.catatanPilpresController.viewModel.output.notePreferenceValueO
                        values.do(onNext: { [weak self] (value) in
                            self?.viewModel.input.notePreferenceValueI.onNext((value))
                        })
                        .drive()
                        .disposed(by: self.disposeBag)
                    } else {
                        self.catatanPilpresController.view.alpha = 0.0
                        self.catatanPartyController.view.alpha = 1.0
                        let values = self.catatanPartyViewModel.output.notPreferenceO
                        values.do(onNext: { [weak self] (s) in
                            self?.viewModel.input.partyPreferenceValueI.onNext((s))
                        })
                        .drive()
                        .disposed(by: self.disposeBag)
                    }
                })
            })
            .disposed(by: disposeBag)
        
        viewModel.output.enableO
            .do(onNext: { [weak self] (enable) in
                guard let `self` = self else { return }
                self.btnUpdate.backgroundColor = enable ? Color.primary_red : Color.grey_one
            })
            .drive(btnUpdate.rx.isEnabled)
            .disposed(by: disposeBag)
        
       viewModel.output.updateO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}
