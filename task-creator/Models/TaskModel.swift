import Foundation
import SwiftUI

struct Category: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var icon: String
    var colorHex: String
    var isSystem: Bool = false // Prevent deletion of system categories
    
    var color: Color {
        Color(colorHex)
    }
    
    // Default Categories
    static let defaults: [Category] = []
}

struct TaskType: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var name: String
    var icon: String
    var isSystem: Bool = false
    
    // Default Types
    static let defaults: [TaskType] = [
        TaskType(name: "課業", icon: "books.vertical.fill", isSystem: true),
        TaskType(name: "生活", icon: "leaf.fill", isSystem: true),
        TaskType(name: "其他", icon: "ellipsis.circle.fill", isSystem: true)
    ]
}

enum Priority: String, CaseIterable, Codable {
    case normal = "普通"
    case urgent = "急"
}

enum Day: String, CaseIterable, Codable, Identifiable {
    case mon = "Mon"
    case tue = "Tue"
    case wed = "Wed"
    case thu = "Thu"
    case fri = "Fri"
    case sat = "Sat"
    case sun = "Sun"
    
    var id: String { rawValue }
}

struct Task: Identifiable, Codable, Equatable {
    var id: String = String(Date().timeIntervalSince1970)
    var title: String
    var type: TaskType
    var category: Category
    var priority: Priority
    var day: Day? // null represents Inbox
    var completed: Bool = false
    var completedDate: Date?
    var dueDate: Date = Date() // Added due date
    var customCategory: String? // Kept for backward compatibility if needed, but likely redundant now
}

enum Mood: String, Codable, CaseIterable {
    case happy = "😄"
    case neutral = "😐"
    case sad = "😵‍💫"
    
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .neutral: return .orange
        case .sad: return .purple
        }
    }
}

struct Reflection: Identifiable, Codable {
    var id = UUID().uuidString
    var date: Date
    var mood: Mood
    var content: String
}

enum FocusStatus: String, Codable {
    case completed
    case abandoned
}

struct FocusSession: Identifiable, Codable {
    var id: String = UUID().uuidString
    var startTime: Date
    var endTime: Date
    var duration: TimeInterval
    var category: Category
    var status: FocusStatus
}

struct AIAnalysisRecord: Identifiable, Codable {
    var id: String = UUID().uuidString
    var date: Date
    var content: String
}

struct ImportantDate: Identifiable, Codable {
    var id: String = UUID().uuidString
    var title: String
    var date: Date
    var color: String // Hex color string
    var icon: String = "calendar" // System image name
}
