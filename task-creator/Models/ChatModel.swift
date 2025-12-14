import Foundation

// MARK: - Chat Message
struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date
    var suggestedTasks: [SuggestedTask]?
    var suggestedTaskTypes: [SuggestedTaskType]?
    
    enum MessageRole: String, Codable {
        case user
        case assistant
    }
    
    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date(), suggestedTasks: [SuggestedTask]? = nil, suggestedTaskTypes: [SuggestedTaskType]? = nil) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
        self.suggestedTasks = suggestedTasks
        self.suggestedTaskTypes = suggestedTaskTypes
    }
}

// MARK: - Suggested Task
struct SuggestedTask: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let category: String
    let categoryIcon: String?
    let categoryColor: String?
    let priority: String
    var isSelected: Bool
    var isAdded: Bool
    
    init(id: UUID = UUID(), title: String, category: String, categoryIcon: String? = nil, categoryColor: String? = nil, priority: String, isSelected: Bool = false, isAdded: Bool = false) {
        self.id = id
        self.title = title
        self.category = category
        self.categoryIcon = categoryIcon
        self.categoryColor = categoryColor
        self.priority = priority
        self.isSelected = isSelected
        self.isAdded = isAdded
    }
}

// MARK: - Suggested TaskType
struct SuggestedTaskType: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var icon: String
    var colorHex: String?
    var isSelected: Bool = false
    var isAdded: Bool = false
    
    init(name: String, icon: String, colorHex: String? = nil, isSelected: Bool = false, isAdded: Bool = false) {
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.isSelected = isSelected
        self.isAdded = isAdded
    }
}

// MARK: - User Context
struct UserContext: Codable {
    var identity: String? // 如：资工系学生、高中生
    var goals: [String]? // 学习目标
    var preferences: [String: String]? // 其他偏好设置
}
