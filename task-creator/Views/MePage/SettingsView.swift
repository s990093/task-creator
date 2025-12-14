import SwiftUI

// MARK: - 時區管理器
class TimeZoneManager: ObservableObject {
    static let shared = TimeZoneManager()
    
    @Published var selectedTimeZone: AppTimeZone {
        didSet {
            UserDefaults.standard.set(selectedTimeZone.rawValue, forKey: "selectedTimeZone")
        }
    }
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "selectedTimeZone"),
           let timezone = AppTimeZone(rawValue: saved) {
            self.selectedTimeZone = timezone
        } else {
            self.selectedTimeZone = .taipei  // 預設台灣時區
        }
    }
    
    var currentTimeZone: TimeZone {
        selectedTimeZone.timezone
    }
}

// MARK: - 應用時區枚舉
enum AppTimeZone: String, CaseIterable, Identifiable {
    case taipei = "Asia/Taipei"
    case tokyo = "Asia/Tokyo"
    case seoul = "Asia/Seoul"
    case singapore = "Asia/Singapore"
    case london = "Europe/London"
    case newYork = "America/New_York"
    case losAngeles = "America/Los_Angeles"
    
    var id: String { rawValue }
    
    var timezone: TimeZone {
        TimeZone(identifier: rawValue) ?? TimeZone.current
    }
    
    var displayName: String {
        switch self {
        case .taipei: return "🇹🇼 台灣 (GMT+8)"
        case .tokyo: return "🇯🇵 東京 (GMT+9)"
        case .seoul: return "🇰🇷 首爾 (GMT+9)"
        case .singapore: return "🇸🇬 新加坡 (GMT+8)"
        case .london: return "🇬🇧 倫敦 (GMT+0)"
        case .newYork: return "🇺🇸 紐約 (GMT-5)"
        case .losAngeles: return "🇺🇸 洛杉磯 (GMT-8)"
        }
    }
    
    var flagEmoji: String {
        switch self {
        case .taipei: return "🇹🇼"
        case .tokyo: return "🇯🇵"
        case .seoul: return "🇰🇷"
        case .singapore: return "🇸🇬"
        case .london: return "🇬🇧"
        case .newYork, .losAngeles: return "🇺🇸"
        }
    }
}

// MARK: - 語言選項枚舉
enum AppLanguage: String, CaseIterable, Identifiable {
    case traditionalChinese = "zh-Hant"
    case simplifiedChinese = "zh-Hans"
    case english = "en"
    case japanese = "ja"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .traditionalChinese: return "🇹🇼 繁體中文"
        case .simplifiedChinese: return "🇨🇳 简体中文"
        case .english: return "🇺🇸 English"
        case .japanese: return "🇯🇵 日本語"
        }
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var timeZoneManager = TimeZoneManager.shared
    @State private var selectedLanguage: AppLanguage = .traditionalChinese
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    
    var body: some View {
        NavigationView {
            ZStack {
                // 深色背景
                Color(hex: "1C2833")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 時區設定區塊
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "clock.badge")
                                    .foregroundColor(.cyan)
                                Text("時區設定")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(AppTimeZone.allCases) { timezone in
                                    TimeZoneRow(
                                        timezone: timezone,
                                        isSelected: timeZoneManager.selectedTimeZone == timezone
                                    ) {
                                        withAnimation(.spring()) {
                                            timeZoneManager.selectedTimeZone = timezone
                                        }
                                    }
                                }
                            }
                            
                            // 當前時間顯示
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.white.opacity(0.5))
                                Text("目前時間：\(currentTimeString)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color(hex: "2C3544"))
                        .cornerRadius(16)
                        
                        // 語言設定區塊
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.green)
                                Text("語言設定")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(AppLanguage.allCases) { language in
                                    LanguageRow(
                                        language: language,
                                        isSelected: selectedLanguage == language
                                    ) {
                                        withAnimation(.spring()) {
                                            selectedLanguage = language
                                        }
                                    }
                                }
                            }
                            
                            // 提示訊息
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.orange.opacity(0.7))
                                Text("語言切換功能即將推出")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                                Spacer()
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color(hex: "2C3544"))
                        .cornerRadius(16)
                        
                        // 通知設定區塊
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bell.badge")
                                    .foregroundColor(.orange)
                                Text("通知設定")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(spacing: 16) {
                                SettingToggleRow(
                                    icon: "bell.fill",
                                    title: "推送通知",
                                    description: "接收任務提醒和專注完成通知",
                                    isOn: $notificationsEnabled
                                )
                                
                                SettingToggleRow(
                                    icon: "speaker.wave.2.fill",
                                    title: "音效",
                                    description: "計時器音效和提示音",
                                    isOn: $soundEnabled
                                )
                            }
                        }
                        .padding(20)
                        .background(Color(hex: "2C3544"))
                        .cornerRadius(16)
                        
                      
                        
                        // 關於
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                                Text("關於")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("版本")
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("1.0.0")
                                        .foregroundColor(.white)
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.1))
                                
                                HStack {
                                    Text("開發者")
                                        .foregroundColor(.white.opacity(0.6))
                                    Spacer()
                                    Text("TaskFlow Team")
                                        .foregroundColor(.white)
                                }
                            }
                            .font(.subheadline)
                        }
                        .padding(20)
                        .background(Color(hex: "2C3544"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }
    
    private var currentTimeString: String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZoneManager.currentTimeZone
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - 時區選擇行
struct TimeZoneRow: View {
    let timezone: AppTimeZone
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(timezone.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.cyan)
                        .imageScale(.large)
                }
            }
            .padding(12)
            .background(
                isSelected ?
                Color.cyan.opacity(0.15) :
                Color.white.opacity(0.05)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.cyan : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - 語言選擇行
struct LanguageRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(language.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .imageScale(.large)
                }
            }
            .padding(12)
            .background(
                isSelected ?
                Color.green.opacity(0.15) :
                Color.white.opacity(0.05)
            )
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.green : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
    }
}

// MARK: - 設定開關行
struct SettingToggleRow: View {
    let icon: String
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.cyan)
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.cyan)
        }
        .padding(12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

#Preview {
    SettingsView()
}
