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

class PaslonCaraouselCell: UITableViewCell {
    
    @IBOutlet weak var contentPager: FSPagerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        configurePager()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

extension PaslonCaraouselCell: FSPagerViewDelegate, FSPagerViewDataSource {
    
    private func configurePager() {
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
}

extension PaslonCaraouselCell: IReusableCell {
    
    struct Input {
        let focus: Int
    }
    
    func configureCell(item: Input) {
        DispatchQueue.main.async {
            self.contentPager.scrollToItem(at: item.focus, animated: true)
            self.contentPager.reloadData()
        }
    }
}
