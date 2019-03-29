//
//  PaslonCaraouselCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 27/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import FSPagerView
import RxSwift
import RxCocoa
import Networking

class PaslonCaraouselCell: UITableViewCell {
    
    @IBOutlet weak var contentPager: FSPagerView!
    @IBOutlet weak var ivAvatarPreference: CircularUIImageView!
    @IBOutlet weak var lblPreferenceQuiz: Label!
    @IBOutlet weak var lblPreferenceUser: Label!
    @IBOutlet weak var lblPreferenceResult: UILabel!
    
    private var focusTarget: Int? = nil
    private var viewModel: CatatanViewModel!
    private(set) var disposeBag: DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configurePager()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
    }
    
}

extension PaslonCaraouselCell: FSPagerViewDelegate, FSPagerViewDataSource {
    
    private func configurePager() {
        contentPager.alpha = 0.0
        contentPager.delegate = self
        contentPager.dataSource = self
        contentPager.transformer = FSPagerViewTransformer.init(type: .linear)
        contentPager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.contentPager.decelerationDistance = FSPagerView.automaticDistance
        self.contentPager.itemSize = CGSize(width: 275.0, height: 265.0)
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 3
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        switch index {
        case 0:
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: 0)
            cell.imageView?.image = UIImage(named: "caraousel_not")
            return cell
        case 1:
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: 1)
            cell.imageView?.image = UIImage(named: "caraousel_jokowi")
            return cell
        case 2:
            let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: 2)
            cell.imageView?.image = UIImage(named: "caraousel_prabowo")
            return cell
        default:
            let cell = FSPagerViewCell()
            return cell
        }
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        print("pager index: \(targetIndex)")
        switch targetIndex {
        case 0:
            viewModel.input.notePreferenceValueI.onNext(3)
        case 1:
            viewModel.input.notePreferenceValueI.onNext(1)
        case 2:
            viewModel.input.notePreferenceValueI.onNext(2)
        default:
            break
        }
    }
}

extension PaslonCaraouselCell: IReusableCell {
    
    struct Input {
        let focus: Int
        let viewModel: CatatanViewModel
        let preferenceQuiz: String
        let paslonUrl: String
        let preferenceUser: String
        let preference: String
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        DispatchQueue.main.async {
            self.viewModel = item.viewModel
            self.contentPager.reloadData()
            
            switch item.focus {
            case 3:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    UIView.animate(withDuration: 1.3, animations: {
                        self.contentPager.alpha = 1.0
                        self.contentPager.scrollToItem(at: 0, animated: true)
                    })
                })
            case 1:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    UIView.animate(withDuration: 1.3, animations: {
                        self.contentPager.alpha = 1.0
                        self.contentPager.scrollToItem(at: 1, animated: true)
                    })
                })
            case 2:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    UIView.animate(withDuration: 1.3, animations: {
                        self.contentPager.alpha = 1.0
                        self.contentPager.scrollToItem(at: 2, animated: true)
                    })
                })
            default:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    UIView.animate(withDuration: 1.3, animations: {
                        self.contentPager.alpha = 1.0
                        self.contentPager.scrollToItem(at: 0, animated: true)
                    })
                })
            }
        }
        
        self.ivAvatarPreference.show(fromURL: item.paslonUrl)
        self.lblPreferenceQuiz.text = item.preferenceQuiz
        self.lblPreferenceUser.text = item.preferenceUser
        self.lblPreferenceResult.text = item.preference
        
        disposeBag = bag
    }
}
