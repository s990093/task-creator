import Foundation
import SwiftUI

// MARK: - Achievement Model

struct Achievement: Identifiable, Codable, Hashable {
    var id: String = UUID().uuidString
    var title: String
    var description: String
    var icon: String
    var colorHex: String
    var unlockedDate: Date?
    var achievementType: AchievementType
    
    var color: Color {
        Color(hex: colorHex)
    }
    
    var isUnlocked: Bool {
        unlockedDate != nil
    }
    
    // Predefined achievement types
    enum AchievementType: String, Codable, CaseIterable {
        case perfectWeek = "perfect_week"           // 100% completion rate
        case focusMaster = "focus_master"           // >= 10 hours focus time
        case consistentProgress = "consistent_progress" // 3 consecutive weeks improvement
        case balancedDevelopment = "balanced_development" // All categories have focus time
        case earlyBird = "early_bird"              // 3+ days starting before 8 AM
        case pomodoroChampion = "pomodoro_champion" // 20+ completed pomodoros
        case weeklyWarrior = "weekly_warrior"      // 5+ days with tasks completed
        
        var defaultConfig: Achievement {
            switch self {
            case .perfectWeek:
                return Achievement(
                    title: "全力以赴",
                    description: "本週任務完成率達到 100%",
                    icon: "star.fill",
                    colorHex: "FFD700",
                    achievementType: .perfectWeek
                )
            case .focusMaster:
                return Achievement(
                    title: "專注達人",
                    description: "本週專注時間超過 10 小時",
                    icon: "brain.head.profile",
                    colorHex: "5DD3C6",
                    achievementType: .focusMaster
                )
            case .consistentProgress:
                return Achievement(
                    title: "連續進步",
                    description: "連續 3 週完成率持續上升",
                    icon: "chart.line.uptrend.xyaxis",
                    colorHex: "4A90E2",
                    achievementType: .consistentProgress
                )
            case .balancedDevelopment:
                return Achievement(
                    title: "平衡發展",
                    description: "所有類別都有專注時間投入",
                    icon: "chart.pie.fill",
                    colorHex: "FF9F0A",
                    achievementType: .balancedDevelopment
                )
            case .earlyBird:
                return Achievement(
                    title: "早起鳥兒",
                    description: "本週至少 3 天在早上 8 點前開始專注",
                    icon: "sunrise.fill",
                    colorHex: "FF6B9D",
                    achievementType: .earlyBird
                )
            case .pomodoroChampion:
                return Achievement(
                    title: "番茄鐘冠軍",
                    description: "本週完成 20 個以上番茄鐘",
                    icon: "timer",
                    colorHex: "FF453A",
                    achievementType: .pomodoroChampion
                )
            case .weeklyWarrior:
                return Achievement(
                    title: "每日戰士",
                    description: "本週至少 5 天都完成了任務",
                    icon: "flame.fill",
                    colorHex: "FF9500",
                    achievementType: .weeklyWarrior
                )
            }
        }
    }
}

// MARK: - Weekly Memory Model

struct WeeklyMemory: Identifiable, Codable {
    var id: String = UUID().uuidString
    var weekStartDate: Date  // Monday
    var weekEndDate: Date    // Sunday
    
    // Task Statistics
    var completedTasksCount: Int
    var totalTasksCount: Int
    var completionRate: Double
    
    // Focus Statistics
    var totalFocusMinutes: Int
    var completedPomodoros: Int
    var dailyFocusMinutes: [Int]  // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    
    // Category Distribution (CategoryID: Minutes)
    var categoryDistribution: [String: Int]
    
    // Mood Records
    var moodRecords: [Mood]
    
    // Achievements
    var achievements: [Achievement]
    
    // Visual Theme
    var visualTheme: VisualTheme
    
    // Computed Properties
    var weekNumber: Int {
        Calendar.current.component(.weekOfYear, from: weekStartDate)
    }
    
    var year: Int {
        Calendar.current.component(.year, from: weekStartDate)
    }
    
    var weekTitle: String {
        "\(year)年 第\(weekNumber)週"
    }
    
    var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        let start = formatter.string(from: weekStartDate)
        let end = formatter.string(from: weekEndDate)
        return "\(start) - \(end)"
    }
    
    var averageDailyFocusMinutes: Int {
        let nonZeroDays = dailyFocusMinutes.filter { $0 > 0 }.count
        guard nonZeroDays > 0 else { return 0 }
        let total = dailyFocusMinutes.reduce(0, +)
        return total / nonZeroDays
    }
    
    var activeDaysCount: Int {
        dailyFocusMinutes.filter { $0 > 0 }.count
    }
}

// MARK: - Visual Theme

struct VisualTheme: Codable, Hashable {
    var primaryColorHex: String
    var secondaryColorHex: String
    var gradientColors: [String]
    var themeName: String
    
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var secondaryColor: Color {
        Color(hex: secondaryColorHex)
    }
    
    var gradient: LinearGradient {
        LinearGradient(
            colors: gradientColors.map { Color(hex: $0) },
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Generate theme based on completion rate
    static func theme(for completionRate: Double) -> VisualTheme {
        switch completionRate {
        case 0.9...1.0:  // Excellent (90-100%)
            return VisualTheme(
                primaryColorHex: "5DD3C6",
                secondaryColorHex: "30D158",
                gradientColors: ["5DD3C6", "4A90E2", "30D158"],
                themeName: "優秀"
            )
        case 0.7..<0.9:  // Good (70-89%)
            return VisualTheme(
                primaryColorHex: "4A90E2",
                secondaryColorHex: "5DD3C6",
                gradientColors: ["4A90E2", "5DD3C6"],
                themeName: "良好"
            )
        case 0.5..<0.7:  // Average (50-69%)
            return VisualTheme(
                primaryColorHex: "FF9F0A",
                secondaryColorHex: "FFD60A",
                gradientColors: ["FF9F0A", "FFD60A"],
                themeName: "加油"
            )
        default:  // Needs Improvement (0-49%)
            return VisualTheme(
                primaryColorHex: "FF6B6B",
                secondaryColorHex: "FF9F0A",
                gradientColors: ["FF6B6B", "FF9F0A"],
                themeName: "需努力"
            )
        }
    }
}

// MARK: - Mock Data

extension WeeklyMemory {
    static var sample: WeeklyMemory {
        WeeklyMemory(
            weekStartDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
            weekEndDate: Date(),
            completedTasksCount: 42,
            totalTasksCount: 45,
            completionRate: 0.93,
            totalFocusMinutes: 1250,
            completedPomodoros: 25,
            dailyFocusMinutes: [120, 150, 90, 200, 180, 450, 60],
            categoryDistribution: [
                "Coding": 600,
                "Reading": 300,
                "Writing": 200,
                "Meeting": 150
            ],
            moodRecords: [], 
            achievements: [
                Achievement.AchievementType.perfectWeek.defaultConfig,
                Achievement.AchievementType.focusMaster.defaultConfig
            ],
            visualTheme: VisualTheme.theme(for: 0.93)
        )
    }
    
    static var samples: [WeeklyMemory] {
        [
            sample,
            WeeklyMemory(
                weekStartDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                weekEndDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
                completedTasksCount: 30,
                totalTasksCount: 40,
                completionRate: 0.75,
                totalFocusMinutes: 800,
                completedPomodoros: 15,
                dailyFocusMinutes: [100, 120, 80, 150, 100, 200, 50],
                categoryDistribution: ["Coding": 400, "Reading": 200, "Admin": 200],
                moodRecords: [],
                achievements: [Achievement.AchievementType.consistentProgress.defaultConfig],
                visualTheme: VisualTheme.theme(for: 0.75)
            ),
            WeeklyMemory(
                weekStartDate: Calendar.current.date(byAdding: .day, value: -21, to: Date())!,
                weekEndDate: Calendar.current.date(byAdding: .day, value: -14, to: Date())!,
                completedTasksCount: 15,
                totalTasksCount: 30,
                completionRate: 0.5,
                totalFocusMinutes: 400,
                completedPomodoros: 8,
                dailyFocusMinutes: [60, 60, 60, 60, 60, 50, 50],
                categoryDistribution: ["Admin": 300, "Meeting": 100],
                moodRecords: [],
                achievements: [],
                visualTheme: VisualTheme.theme(for: 0.5)
            )
        ]
    }
}
