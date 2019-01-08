//
//  PenpolFilterModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation
import RxSwift

enum FilterViewType: String {
    case radio = "radio"
    case text = "text"
}

struct PenpolFilterModel {
    let paramKey: String
    let title: String
    let items: [FilterItem]
    
    struct FilterItem {
        let paramKey: String
        var paramValue: String
        let title: String
        let type: FilterViewType
        let isSelected: Bool
    }
}

extension PenpolFilterModel {
    static func generateQuestionFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(paramKey: "filter_by", paramValue: "user_verified_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user_verified_all"))
        let notVerified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_false", title: "Belum Verifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user_verified_false"))
        let verified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_true", title: "Terverifikasi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "user_verified_true"))
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        let newest = FilterItem(paramKey: "order_by", paramValue: "created", title: "Paling Baru", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "created"))
        let voteCount = FilterItem(paramKey: "order_by", paramValue: "cached_votes_up", title: "Paling Banyak Divoting", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "cached_votes_up"))
        let orderFilter = PenpolFilterModel(paramKey: "order_by", title: "Urutan", items: [newest, voteCount])
        
        filterItems.append(userFilter)
        filterItems.append(orderFilter)
        
        return filterItems
    }
    

    static func generatePilpresFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(paramKey: "filter_by", paramValue: "team_all", title: "Semua", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "team_all"))
        let paslonSatu = FilterItem(paramKey: "filter_by", paramValue: "team_id_1", title: "Team Jokowi - Makruf", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "team_id_1"))
        let paslonDua = FilterItem(paramKey: "filter_by", paramValue: "team_id_2", title: "Team Prabowo - Sandi", type: .radio, isSelected: UserDefaults.isSelectedFilter(value: "team_id_2"))
        let sumberFilter = PenpolFilterModel(paramKey: "filter_by", title: "Sumber dari", items: [all, paslonSatu, paslonDua])
        filterItems.append(sumberFilter)
        return filterItems
    }
    
    static func generateJanjiFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        // TODO: TBD The key for this item is the same with quiz filter
        let cluster = FilterItem(paramKey: "cluster_id", paramValue: "", title: "Cluster", type: .text, isSelected: true)
        let clusterFilter = PenpolFilterModel(paramKey: "cluster_id", title: "Cluster", items: [cluster])
        let all = FilterItem(paramKey: "filter_by", paramValue: "user_verified_all", title: "Semua", type: .radio, isSelected: false)
        let notVerified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_false", title: "Belum Verifikasi", type: .radio, isSelected: false)
        let verified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_true", title: "Terverifikasi", type: .radio, isSelected: false)
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        filterItems.append(clusterFilter)
        filterItems.append(userFilter)
        
        return filterItems
    }

    static func generateQuizFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        func isSelected(key: String) -> Bool {
            return UserDefaults.standard.bool(forKey: key)
        }
        
        let all = FilterItem(paramKey: "filter_by", paramValue: "all", title: "Semua", type: .radio, isSelected: isSelected(key: "all"))
        let notParticipating = FilterItem(paramKey: "filter_by", paramValue: "not_participating", title: "Belum Diikuti", type: .radio, isSelected: isSelected(key: "not_participating"))
        let inProgress = FilterItem(paramKey: "filter_by", paramValue: "in_progress", title: "Belum Selesai", type: .radio, isSelected: isSelected(key: "in_progress"))
        let finished = FilterItem(paramKey: "filter_by", paramValue: "finished", title: "Selesai", type: .radio, isSelected: isSelected(key: "finished"))
        let quizFilter = PenpolFilterModel(paramKey: "filter_by", title: "Quiz", items: [all, notParticipating, inProgress, finished])
        
        filterItems.append(quizFilter)
        
        return filterItems
    }
}
