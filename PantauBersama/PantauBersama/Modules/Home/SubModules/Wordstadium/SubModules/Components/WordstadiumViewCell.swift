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
import Networking

class WordstadiumViewCell: UITableViewCell{
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleIv: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var seeMoreBtn: UIButton!
    @IBOutlet weak var emptyView: UIView!
    
    private var challenges: [Challenge]!
    private var viewModel: ILiniWordstadiumViewModel!
    private var type: LiniType!
    
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
        titleIv.image = nil
        disposeBag = nil
    }
    
    
}

extension WordstadiumViewCell: IReusableCell,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    struct Input {
        let challenges: [Challenge]
        let viewModel : ILiniWordstadiumViewModel
        let sectionData: SectionWordstadium
    }
    
    func configureCell(item: Input) {
        self.viewModel = item.viewModel
        self.challenges = item.challenges
        self.type = item.sectionData.type
        
        self.titleLbl.text = item.sectionData.title
        
        switch item.sectionData.type {
        case .public:
            self.titleIv.image = UIImage(named: "icWordLive")
        case .personal:
            self.titleIv.image = UIImage(named: "icWordChallange")
        }
        
        self.emptyView.isHidden = item.challenges.count > 0
        self.seeMoreBtn.isHidden = !item.sectionData.seeMore
        
        let bag = DisposeBag()
        
        seeMoreBtn.rx.tap
            .map({ item.sectionData })
            .bind(to: item.viewModel.input.seeMoreI)
            .disposed(by: bag)
        
        self.collectionView.rx.itemSelected
            .map{(indexPath) in
                return self.challenges[indexPath.row]
            }
            .bind(to: item.viewModel.input.collectionSelectedI)
            .disposed(by: bag)
        
        disposeBag = bag
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.challenges.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collection = collectionView.dequeueReusableCell(indexPath: indexPath) as WordstadiumCollectionCell
        collection.configureCell(item: WordstadiumCollectionCell.Input(type: self.type, wordstadium: self.challenges[indexPath.row]))
        collection.moreMenuBtn.rx.tap
            .map({ self.challenges[indexPath.row] })
            .bind(to: self.viewModel.input.moreI)
            .disposed(by: self.disposeBag!)
        return collection
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: 280.0, height: 180.0)
    }
    
}
