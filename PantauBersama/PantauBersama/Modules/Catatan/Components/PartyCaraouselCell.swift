//
//  PartyCaraouselCell.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 27/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import FSPagerView
import Common

class PartyCaraouselCell: UITableViewCell {
    
    @IBOutlet weak var contentPager: FSPagerView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentPager.delegate = self
        contentPager.dataSource = self
        contentPager.transformer = FSPagerViewTransformer.init(type: .linear)
        self.contentPager.itemSize = CGSize(width: 275.0, height: 265.0)
        contentPager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}

extension PartyCaraouselCell: FSPagerViewDelegate, FSPagerViewDataSource {
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return 20
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        cell.imageView?.image = UIImage(named: "caraousel_prabowo")
        return cell
    }
    
}

extension PartyCaraouselCell: IReusableCell {
    
    struct Input {
        
    }
    
    func configureCell(item: Input) {
        
    }
}
