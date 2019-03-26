//
//  QuizNode.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 26/03/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Common
import AsyncDisplayKit
import RxSwift
import RxCocoa

class QuizNode: ASCellNode {
    
    private(set) var disposeBag = DisposeBag()
    
    struct Attributes {
        static let placeholderColor: UIColor = UIColor.gray.withAlphaComponent(0.8)
    }
    
    lazy var quizImageNode: ASNetworkImageNode = {
       let node = ASNetworkImageNode()
        node.placeholderColor = Attributes.placeholderColor
        node.placeholderEnabled = true
        node.style.alignSelf = .center
        node.style.height = ASDimensionMake(212)
        node.style.flexGrow = 1.0
        node.style.flexShrink = 1.0
        return node
    }()
    
    lazy var titleQuizNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        return node
    }()
    
    lazy var subtitleQuizNode: ASTextNode = {
       let node = ASTextNode()
        node.placeholderEnabled = true
        node.placeholderColor = Attributes.placeholderColor
        return node
    }()
    
    lazy var buttonQuizNode: ASButtonNode = {
       let node = ASButtonNode()
        node.placeholderEnabled = true
        node.style.preferredSize = CGSize(width: 72.8, height: 24.0)
        node.cornerRadius = 4
        node.style.alignSelf = .start
        return node
    }()
    
    lazy var buttonShareNode: ASButtonNode = {
       let node = ASButtonNode()
        node.placeholderEnabled = true
        node.setImage(#imageLiteral(resourceName: "icShare"), for: .normal)
        node.style.alignSelf = .end
        node.style.preferredSize = CGSize(width: 24.0, height: 24.0)
        return node
    }()
    
    init(item: Input) {
        super.init()
        let bag = DisposeBag()
        self.backgroundColor = .white
        self.automaticallyManagesSubnodes = true
        self.selectionStyle = .none
        
        quizImageNode.setURL(URL(string: item.quiz.image.url), resetToDefault: true)
        titleQuizNode.attributedText =
            NSAttributedString(string: item.quiz.title,
              attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 0, green: 0, blue: 0),
                           NSAttributedString.Key.font: UIFont.init(name: "BwModelicaSS01-BoldCondensed", size: 16)!])
        
        subtitleQuizNode.attributedText =
            NSAttributedString(string: item.quiz.subtitle,
                               attributes: [NSAttributedString.Key.foregroundColor: Color.RGBColor(red: 0, green: 0, blue: 0),
                                            NSAttributedString.Key.font: UIFont.init(name: "BwModelica-ThinCondensed", size: 12)!])
        
        setState(state: item.quiz.participationStatus)
        
        buttonQuizNode.rx.tapper()
            .map({ item.quiz })
            .bind(to: item.viewModel.input.openQuizTrigger)
            .disposed(by: bag)
        
        buttonShareNode.rx.tapper()
            .map({ item.quiz })
            .bind(to: item.viewModel.input.shareTrigger)
            .disposed(by: bag)
        
        
        disposeBag = bag
    }

}

extension QuizNode {
    
    struct Input {
        let viewModel: QuizViewModel
        let quiz: QuizModel
    }
    
    func setState(state: QuizModel.QuizStatus) {
        switch state {
        case .notParticipating:
            self.buttonQuizNode.setTitle("IKUTI >>", with: UIFont.init(name: "Lato-Bold", size: 12), with: Color.primary_white, for: .normal)
            self.buttonQuizNode.backgroundColor = #colorLiteral(red: 0.9510135055, green: 0.4663162827, blue: 0.1120762601, alpha: 1)
            break
        case .inProgress:
            self.buttonQuizNode.setTitle("LANJUT >>", with: UIFont.init(name: "Lato-Bold", size: 12), with: Color.primary_white, for: .normal)
            self.buttonQuizNode.backgroundColor = #colorLiteral(red: 0.9195427895, green: 0.1901296675, blue: 0.2161853909, alpha: 1)
            break
        case .finished:
            self.buttonQuizNode.setTitle("HASIL >>", with: UIFont.init(name: "Lato-Bold", size: 12), with: Color.primary_white, for: .normal)
            self.buttonQuizNode.backgroundColor = #colorLiteral(red: 0.01680011675, green: 0.7413030267, blue: 0.6572044492, alpha: 1)
            break
        }
        self.buttonQuizNode.layoutIfNeeded()
    }
    
}

extension QuizNode {
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        /// Footer spec contains: Button Quiz and Share
        let footerSpec = ASStackLayoutSpec(direction: .horizontal,
                                           spacing: 1.0,
                                           justifyContent: .spaceBetween,
                                           alignItems: .notSet,
                                           children: [buttonQuizNode, buttonShareNode])
        footerSpec.style.flexGrow = 1.0
        footerSpec.style.flexShrink = 1.0
        /// Content vertical stack, contains: Image, title, subtitle, and footer
        let contentVerticalStack = ASStackLayoutSpec(direction: .vertical,
                                                     spacing: 6.0,
                                                     justifyContent: .start,
                                                     alignItems: .stretch,
                                                     children: [quizImageNode, titleQuizNode, subtitleQuizNode, footerSpec])
        /// Set flexGrow and flexShrink for content
        contentVerticalStack.style.flexGrow = 1.0
        contentVerticalStack.style.flexShrink = 1.0
        /// Create inset for ASInsetLayoutSpec
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0), child: contentVerticalStack)
        
    }
    
    
}
