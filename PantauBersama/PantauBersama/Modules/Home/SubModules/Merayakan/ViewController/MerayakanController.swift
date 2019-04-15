//
//  MerayakanController.swift
//  PantauBersama
//
//  Created by asharijuang on 14/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class MerayakanController: UIViewController {

    @IBOutlet weak var segmentedControl: SegementedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navbar: Navbar!
    var viewModel: MerayakanViewModel!
    
    lazy var rekapViewModel = RekapViewModel(navigator: viewModel.navigator)
    lazy var perhitunganViewModel = PerhitunganViewModel(navigator: viewModel.navigator)
    private lazy var rekapController = RekapController(viewModel: rekapViewModel, pageType: .kota)
    private lazy var perhitunganController = PerhitunganController(viewModel: perhitunganViewModel)
    
    private let disposeBag = DisposeBag()
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.sizeToFit()
        return search
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navbar.backgroundColor = Color.primary_red

        add(childViewController: perhitunganController, context: container)
        add(childViewController: rekapController, context: container)
        
        // MARK
        // segmented control value
        // assign extension Reactive UIControl
        segmentedControl.rx.value
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] i in
                UIView.animate(withDuration: 0.3, animations: {
                    if i == 0 {
                        self.perhitunganController.view.alpha = 1.0
                        self.rekapController.view.alpha = 0.0
                    } else {
                        self.perhitunganController.view.alpha = 0.0
                        self.rekapController.view.alpha = 1.0
                    }
                })
            })
            .disposed(by: disposeBag)
        
        navbar.notification.rx.tap
            .bind(to: viewModel.input.notifTrigger)
            .disposed(by: disposeBag)
        
        navbar.profile.rx.tap
            .bind(to: viewModel.input.profileTrigger)
            .disposed(by: disposeBag)
        
        navbar.note.rx.tap
            .bind(to: viewModel.input.catatanTrigger)
            .disposed(by: disposeBag)
        
        navbar.search.rx.tap
            .bind(to: viewModel.input.searchTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.notifSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.profileSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.catatanSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.searchSelected
            .drive()
            .disposed(by: disposeBag)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
//        viewModel.input.viewWillAppearTrigger.onNext(())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.navigationBar.isHidden = false
    }

}
