//
//  UserSettings.swift
//  Coacher
//
//  Created by Rebecca Clarke on 8/30/25.
//

import Foundation
import SwiftData

@Model
final class UserSettings {
    @Attribute(.unique) var id: UUID
    var customEveningPrepItems: [String]
    var dateCreated: Date
    var lastModified: Date
    
    init() {
        self.id = UUID()
        self.customEveningPrepItems = []
        self.dateCreated = Date()
        self.lastModified = Date()
    }
    
    func addCustomItem(_ item: String) {
        if !customEveningPrepItems.contains(item) {
            customEveningPrepItems.append(item)
            lastModified = Date()
        }
    }
    
    func removeCustomItem(_ item: String) {
        customEveningPrepItems.removeAll { $0 == item }
        lastModified = Date()
    }
}
