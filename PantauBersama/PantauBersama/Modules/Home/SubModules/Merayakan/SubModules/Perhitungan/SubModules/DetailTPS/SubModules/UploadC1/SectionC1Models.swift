//
//  SectionC1Models.swift
//  PantauBersama
//
//  Created by Hanif Sugiyanto on 10/04/19.
//  Copyright © 2019 PantauBersama. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

struct StashImages {
    var section: Int
    var images: UIImage?
    var id: String?
    
    init(section: Int, images: UIImage?, id: String?) {
        self.section = section
        self.images = images
        self.id = id
    }
    
}


// TableViewEditingCommand
enum TableViewEditingCommand {
    case AppendItem(item: StashImages, section: Int)
    case DeleteItem(IndexPath)
}
extension TableViewEditingCommand {
    
    func addItem(item: StashImages, section: Int) -> TableViewEditingCommand {
        return TableViewEditingCommand.AppendItem(item: item, section: section)
    }
    
}


struct SectionC1Models {
    var header: String
    var items: [StashImages]
    
    init(header: String, items: [StashImages]) {
        self.header = header
        self.items = items
    }
    
}

extension SectionC1Models: AnimatableSectionModelType {
    typealias Item = StashImages
    typealias Identity = String
    
    var identity: String {
        return header
    }
    
    var item: [StashImages] {
        return items
    }
    
    init(original: SectionC1Models, items: [Item]) {
        self = original
        self.items = items
    }
    
}

extension SectionC1Models: Equatable { }

func == (lhs: SectionC1Models, rhs: SectionC1Models) -> Bool {
    return lhs.header == rhs.header
        && lhs.items == rhs.items
}

extension StashImages: IdentifiableType, Equatable {
    typealias Identity = String
    
    var identity: String {
        return id ?? ""
    }
}


struct SectionC1TableViewState {
    
    var section: [SectionC1Models]
    
    
    init(section: [SectionC1Models]) {
        self.section = section
    }
    
    func executeCommand(command: TableViewEditingCommand) -> SectionC1TableViewState {
        
        switch command {
        case .AppendItem(let (item, section)):
            var sections = self.section
            let items = sections[section].items + item
            sections[section] = SectionC1Models(original: sections[section], items: items)
            return SectionC1TableViewState(section: sections)
        case .DeleteItem(let indexPath):
            var sections = self.section
            var items = sections[indexPath.section].items
            items.remove(at: indexPath.row)
            sections[indexPath.section] = SectionC1Models(original: sections[indexPath.section], items: items)
            return SectionC1TableViewState(section: sections)
        }
    }
}


func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}

