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
import RxSwift
import RxCocoa

class PartyCaraouselCell: UITableViewCell {
    
    @IBOutlet weak var contentPager: FSPagerView!
    private var data: [PoliticalParty] = []
    private var viewModel: CatatanViewModel!
    
    private(set) var disposeBag: DisposeBag!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentPager.alpha = 0.0
        contentPager.delegate = self
        contentPager.dataSource = self
        contentPager.transformer = FSPagerViewTransformer.init(type: .linear)
        switch UIScreen.main.bounds.height {
        case 568:
            self.contentPager.itemSize = CGSize(width: 250.0, height: 250.0)
        default:
            self.contentPager.itemSize = CGSize(width: 275.0, height: 265.0)
        }
        contentPager.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = nil
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
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        let data = self.data[targetIndex].id
        print("pager index data: \(data)")
        viewModel.input.partyPreferenceValueI.onNext(data)
    }
    
}

extension PartyCaraouselCell: IReusableCell {
    
    struct Input {
        let viewModel: CatatanViewModel
        let focus: Int
    }
    
    func configureCell(item: Input) {
        let bag = DisposeBag()
        self.viewModel = item.viewModel
        let data = item.viewModel.partyItems.value
        self.data = data
        DispatchQueue.main.async {
            self.contentPager.reloadData()
        }
        
        if self.data.count == 0 {
            // will wait until items is fully reloaded
        } else if self.data.count > 1 {
            // will wait time now() + 1 sec
            // to scroll content pager
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.contentPager.alpha = 0.0
                UIView.animate(withDuration: 2, animations: {
                    self.contentPager.alpha = 1.0
                    self.contentPager.scrollToItem(at: item.focus - 1, animated: true)
                })
            }
        }
        
        disposeBag = bag
    }
}
