//
//  IdentitasController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class IdentitasController: UIViewController {
    
    @IBOutlet weak var textFieldKTP: TextField!
    @IBOutlet weak var buttonOke: Button!
    
    var viewModel: IIdentitasViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        navigationController?.navigationBar.configure(with: .white)
        
        back.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        textFieldKTP.rx.text.orEmpty
            .bind(to: viewModel.input.newKTPInput)
            .disposed(by: disposeBag)
        
        buttonOke.rx.tap
            .bind(to: viewModel.input.nextTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.enable
            .do(onNext: { [weak self](enable) in
                self?.buttonOke.backgroundColor = enable ? Color.primary_red : Color.grey_three
            })
            .drive(buttonOke.rx.isEnabled)
            .disposed(by: disposeBag)
        
        viewModel.output.errorTrackerO
            .drive(onNext: { [weak self] (e) in
                guard let alert = UIAlertController.alert(with: e) else { return }
                self?.navigationController?.present(alert, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.changeO
            .drive()
            .disposed(by: disposeBag)
    }
}
