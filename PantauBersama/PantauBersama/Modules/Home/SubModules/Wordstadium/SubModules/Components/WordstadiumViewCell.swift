//
//  WordstadiumViewCell.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 13/02/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import UIKit
import Common
import RxSwift
import RxCocoa

class WordstadiumViewCell: UITableViewCell{

    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleIv: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    
    private var collectionType : ItemType!
    private var items : [Wordstadium]!
    
    private var disposeBag : DisposeBag?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.collectionView.registerReusableCell(WordstadiumCollectionCell.self)
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        disposeBag = nil
    }
    
    
}

extension WordstadiumViewCell: IReusableCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    struct Input {
        let type : ItemType
        let wordstadium: SectionWordstadium
        let viewModel : WordstadiumCellViewModel
    }
    
    func configureCell(item: Input) {
        self.collectionType = item.type
        self.items = item.wordstadium.itemsLive
        
        switch item.type {
        case .live:
            self.titleLbl.text = "Live Now"
            self.titleIv.image = UIImage(named: "icWordLive")
        case .inProgress:
            self.titleLbl.text = "Challenge in Progress"
            self.titleIv.image = UIImage(named: "icWordChallange")
        default: break
        }
        
        let bag = DisposeBag()
        
        seeMoreBtn.rx.tap
            .map({ item.wordstadium })
            .bind(to: item.viewModel.input.moreSelected)
            .disposed(by: bag)
        
        disposeBag = bag
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection = collectionView.dequeueReusableCell(indexPath: indexPath) as WordstadiumCollectionCell
        collection.configureCell(item: WordstadiumCollectionCell.Input(type: self.collectionType))
        return collection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 280.0, height: 180.0)
    }
}
