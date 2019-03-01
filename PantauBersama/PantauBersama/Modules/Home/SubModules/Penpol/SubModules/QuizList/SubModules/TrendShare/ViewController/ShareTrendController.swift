//
//  ShareTrendController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 20/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Common
import Networking

class ShareTrendController: UIViewController {
    
    @IBOutlet weak var ivPaslon: CircularUIImageView!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var lblTeam: UILabel!
    @IBOutlet weak var share: Button!
    @IBOutlet weak var lblDesc: Label!
    @IBOutlet weak var lblSubDesc: Label!
    
    private var imageScreeenShoot: TrendImageShare = {
        let image = TrendImageShare()
        return image
    }()
    
    private var trendResponse: TrendResponse!
    
    var viewModel: ShareTrendViewModel!
    private let disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let back = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = back
        
        imageScreeenShoot = TrendImageShare()
        imageScreeenShoot.configureBackground(type: .trend)
        
        share.rx.tap
            .debounce(1.0, scheduler: MainScheduler.instance)
            .map({ self.takeScreenshot() })
            .bind(to: viewModel.input.shareI)
            .disposed(by: disposeBag)
        
        back.rx.tap
            .do(onNext: { [unowned self] (_) in
                self.navigationController?.popViewController(animated: true)
            })
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        viewModel.output.dataO
            .drive(onNext: { [weak self] (response) in
                guard let `self` = self else { return }
                  let kecenderungan = response.teams.max { $0.percentage?.isLess(than: $1.percentage ?? 0.0) ?? false }
                    if let avatarUrl = kecenderungan?.team.avatar {
                        self.ivPaslon.af_setImage(withURL: URL(string: avatarUrl)!)
                    }
                    self.lblDesc.text = "Total Kecenderunganmu \(response.meta.quizzes.finished) dari \(response.meta.quizzes.total) Quiz,"
                    self.lblSubDesc.text = "\(response.user.fullName ?? "") lebih suka jawaban dari Paslon no \(kecenderungan?.team.id ?? 0)"
                    let percentage = String(format: "%.0f", kecenderungan?.percentage ?? 0.0) + "%"
                    self.lblPercentage.text = percentage
                    self.lblTeam.text = "\(kecenderungan?.team.title ?? "")"
                
                    self.imageScreeenShoot.configure(data: response)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.shareO
            .drive()
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.configure(with: .transparent)
        self.navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        viewModel.input.viewWillAppearI.onNext(())
    }
    
}

extension ShareTrendController {
    
    
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
