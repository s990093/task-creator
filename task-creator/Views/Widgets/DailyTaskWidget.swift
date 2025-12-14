//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), tasks: [
//            Task(title: "完成數學作業", category: .math, priority: .urgent, day: .mon),
//            Task(title: "背英文單字", category: .english, priority: .normal, day: .mon),
//            Task(title: "閱讀課外讀物", category: .other, priority: .normal, day: .mon)
//        ])
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), tasks: [
//            Task(title: "完成數學作業", category: .math, priority: .urgent, day: .mon),
//            Task(title: "背英文單字", category: .english, priority: .normal, day: .mon),
//            Task(title: "閱讀課外讀物", category: .other, priority: .normal, day: .mon)
//        ])
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        // In a real app, you would fetch data from a shared container (App Group)
//        // For now, we'll use mock data or try to load from UserDefaults if shared
//        
//        let currentDate = Date()
//        let entry = SimpleEntry(date: currentDate, tasks: loadTasks())
//        
//        let timeline = Timeline(entries: [entry], policy: .atEnd)
//        completion(timeline)
//    }
//    
//    func loadTasks() -> [Task] {
//        // Attempt to load from UserDefaults (Note: Needs App Group for real app/widget sharing)
//        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
//           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
//            return Array(decodedTasks.prefix(3))
//        }
//        return []
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let tasks: [Task]
//}
//
//struct DailyTaskWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        ZStack {
//            Color(hex: "FDF6E3") // Beige background
//            
//            VStack(alignment: .leading, spacing: 12) {
//                HStack {
//                    Text("今日任務")
//                        .font(.headline)
//                        .foregroundColor(Color(hex: "5D4037"))
//                    Spacer()
//                    Image(systemName: "checklist")
//                        .foregroundColor(Color(hex: "5D4037"))
//                }
//                
//                if entry.tasks.isEmpty {
//                    Text("無待辦事項 🎉")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                } else {
//                    ForEach(entry.tasks) { task in
//                        HStack(spacing: 8) {
//                            Circle()
//                                .fill(task.category.foregroundColor)
//                                .frame(width: 8, height: 8)
//                            
//                            Text(task.title)
//                                .font(.caption)
//                                .fontWeight(.medium)
//                                .foregroundColor(Color(hex: "5D4037"))
//                                .lineLimit(1)
//                            
//                            Spacer()
//                        }
//                        .padding(8)
//                        .background(Color.white)
//                        .cornerRadius(8)
//                    }
//                }
//                
//                Spacer()
//            }
//            .padding()
//        }
//    }
//}
//
//struct DailyTaskWidget: Widget {
//    let kind: String = "DailyTaskWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            DailyTaskWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("每日任務")
//        .description("查看您今天的重點任務。")
//        .supportedFamilies([.systemSmall, .systemMedium])
//    }
//}
//
//// Helper for Preview
//struct DailyTaskWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        DailyTaskWidgetEntryView(entry: SimpleEntry(date: Date(), tasks: [
//            Task(title: "寫數學", category: .math, priority: .urgent, day: .mon),
//            Task(title: "讀英文", category: .english, priority: .normal, day: .mon)
//        ]))
//        .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
//
//// Duplicate Models for Widget (since it might be in a separate target)
//// In a real project, you would check "Target Membership" for TaskModel.swift
//// For this file to compile standalone if added to a new target, it needs the models.
//// Assuming TaskModel.swift is shared.
