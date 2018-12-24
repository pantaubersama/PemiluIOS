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
        
        // dummy
        buttonOke.addTarget(self, action: #selector(handleTap(sender:)), for: .touchUpInside)
    }
    
    @objc private func handleTap(sender: UIButton) {
        let vc = SelfIdentitasController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
