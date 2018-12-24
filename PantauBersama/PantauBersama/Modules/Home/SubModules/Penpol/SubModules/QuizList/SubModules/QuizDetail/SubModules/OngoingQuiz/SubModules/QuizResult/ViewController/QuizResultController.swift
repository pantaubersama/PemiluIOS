//
//  QuizResultController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 23/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizResultController: UIViewController {
    
    @IBOutlet weak var lbResult: Label!
    @IBOutlet weak var lbPercent: Label!
    @IBOutlet weak var lbPaslon: Label!
    @IBOutlet weak var btnShare: Button!
    @IBOutlet weak var btnAnswerKey: Button!
    @IBOutlet weak var ivPaslon: UIImageView!
    
    var viewModel: QuizResultViewModel!
    
    private(set) var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = back
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        
        // TODO: for mock only, move navigation to coordinator
        back.rx.tap
            .bind { [unowned self](_) in
                self.navigationController?.popViewController(animated: true)
            }.disposed(by: disposeBag)
        
        btnAnswerKey.rx.tap
            .bind(onNext: { [unowned self](_) in
                self.navigationController?.present(QuizAnswerController(), animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}
