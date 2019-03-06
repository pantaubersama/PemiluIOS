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
    var isFromDeeplink: Bool = false
    
    private(set) var disposeBag = DisposeBag()
    
    private var imageScreeenShoot: TrendImageShare = {
        let image = TrendImageShare()
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageScreeenShoot = TrendImageShare()
        imageScreeenShoot.configureBackground(type: .quiz)
        
        viewModel.output.result
            .drive(onNext: { [weak self](result) in
                guard let weakSelf = self else { return }
                weakSelf.lbPaslon.text = result.name
                weakSelf.lbPercent.text = result.percentage
                weakSelf.lbResult.text = result.resultSummary
                weakSelf.ivPaslon.show(fromURL: result.avatar)
                weakSelf.imageScreeenShoot.configureResult(data: result)
            }).disposed(by: disposeBag)
        
        viewModel.output.openSummary
            .drive()
            .disposed(by: disposeBag)
        
        viewModel.output.back
            .drive()
            .disposed(by: disposeBag)
        
        btnAnswerKey.rx.tap
            .bind(to: viewModel.input.openSummaryTrigger)
            .disposed(by: disposeBag)
        
        btnShare.rx.tap
            .debounce(1.0, scheduler: MainScheduler.instance)
            .map({ self.takeScreenshot() })
            .bind(to: viewModel.input.shareTrigger)
            .disposed(by: disposeBag)
        
        viewModel.output.share
            .drive()
            .disposed(by: disposeBag)
        
        
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        self.navigationItem.leftBarButtonItem = back
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        back.rx.tap
            .bind(to: viewModel.input.backTrigger)
            .disposed(by: disposeBag)
        
        if self.isFromDeeplink == true {
            self.btnShare.isHidden = true
            self.btnAnswerKey.isHidden = true
        } else {
            self.btnAnswerKey.isHidden = false
            self.btnShare.isHidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
}

extension QuizResultController {
    
    /// Takes the screenshot of the screen and returns the corresponding image
    /// - Returns: (Optional)image captured as a screenshot
    open func takeScreenshot() -> UIImage? {
        var screenshotImage :UIImage?
        let layer = self.imageScreeenShoot.layer
        let scale = UIScreen.main.scale
        let size = CGSize(width: 360, height: 640)
        UIGraphicsBeginImageContextWithOptions(size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshotImage
    }
    
}
