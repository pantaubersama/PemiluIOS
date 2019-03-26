//
//  LinimasaNode.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import AsyncDisplayKit
import RxSwift
import RxCocoa
import Networking
import Common

class LinimasaNode: ASCellNode {
    
    private(set) var disposeBag = DisposeBag()
    
    struct Attributes {
        static let placeholderColor: UIColor = UIColor.gray.withAlphaComponent(0.8)
    }
    
    lazy var headerImageNode: ASNetworkImageNode = {
       let node = ASNetworkImageNode()
        node.clipsToBounds = true
        node.cornerRadius = 2
        node.style.preferredSize = CGSize(width: 12.0, height: 12.0)
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        node.borderColor = Color.primary_red.cgColor
        node.borderWidth = 1.0
        return node
    }()
    
    lazy var headerTextNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderColor = Attributes.placeholderColor
        node.placeholderEnabled = true
        return node
    }()
    
    lazy var profileImageNode: ASNetworkImageNode = {
       let node = ASNetworkImageNode()
        node.clipsToBounds = true
        node.placeholderColor = Attributes.placeholderColor
        node.placeholderEnabled = true
        node.style.preferredSize = CGSize(width: 40.0, height: 40.0)
        node.cornerRadius = 20.0
        return node
    }()
    
    lazy var statusProfileImageNode: ASImageNode = {
       let node = ASImageNode()
        node.image = #imageLiteral(resourceName: "icTwitterCircle")
        node.style.preferredSize = CGSize(width: 24.0, height: 24.0)
        return node
    }()
    
    lazy var nameProfileNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderColor = Attributes.placeholderColor
        node.placeholderEnabled = true
        return node
    }()
    
    lazy var usernameProfileNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        return node
    }()
    
    lazy var dateStatusNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        return node
    }()
    
    lazy var statusNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        node.automaticallyManagesSubnodes = true
        node.maximumNumberOfLines = 0
        return node
    }()
    
    lazy var statusImageNode: ASNetworkImageNode = {
       let node = ASNetworkImageNode()
        node.isHidden = true
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        node.cornerRadius = 5.0
        node.style.alignSelf = .center
        return node
    }()
    
    lazy var buttonNode: ASButtonNode = {
       let node = ASButtonNode()
        node.setImage(#imageLiteral(resourceName: "baselineMoreHorizBlack24Px"), for: .normal)
        node.style.preferredSize = CGSize(width: 20.0, height: 20.0)
        return node
    }()
    
    init(item: Input) {
        super.init()
        let bag = DisposeBag()
        self.backgroundColor = .white
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        
        nameProfileNode.attributedText = NSAttributedString(string: item.feeds.account.name,
            attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 0, green: 0, blue: 0),
                        NSAttributedString.Key.font: UIFont.init(name: "Lato-Bold", size: 12)!])
        
        let date = item.feeds.createdAtWord.id
        dateStatusNode.attributedText = NSAttributedString(string: "• \(date)",
            attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 124, green: 124, blue: 124),
                         NSAttributedString.Key.font: UIFont.init(name: "Lato-Bold", size: 12)!])
        
        usernameProfileNode.attributedText = NSAttributedString(string: "@\(item.feeds.account.username)",
            attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 124, green: 124, blue: 124),
                         NSAttributedString.Key.font: UIFont.init(name: "Lato-Bold", size: 12)!])
        
        statusNode.attributedText = NSAttributedString(string: item.feeds.source.text,
           attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 57, green: 57, blue: 57),
                        NSAttributedString.Key.font: UIFont.init(name: "Lato-Regular", size: 12)!])
        
        headerTextNode.attributedText = NSAttributedString(string: "Disematkan dari \(item.feeds.team.title)",
            attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 123, green: 123, blue: 123),
                         NSAttributedString.Key.font: UIFont.init(name: "Lato-Regular", size: 9)!])
        
        if let avatarURL = item.feeds.account.profileImageUrl {
            profileImageNode.setURL(URL(string: avatarURL)!, resetToDefault: true)
        }
        
        if let thumbnailURL = item.feeds.team.avatar {
            headerImageNode.setURL(URL(string: thumbnailURL)!, resetToDefault: true)
        }
        
        if let media = item.feeds.source.media?.first {
            statusImageNode.isHidden = false
            statusImageNode.setURL(URL(string: media), resetToDefault: true)
            statusImageNode.style.preferredSize = CGSize(width: 275.0, height: 154.7)
        }
        
        buttonNode.rx.tapper()
            .map({ item.feeds })
            .bind(to: item.viewModel.input.moreTrigger)
            .disposed(by: bag)
        
        disposeBag = bag
    }
}

extension LinimasaNode {
    
    struct Input {
        let viewModel: PilpresViewModel
        let feeds: Feeds
    }
    
}

extension LinimasaNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        /// Header stack spec contains name team and image team
        let headerStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                                spacing: 3.0,
                                                justifyContent: .start,
                                                alignItems: .center,
                                                children: [headerImageNode, headerTextNode])
        /// Profile with corner spec
        let profileCornerSpec = ASCornerLayoutSpec(child: profileImageNode,
                                                   corner: statusProfileImageNode,
                                                   location: .bottomLeft)
        profileCornerSpec.offset = CGPoint(x: 0, y: 0)
        
        let nameStackSpec = ASStackLayoutSpec(direction: .horizontal,
                                              spacing: 1.0,
                                              justifyContent: .start,
                                              alignItems: .start,
                                              children: [nameProfileNode, usernameProfileNode, dateStatusNode])
        /// content spec vertical
        let contentInnerSpec = ASStackLayoutSpec(direction: .vertical,
                                                 spacing: 3.0,
                                                 justifyContent: .start,
                                                 alignItems: .stretch,
                                                 children: [headerStackSpec, nameStackSpec, statusNode, statusImageNode])
        contentInnerSpec.style.flexGrow = 1.0
        contentInnerSpec.style.flexShrink = 1.0
        /// Inner content direction stack from horizontal
        let horizontalContentStack = ASStackLayoutSpec(direction: .horizontal,
                                                       spacing: 8.0,
                                                       justifyContent: .start,
                                                       alignItems: .start,
                                                       children: [profileCornerSpec, contentInnerSpec, buttonNode])
        
//        let verticalContentStack = ASStackLayoutSpec(direction: .vertical,
//                                                     spacing: 3.0,
//                                                     justifyContent: .start,
//                                                     alignItems: .start,
//                                                     children: [horizontalContentStack])
//        verticalContentStack.style.flexGrow = 1.0
//        verticalContentStack.style.flexShrink = 1.0
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0), child: horizontalContentStack)
        
    }
}
