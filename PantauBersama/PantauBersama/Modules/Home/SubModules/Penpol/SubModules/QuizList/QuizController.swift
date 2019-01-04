//
//  QuizController.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 20/12/18.
//  Copyright © 2018 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import AlamofireImage

class QuizController: UITableViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private var viewModel: QuizViewModel!
    
    convenience init(viewModel: QuizViewModel) {
        self.init()
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerReusableCell(QuizCell.self)
        tableView.registerReusableCell(TrendCell.self)
        tableView.registerReusableCell(BannerInfoQuizCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.separatorStyle = .none
        tableView.separatorColor = UIColor.groupTableViewBackground
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        viewModel.output.openQuizSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.infoSelected
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.shareSelected
            .drive()
            .disposed(by: disposeBag)
    }
}

extension QuizController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 2 ? 30 : 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 85
        case 1:
            return 148
        default:
            return 350
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let bannerCell = tableView.dequeueReusableCell(indexPath: indexPath) as BannerInfoQuizCell
            bannerCell.bind(viewModel: viewModel)
            return bannerCell
        case 1:
            let trendCell = tableView.dequeueReusableCell(indexPath: indexPath) as TrendCell
            trendCell.bind(viewModel: viewModel)
            return trendCell
        default:
            let quizCell = tableView.dequeueReusableCell(indexPath: indexPath) as QuizCell
            quizCell.quiz = "quiz"
            quizCell.bind(viewModel: viewModel)
//            quizCell.ivQuiz.af_setImage(withURL: <#T##URL#>)
            quizCell.ivQuiz.show(fromURL: "https://d1u5p3l4wpay3k.cloudfront.net/dota2_gamepedia/8/8a/Rubick_icon.png")
            return quizCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
