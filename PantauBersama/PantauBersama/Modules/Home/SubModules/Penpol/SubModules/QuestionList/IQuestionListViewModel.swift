//
//  IQuestionListViewModel.swift
//  PantauBersama
//
//  Created by wisnu bhakti on 14/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Networking
import Common

protocol IQuestionListViewModelInput {
    var refreshI: AnyObserver<Void> { get }
    var nextPageI: AnyObserver<Void> { get }
    var shareQuestionI: AnyObserver<QuestionModel> { get }
    var moreI: AnyObserver<QuestionModel> { get }
    var moreMenuI: AnyObserver<QuestionType> { get }
    var voteI: AnyObserver<QuestionModel> { get }
    var filterI: AnyObserver<[PenpolFilterModel.FilterItem]> {get}
    var createI: AnyObserver<Void> {get}
}

protocol IQuestionListViewModelOutput {
    var items: Driver<[ICellConfigurator]>! { get }
    var error: Driver<Error>! { get }
    var moreSelectedO: Driver<QuestionModel>! { get }
    var moreMenuSelectedO: Driver<String>! { get }
    var shareSelectedO: Driver<Void>! { get }
    var filterO: Driver<Void>! { get }
    var bannerO: Driver<BannerInfo>! { get }
    var bannerSelectedO: Driver<Void>! { get }
    var userDataO: Driver<UserResponse?>! { get }
    var deleteO: Driver<Int>! { get }
    var createO: Driver<Void>! { get }
    var showHeaderO: Driver<Bool>! { get }
}

protocol IQuestionListViewModel {
    var input: IQuestionListViewModelInput { get }
    var output: IQuestionListViewModelOutput { get }
    
    var errorTracker: ErrorTracker { get }
    var activityIndicator: ActivityIndicator { get }
    var headerViewModel: BannerHeaderViewModel { get }
    
    func transformToPage(response: QuestionsResponse, batch: Batch) -> Page<[QuestionModel]>
    func paginateItems(batch: Batch ,nextBatchTrigger: Observable<Void>, filteredBy: String, orderedBy: String) -> Observable<[QuestionModel]>
    func recursivelyPaginateItems(batch: Batch ,nextBatchTrigger: Observable<Void>, filteredBy: String, orderedBy: String) -> Observable<Page<[QuestionModel]>>
}

extension IQuestionListViewModel {
    
    func transformToPage(response: QuestionsResponse, batch: Batch) -> Page<[QuestionModel]> {
        let nextBatch = Batch(offset: batch.offset,
                              limit: response.data.meta.pages.perPage ,
                              total: response.data.meta.pages.total,
                              count: response.data.meta.pages.page,
                              page: response.data.meta.pages.page)
        return Page<[QuestionModel]>(
            item: generateQuestions(from: response),
            batch: nextBatch
        )
    }
    
    func paginateItems(
        batch: Batch = Batch.initial,
        nextBatchTrigger: Observable<Void>, filteredBy: String, orderedBy: String) -> Observable<[QuestionModel]> {
        return recursivelyPaginateItems(batch: batch, nextBatchTrigger: nextBatchTrigger, filteredBy: filteredBy, orderedBy: orderedBy)
            .scan([], accumulator: { (accumulator, page) in
                return accumulator + page.item
            })
    }
    
    func generateQuestions(from questionResponse: QuestionsResponse) -> [QuestionModel] {
        return questionResponse.data.questions.map({ (questionResponse) -> QuestionModel in
            return QuestionModel(question: questionResponse)
        })
    }
    
    func reportQuestion(question: QuestionModel) -> Observable<String> {
        // TODO: make sure what is className
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.reportQuestion(id: question.id, className: "Question"), c: QuestionOptionResponse.self)
            .map { (response) -> String in
                return response.data.vote.status ? "success report" : response.data.vote.text
            }
            .asObservable()
            .catchErrorJustReturn("Oops something went wrong")
    }
    
    func deleteQuestion(question: QuestionModel) -> Observable<(question: QuestionModel, status: Bool)> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.deleteQuestion(id: question.id
            ), c: QuestionResponse.self)
            .map({ (response) -> (question: QuestionModel, status: Bool) in
                let questionModel = QuestionModel(question: response.data.question)
                let status = response.data.status
                
                return (questionModel, status)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    func voteQuestion(question: QuestionModel) -> Observable<(questionId: String, status: Bool)> {
        return NetworkService.instance
            .requestObject(TanyaKandidatAPI.voteQuestion(id: question.id, className: "Question"), c: QuestionOptionResponse.self)
            .map({ (response) -> (question: String, status: Bool) in
                let questionId = question.id
                let status = response.data.vote.status
                
                return (questionId, status)
            })
            .asObservable()
            .catchErrorJustComplete()
    }
    
    func bannerInfo() -> Observable<BannerInfo> {
        return NetworkService.instance
            .requestObject(
                LinimasaAPI.getBannerInfos(pageName: "tanya"),
                c: BaseResponse<BannerInfoResponse>.self
            )
            .map{ ($0.data.bannerInfo) }
            .asObservable()
            .catchErrorJustComplete()
    }
}
