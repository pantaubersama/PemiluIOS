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
import Networking

class PartyCaraouselCell: UITableViewCell {
    
    @IBOutlet weak var contentPager: FSPagerView!
    private var data: [PoliticalParty] = []
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
        return data.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if let image = data[index].image.url {
            cell.imageView?.show(fromURL: image)
        }
        return cell
    }
    
}

extension PartyCaraouselCell: IReusableCell {
    
    struct Input {
        let viewModel: CatatanViewModel
    }
    
    func configureCell(item: Input) {
        let data = item.viewModel.partyItems.value
        DispatchQueue.main.async {
            self.data = data
            self.contentPager.reloadData()
        }
    }
}
