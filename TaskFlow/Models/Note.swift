//
//  Note.swift
//  TaskFlow
//
//  Created by Joseph DeWeese on 3/27/25.
//

import Foundation
import SwiftData

@Model
class Note: Equatable {
    var creationDate: Date = Date.now
    var text: String
    var page: String?
    var noteTitle: String? // Added property
    
    @Relationship(deleteRule: .nullify, inverse: \Item.notes)
    var item: Item?
    
    init(text: String, page: String? = nil, noteTitle: String? = nil, creationDate: Date = .now) {
        self.text = text
        self.page = page
        self.noteTitle = noteTitle
        self.creationDate = creationDate
    }
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.text == rhs.text &&
        lhs.page == rhs.page &&
        lhs.noteTitle == rhs.noteTitle &&
        lhs.creationDate == rhs.creationDate
    }
}
