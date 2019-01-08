//
//  PenpolFilterModel.swift
//  PantauBersama
//
//  Created by Rahardyan Bisma on 07/01/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import Foundation

enum FilterViewType {
    case radio
    case text
}

struct PenpolFilterModel {
    let paramKey: String
    let title: String
    let items: [FilterItem]
    
    struct FilterItem {
        let paramKey: String
        let paramValue: String
        let title: String
        let type: FilterViewType
    }
}

extension PenpolFilterModel {
    static func generateQuestionFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(paramKey: "filter_by", paramValue: "user_verified_all", title: "Semua", type: .radio)
        let notVerified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_false", title: "Belum Verifikasi", type: .radio)
        let verified = FilterItem(paramKey: "filter_by", paramValue: "user_verified_true", title: "Terverifikasi", type: .radio)
        let userFilter = PenpolFilterModel(paramKey: "filter_by", title: "User", items: [all, notVerified, verified])
        
        let newest = FilterItem(paramKey: "order_by", paramValue: "created", title: "Paling Baru", type: .radio)
        let voteCount = FilterItem(paramKey: "order_by", paramValue: "cached_votes_up", title: "Paling Banyak Divoting", type: .radio)
        let orderFilter = PenpolFilterModel(paramKey: "order_by", title: "Urutan", items: [newest, voteCount])
        
        filterItems.append(userFilter)
        filterItems.append(orderFilter)
        
        return filterItems
    }
    
    static func generatePilpresFilter() -> [PenpolFilterModel] {
        var filterItems: [PenpolFilterModel] = []
        
        let all = FilterItem(paramKey: "filter_by", paramValue: "team_all", title: "Semua", type: .radio)
        let paslonSatu = FilterItem(paramKey: "filter_by", paramValue: "team_id_1", title: "Team Jokowi - Makruf", type: .radio)
        let paslonDua = FilterItem(paramKey: "filter_by", paramValue: "team_id_2", title: "Team Prabowo - Sandi", type: .radio)
        let sumberFilter = PenpolFilterModel(paramKey: "filter_by", title: "Sumber dari", items: [all, paslonSatu, paslonDua])
        filterItems.append(sumberFilter)
        return filterItems
    }
}
