//
//  QuizOngoingController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 21/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxCocoa
import RxSwift

class QuizOngoingController: UIViewController {
    @IBOutlet weak var btnAChoice: Button!
    @IBOutlet weak var btnBChoice: Button!
    @IBOutlet weak var tvBChoice: UITextView!
    @IBOutlet weak var tvAChoice: UITextView!
    @IBOutlet weak var lbQuestion: Label!
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var lbQuestionIndex: Label!
    @IBOutlet weak var btnBack: ImageButton!
    
    private(set) var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnBack.rx.tap.bind(onNext: { [unowned self] in
            // TODO: move navigation to coordinator later when data available
            self.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
