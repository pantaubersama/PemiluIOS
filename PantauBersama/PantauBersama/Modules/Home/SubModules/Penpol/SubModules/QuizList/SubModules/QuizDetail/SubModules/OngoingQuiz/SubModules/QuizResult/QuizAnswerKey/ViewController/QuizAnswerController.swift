//
//  QuizAnswerController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 24/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class QuizAnswerController: UIViewController {
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: Button!
    
    private(set) var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(QuizAnswerKeyCell.self)
        
        // TODO: Move navigation to coordinator later
        btnClose.rx.tap.bind(onNext: { [unowned self]_ in
            self.dismiss(animated: true, completion: nil)
        }).disposed(by: disposeBag)
    }
    
    
}

extension QuizAnswerController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 187
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as QuizAnswerKeyCell
        return cell
    }
    
    
}

extension QuizAnswerController: UITableViewDelegate {
    
}
