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
        
        let currentDay = getCurrentDay()
        
        // Filter tasks for today and not completed
        let todayTasks = allTasks
            .filter { $0.day == currentDay && !$0.completed }
            .sorted { task1, task2 in
                // Sort by priority: urgent first
                if task1.priority == .urgent && task2.priority != .urgent {
                    return true
                }
                return false
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
        [
            Task(title: "完成數學作業", category: .math, priority: .urgent, day: getCurrentDay()),
            Task(title: "背英文單字", category: .english, priority: .normal, day: getCurrentDay()),
            Task(title: "閱讀課外讀物", category: .other, priority: .normal, day: getCurrentDay())
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
            // Beige background
            Color(hex: "FDF6E3")
            
            VStack(alignment: .leading, spacing: spacing) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("今日任務")
                            .font(headerFont)
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "5D4037"))
                        
                        if widgetFamily != .systemSmall {
                            Text(dayDisplayName)
                                .font(.caption2)
                                .foregroundColor(Color(hex: "5D4037").opacity(0.6))
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "checklist")
                        .foregroundColor(Color(hex: "5D4037"))
                        .font(iconFont)
                }
                
                // Tasks or Empty State
                if entry.tasks.isEmpty {
                    emptyStateView
                } else {
                    tasksListView
                }
                
                Spacer(minLength: 0)
            }
            .padding(padding)
        }
    }
    
    // MARK: - Subviews
    
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("🎉")
                .font(.system(size: widgetFamily == .systemSmall ? 32 : 40))
            Text("無待辦事項")
                .font(widgetFamily == .systemSmall ? .caption : .subheadline)
                .foregroundColor(.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tasksListView: some View {
        ForEach(displayedTasks) { task in
            HStack(spacing: 6) {
                // Category indicator
                Circle()
                    .fill(task.category.foregroundColor)
                    .frame(width: dotSize, height: dotSize)
                
                // Task title
                Text(task.title)
                    .font(taskFont)
                    .fontWeight(.medium)
                    .foregroundColor(Color(hex: "5D4037"))
                    .lineLimit(1)
                
                Spacer(minLength: 4)
                
                // Priority badge
                if task.priority == .urgent {
                    Text("急")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .cornerRadius(3)
                }
            }
            .padding(taskPadding)
            .background(Color.white.opacity(0.7))
            .cornerRadius(cardCornerRadius)
        }
    }
    
    // MARK: - Computed Properties
    
    private var displayedTasks: [Task] {
        let maxTasks = widgetFamily == .systemSmall ? 3 : 5
        return Array(entry.tasks.prefix(maxTasks))
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
    
    private var padding: CGFloat {
        widgetFamily == .systemSmall ? 12 : 16
    }
    
    private var taskPadding: CGFloat {
        widgetFamily == .systemSmall ? 6 : 8
    }
    
    private var dotSize: CGFloat {
        widgetFamily == .systemSmall ? 5 : 6
    }
    
    private var cardCornerRadius: CGFloat {
        widgetFamily == .systemSmall ? 6 : 8
    }
    
    private var headerFont: Font {
        widgetFamily == .systemSmall ? .subheadline : .headline
    }
    
    private var iconFont: Font {
        widgetFamily == .systemSmall ? .caption : .body
    }
    
    private var taskFont: Font {
        widgetFamily == .systemSmall ? .caption2 : .caption
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

// MARK: - Widget Bundle (Entry Point)
@main
struct DailyTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        DailyTaskWidget()
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    DailyTaskWidget()
} timeline: {
    DailyTaskWidgetEntry(
        date: Date(),
        tasks: [
            Task(title: "完成數學作業", category: .math, priority: .urgent, day: .mon),
            Task(title: "背英文單字", category: .english, priority: .normal, day: .mon)
        ],
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
        tasks: [
            Task(title: "完成數學作業", category: .math, priority: .urgent, day: .mon),
            Task(title: "背英文單字", category: .english, priority: .normal, day: .mon),
            Task(title: "閱讀課外讀物", category: .other, priority: .normal, day: .mon),
            Task(title: "複習物理", category: .other, priority: .normal, day: .mon)
        ],
        currentDay: .mon
    )
}
