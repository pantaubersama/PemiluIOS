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

class QuizSummaryController: UIViewController {
    @IBOutlet weak var ivQuiz: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnClose: Button!
    
    private(set) var disposeBag = DisposeBag()
    var viewModel: QuizSummaryViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableView.automaticDimension
        tableView.registerReusableCell(QuizSummaryKeyCell.self)
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 211))
        header.backgroundColor = .clear
        tableView.tableHeaderView = header
        
        viewModel.output.answerKeys
            .drive(tableView.rx.items) { tableView, row, item -> UITableViewCell in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: QuizSummaryKeyCell.reuseIdentifier) as? QuizSummaryKeyCell else {
                    return UITableViewCell()
                }
                
                cell.tag = row
                cell.configureCell(item: QuizSummaryKeyCell.Input(question: item, order: row + 1))
                
                return cell
            }
            .disposed(by: disposeBag)
        
        viewModel.output.quiz
            .drive(onNext: { [unowned self]quizModel in
                self.ivQuiz.contentMode = .scaleAspectFill
                self.ivQuiz.show(fromURL: quizModel?.image.url ?? "")
            })
            .disposed(by: disposeBag)
        
        // TODO: Move navigation to coordinator later
        btnClose.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
    }
    
    
}
