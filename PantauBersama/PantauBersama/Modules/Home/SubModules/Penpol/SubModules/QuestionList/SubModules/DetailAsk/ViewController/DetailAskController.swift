//
//  DetailAskController.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 22/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Lottie
import Networking

class DetailAskController: UIViewController {
    
    @IBOutlet weak var buttonClose: ImageButton!
    @IBOutlet weak var lottieFrame: UIView!
    @IBOutlet weak var btnVote: UIButton!
    @IBOutlet weak var lblVote: Label!
    @IBOutlet weak var avatar: CircularUIImageView!
    @IBOutlet weak var lblName: Label!
    @IBOutlet weak var lblStatus: Label!
    @IBOutlet weak var lblTime: Label!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var btnShare: ImageButton!
    @IBOutlet weak var btnMore: ImageButton!
    
    var viewModel: DetailAskViewModel!
    private var data: Question!
    private let disposeBag: DisposeBag = DisposeBag()
    
    lazy private var voteAnimation: LOTAnimationView = {
        let voteAnimation = LOTAnimationView(name: "upvote")
        voteAnimation.translatesAutoresizingMaskIntoConstraints = false
        voteAnimation.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        voteAnimation.contentMode = .center
        voteAnimation.frame = lottieFrame.bounds
        voteAnimation.loopAnimation = false
        
        return voteAnimation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLottie()
        
        buttonClose.rx.tap
            .bind(to: viewModel.input.backI)
            .disposed(by: disposeBag)
        
        btnMore.rx.tap
            .map({ self.data })
            .bind(to: viewModel.input.moreI)
            .disposed(by: disposeBag)
        
        btnShare.rx.tap
            .map({ self.data })
            .bind(to: viewModel.input.shareI)
            .disposed(by: disposeBag)
        
        btnVote.rx.tap
            .map({ self.data })
            .bind(onNext: { [weak self] (question) in
                guard let question = question else { return }
                if question.isLiked {
                    self?.voteAnimation.play(fromProgress: 1, toProgress: 0, withCompletion: { (finished) in
                        if finished {
                            self?.viewModel.input.unvoteI.onNext((question))
                            self?.lblVote.text = "\(question.likeCount - 1)"
                        }
                    })
                } else {
                    self?.voteAnimation.play(completion: { (finished) in
                        if finished {
                            self?.viewModel.input.voteI.onNext((question))
                            self?.lblVote.text = "\(question.likeCount + 1)"
                        }
                    })
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.voteO
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.voteTriggerI.onNext(())
            })
            .drive()
            .disposed(by: disposeBag)

        viewModel.output.unvoteO
            .do(onNext: { [weak self] (_) in
                self?.viewModel.input.voteTriggerI.onNext(())
            })
            .drive()
            .disposed(by: disposeBag)
        
        
        viewModel.output.itemsO
            .do(onNext: { [unowned self] (question) in
                if let thumbnail = question.user.avatar.thumbnail.url {
                    self.avatar.af_setImage(withURL: URL(string: thumbnail)!)
                }
                self.lblTime.text = question.createdAtInWord.id
                self.lblName.text = question.user.fullName
                self.lblStatus.text = question.user.about
                self.lblContent.text = question.body
                self.lblVote.text = "\(question.likeCount)"
                self.data = question
                if question.isLiked {
                    self.voteAnimation.play(fromProgress: 1, toProgress: 1, withCompletion: nil)
                }
            })
            .drive()
            .disposed(by: disposeBag)
        
      
        viewModel.output.moreO
            .asObservable()
            .flatMapLatest { [weak self] (question) -> Observable<QuestionSingleType> in
                return Observable.create({ (observer) -> Disposable in
                    let myId = AppState.local()?.user.id
                    let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                    let hapus = UIAlertAction(title: "Hapus", style: .default, handler: { (_) in
                        observer.onNext(QuestionSingleType.hapus(question: question))
                        observer.on(.completed)
                    })
                    let salin = UIAlertAction(title: "Salin Tautan", style: .default, handler: { (_) in
                        observer.onNext(QuestionSingleType.salin(question: question))
                        observer.on(.completed)
                    })
                    let bagikan = UIAlertAction(title: "Bagikan", style: .default, handler: { (_) in
                        observer.onNext(QuestionSingleType.bagikan(question: question))
                        observer.on(.completed)
                    })
                    let laporkan = UIAlertAction(title: "Laporkan Sebagai Spam", style: .default, handler: { (_) in
                        observer.onNext(QuestionSingleType.laporkan(question: question))
                        observer.on(.completed)
                    })
                    let cancel = UIAlertAction(title: "Batal", style: .cancel, handler: nil)
                    
                    if myId == question.user.id {
                        alert.addAction(hapus)
                    }
                    
                    alert.addAction(salin)
                    alert.addAction(bagikan)
                    alert.addAction(laporkan)
                    alert.addAction(cancel)
                    DispatchQueue.main.async {
                        self?.navigationController?.present(alert, animated: true, completion: nil)
                    }
                    return Disposables.create()
                })
            }
            .bind(to: viewModel.input.moreMenuI)
            .disposed(by: disposeBag)
        
        viewModel.output.moreMenuO
            .filter { !$0.isEmpty }
            .drive(onNext: { (message) in
                UIAlertController.showAlert(withTitle: "", andMessage: message)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.shareO
            .drive()
            .disposed(by: disposeBag)
    }
    
    private func configureLottie() {
        lottieFrame.insertSubview(voteAnimation, at: 0)
        NSLayoutConstraint.activate([
            voteAnimation.topAnchor.constraint(equalTo: lottieFrame.topAnchor),
            voteAnimation.leadingAnchor.constraint(equalTo: lottieFrame.leadingAnchor),
            voteAnimation.bottomAnchor.constraint(equalTo: lottieFrame.bottomAnchor),
            voteAnimation.trailingAnchor.constraint(equalTo: lottieFrame.trailingAnchor)
            ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.input.viewWillAppearI.onNext(())
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
}
