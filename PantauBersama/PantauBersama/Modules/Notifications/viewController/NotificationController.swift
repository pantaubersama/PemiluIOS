//
//  NotificationController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 28/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class NotificationController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var context: UIView!
    
    var viewModel: NotificationViewModel!
    
    lazy var infoNotifViewModel: InfoNotifViewModel = InfoNotifViewModel(navigator: viewModel.navigator)
    
    private lazy var infoNotifController = InfoNotifController(viewModel: infoNotifViewModel)
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notifikasi"
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        add(childViewController: infoNotifController, context: context)
        
        
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (i) in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.infoNotifController.view.alpha = 1.0
                    } else {
                        self.infoNotifController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
        
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        
        viewModel.output.backO
            .drive()
            .disposed(by: disposeBag)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.configure(with: .white)
    }
    
}
