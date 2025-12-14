import Foundation

// MARK: - Learning Style
enum InteractionStyle: String, Codable {
    case strict = "嚴格教練"
    case gentle = "溫柔鼓勵"
    case analytical = "理性分析"
}

// MARK: - User Profile
struct UserProfile: Codable {
    var nickname: String
    var timezone: String
    var languages: [String]
    var goals: [String]
    var interactionStyle: InteractionStyle
    var contentDepth: Double // 0.0 (簡潔要點) to 1.0 (深入解析)
    var prefersPractical: Bool // true = 實作範例, false = 理論
    
    static let `default` = UserProfile(
        nickname: "小賴",
        timezone: "Asia/Taipei (GMT+8)",
        languages: ["繁體中文"],
        goals: [],
        interactionStyle: .gentle,
        contentDepth: 0.5,
        prefersPractical: true
    )
}

// MARK: - User Profile Manager
class UserProfileManager: ObservableObject {
    static let shared = UserProfileManager()
    
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }
    
    private let userDefaultsKey = "userProfile"
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = .default
        }
    }
    
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func getUserContext() -> UserContext {
        let identityString = "我是 \(profile.nickname)"
        let goalsString = profile.goals.isEmpty ? nil : profile.goals.joined(separator: ", ")
        
        var preferences: [String: String] = [
            "interactionStyle": profile.interactionStyle.rawValue,
            "contentDepth": profile.contentDepth < 0.33 ? "簡潔" : (profile.contentDepth > 0.67 ? "深入" : "中等"),
            "focusType": profile.prefersPractical ? "實作導向" : "理論導向"
        ]
        
        if !profile.languages.isEmpty {
            preferences["languages"] = profile.languages.joined(separator: ", ")
        }
        
        return UserContext(
            identity: identityString,
            goals: profile.goals.isEmpty ? nil : profile.goals,
            preferences: preferences
        )
    }
}
