//
//  DailyTaskWidget.swift
//  DailyTaskWidget
//
//  Created by hungwei on 2025/12/2.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Provider
struct DailyTaskWidgetProvider: TimelineProvider {
    // App Group for sharing data between app and widget
    private let appGroupID = "group.task-creator.com.task-creator"
    
    func placeholder(in context: Context) -> DailyTaskWidgetEntry {
        DailyTaskWidgetEntry(
            date: Date(),
            tasks: sampleTasks,
            currentDay: getCurrentDay()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (DailyTaskWidgetEntry) -> ()) {
        let entry = DailyTaskWidgetEntry(
            date: Date(),
            tasks: context.isPreview ? sampleTasks : loadTodayTasks(),
            currentDay: getCurrentDay()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let todayTasks = loadTodayTasks()
        
        let entry = DailyTaskWidgetEntry(
            date: currentDate,
            tasks: todayTasks,
            currentDay: getCurrentDay()
        )
        
        // Refresh every 15 minutes
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        
        completion(timeline)
    }
    
    // MARK: - Helper Methods
    
    /// Load today's tasks from shared UserDefaults
    private func loadTodayTasks() -> [Task] {
        guard let sharedDefaults = UserDefaults(suiteName: appGroupID),
              let savedData = sharedDefaults.data(forKey: "tasks"),
              let allTasks = try? JSONDecoder().decode([Task].self, from: savedData) else {
            return []
        }
        
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let tomorrowStart = calendar.date(byAdding: .day, value: 1, to: todayStart) ?? todayStart
        
        // Filter tasks whose dueDate is \"today\" (regardless of completion)
        let todayTasks = allTasks
            .filter { $0.dueDate >= todayStart && $0.dueDate < tomorrowStart }
            .sorted { task1, task2 in
                // Sort by priority: urgent first
                if task1.priority == .urgent && task2.priority != .urgent {
                    return true
                }
                if task2.priority == .urgent && task1.priority != .urgent {
                    return false
                }
                // Otherwise, earlier dueDate first
                return task1.dueDate < task2.dueDate
            }
        
        return Array(todayTasks.prefix(5))
    }
    
    /// Get current day of week
    private func getCurrentDay() -> Day {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let dayMap: [Int: Day] = [
            2: .mon, 3: .tue, 4: .wed, 5: .thu, 6: .fri, 7: .sat, 1: .sun
        ]
        return dayMap[weekday] ?? .mon
    }
    
    /// Sample tasks for placeholder
    private var sampleTasks: [Task] {
        let sampleCategories = [
            Category(name: "國文", icon: "book", colorHex: "FF9F0A", isSystem: true),
            Category(name: "數學", icon: "square.stack.3d.up", colorHex: "007AFF", isSystem: true),
            Category(name: "英文", icon: "textformat", colorHex: "30D158", isSystem: true),
            Category(name: "其他", icon: "sparkles", colorHex: "8E8E93", isSystem: true)
        ]
        
        return [
            Task(title: "完成數學作業", type: TaskType.defaults.first!, category: sampleCategories[1], priority: .urgent, day: getCurrentDay()),
            Task(title: "背英文單字", type: TaskType.defaults.first!, category: sampleCategories[2], priority: .normal, day: getCurrentDay()),
            Task(title: "閱讀課外讀物", type: TaskType.defaults.first!, category: sampleCategories.last!, priority: .normal, day: getCurrentDay())
        ]
    }
}

// MARK: - Timeline Entry
struct DailyTaskWidgetEntry: TimelineEntry {
    let date: Date
    let tasks: [Task]
    let currentDay: Day
}

// MARK: - Widget View
struct DailyTaskWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: DailyTaskWidgetProvider.Entry

    var body: some View {
        ZStack {
            // 讓外層保持透明，使用系統提供的 containerBackground 當底色
            Color.clear
            
            // Main card
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(hex: "FFF3D9"))
                .overlay(
                    cardContent
                        .padding(cardPadding)
                )
                .padding(10)
        }
    }
    
    // MARK: - Subviews
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: spacing) {
            // Top row: title + icon
            HStack {
                Text("準備好…")
                .font(widgetFamily == .systemSmall ? .headline.weight(.bold)
                      : .title2.weight(.bold))
                .foregroundColor(Color(hex: "1E293B"))
                .lineLimit(1)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: widgetFamily == .systemSmall ? 40 : 52,
                           height: widgetFamily == .systemSmall ? 40 : 52)
                Image(systemName: "party.popper.fill")
                    .foregroundColor(Color(hex: "FF9F0A"))
                    .font(.system(size: widgetFamily == .systemSmall ? 18 : 22))
            }
        }
        
        // Status row
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusText)
                .font(widgetFamily == .systemSmall ? .caption2 : .caption)
                .foregroundColor(Color(hex: "475569"))
            Spacer()
        }
        
        // Focus button
        Link(destination: URL(string: "taskflow://pomodoro/start")!) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.headline)
                    Text("開始專注")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                
                Spacer()
                
                Text("25:00")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(Color(hex: "FF7A1A"))
            .clipShape(RoundedRectangle(cornerRadius: 999, style: .continuous))
            .shadow(color: Color(hex: "FF7A1A").opacity(0.4),
                    radius: 10, x: 0, y: 6)
        }
    }
}

// MARK: - Computed Properties

// 今日任務狀態統計
private var pendingCount: Int {
    entry.tasks.filter { status(for: $0) == .pending }.count
}

private var overdueCount: Int {
    entry.tasks.filter { status(for: $0) == .overdue }.count
}

private var completedCount: Int {
    entry.tasks.filter { status(for: $0) == .completed }.count
}

// 狀態文案（根據規則）
private var statusText: String {
    if entry.tasks.isEmpty {
        return "目前無待辦事項"
    }
    if pendingCount == 0 && overdueCount == 0 && completedCount > 0 {
        return "今天的任務都完成了 🎉"
    }
    if overdueCount > 0 {
        return "有 \(overdueCount) 項已逾期，記得優先處理"
    }
    return "還有 \(pendingCount) 項任務等你完成"
}

private var statusColor: Color {
    if entry.tasks.isEmpty || (pendingCount == 0 && overdueCount == 0 && completedCount > 0) {
        return Color(hex: "34C759") // Green
    }
    if overdueCount > 0 {
        return Color(hex: "FF3B30") // Red
    }
    return Color(hex: "FF9F0A") // Orange
}

private var dayDisplayName: String {
    let dayNames: [Day: String] = [
        .mon: "星期一", .tue: "星期二", .wed: "星期三",
        .thu: "星期四", .fri: "星期五", .sat: "星期六", .sun: "星期日"
    ]
    return dayNames[entry.currentDay] ?? ""
}

// Size-dependent properties
private var spacing: CGFloat {
    widgetFamily == .systemSmall ? 8 : 12
}

private var cardPadding: CGFloat {
    widgetFamily == .systemSmall ? 14 : 18
}

// MARK: - Task Status (同 App 端邏輯)

private enum TaskStatus {
    case completed
    case pending
    case overdue
}

/// 截止日期是「今天」的任務：整天都會顯示「進行中」，不會變成「逾期」。
/// 截止日期在「昨天或更早」：顯示「逾期」。
/// 已勾選完成的任務：無論日期，一律顯示「已完成」。
private func status(for task: Task) -> TaskStatus {
    let calendar = Calendar.current
    let todayStart = calendar.startOfDay(for: Date())
    let dueDayStart = calendar.startOfDay(for: task.dueDate)
    
    if task.completed {
        return .completed
    }
    
    if dueDayStart < todayStart {
        return .overdue
    }
    
    return .pending
}
}

// MARK: - Widget Configuration
struct DailyTaskWidget: Widget {
let kind: String = "DailyTaskWidget"

var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: DailyTaskWidgetProvider()) { entry in
        DailyTaskWidgetEntryView(entry: entry)
            .containerBackground(Color(hex: "FDF6E3"), for: .widget)
    }
    .configurationDisplayName("今日任務")
    .description("查看您今天的重點任務")
    .supportedFamilies([.systemSmall, .systemMedium])
}
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    DailyTaskWidget()
} timeline: {
    DailyTaskWidgetEntry(
        date: Date(),
        tasks: Array(DailyTaskWidgetProvider.previewTasks.prefix(2)),
        currentDay: .mon
    )
    DailyTaskWidgetEntry(
        date: Date(),
        tasks: [],
        currentDay: .mon
    )
}

#Preview(as: .systemMedium) {
    DailyTaskWidget()
} timeline: {
    DailyTaskWidgetEntry(
        date: Date(),
        tasks: DailyTaskWidgetProvider.previewTasks,
        currentDay: .mon
    )
}

extension DailyTaskWidgetProvider {
    static var previewTasks: [Task] {
        let sampleCategories = [
            Category(name: "國文", icon: "book", colorHex: "FF9F0A", isSystem: true),
            Category(name: "數學", icon: "square.stack.3d.up", colorHex: "007AFF", isSystem: true),
            Category(name: "英文", icon: "textformat", colorHex: "30D158", isSystem: true),
            Category(name: "其他", icon: "sparkles", colorHex: "8E8E93", isSystem: true)
        ]
        
        // Ensure we have a valid task type for preview
        let defaultType = TaskType(name: "一般", icon: "circle", isSystem: true)
        
        return [
            Task(title: "完成數學作業", type: defaultType, category: sampleCategories[1], priority: .urgent, day: .mon),
            Task(title: "背英文單字", type: defaultType, category: sampleCategories[2], priority: .normal, day: .mon),
            Task(title: "閱讀課外讀物", type: defaultType, category: sampleCategories.last!, priority: .normal, day: .mon),
            Task(title: "複習物理", type: defaultType, category: sampleCategories.last!, priority: .normal, day: .mon)
        ]
    }
}
    
