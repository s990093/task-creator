//import SwiftUI
//
///// 用於在主 App 中預覽和測試 Widget UI 的頁面
//struct WidgetPreviewTestView: View {
//    @EnvironmentObject var viewModel: TaskViewModel
//    
//    var body: some View {
//        ScrollView {
//            VStack(spacing: 24) {
//                Text("Widget 預覽測試")
//                    .font(.largeTitle)
//                    .fontWeight(.bold)
//                    .padding(.top)
//                
//                // Small Widget Preview
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Small Widget (小型)")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                    
//                    widgetView(size: .small)
//                        .frame(width: 169, height: 169)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
//                }
//                
//                // Medium Widget Preview
//                VStack(alignment: .leading, spacing: 8) {
//                    Text("Medium Widget (中型)")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                    
//                    widgetView(size: .medium)
//                        .frame(width: 360, height: 169)
//                        .clipShape(RoundedRectangle(cornerRadius: 20))
//                        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
//                }
//                
//                // Task Data Info
//                VStack(alignment: .leading, spacing: 12) {
//                    Text("當前任務資料")
//                        .font(.headline)
//                    
//                    Text("總任務數: \(viewModel.tasks.count)")
//                    Text("未完成任務: \(viewModel.tasks.filter { !$0.completed }.count)")
//                    Text("今日任務: \(todayTasks.count)")
//                    
//                    if !todayTasks.isEmpty {
//                        Divider()
//                        Text("今日任務列表:")
//                            .font(.subheadline)
//                            .fontWeight(.semibold)
//                        
//                        ForEach(todayTasks.prefix(5)) { task in
//                            HStack {
//                                Circle()
//                                    .fill(task.category.color)
//                                    .frame(width: 8, height: 8)
//                                Text(task.title)
//                                    .font(.caption)
//                                Spacer()
//                                if task.completed {
//                                    Image(systemName: "checkmark.circle.fill")
//                                        .foregroundColor(.green)
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding()
//                .background(Color.secondary.opacity(0.1))
//                .cornerRadius(12)
//                
//                Spacer()
//            }
//            .padding()
//        }
//        .background(Color(UIColor.systemGroupedBackground))
//    }
//    
//    // 獲取今日任務
//    private var todayTasks: [Task] {
//        let today = Calendar.current.component(.weekday, from: Date())
//        let dayMap: [Int: Day] = [
//            2: .mon, 3: .tue, 4: .wed, 5: .thu, 6: .fri, 7: .sat, 1: .sun
//        ]
//        
//        guard let currentDay = dayMap[today] else { return [] }
//        
//        return viewModel.tasks
//            .filter { $0.day == currentDay && !$0.completed }
//            .sorted { task1, task2 in
//                if task1.priority == .urgent && task2.priority != .urgent {
//                    return true
//                }
//                return false
//            }
//    }
//    
//    // Widget UI View
//    @ViewBuilder
//    private func widgetView(size: WidgetSize) -> some View {
//        let tasks = Array(todayTasks.prefix(size == .small ? 3 : 5))
//        
//        ZStack {
//            Color(hex: "FDF6E3") // Beige background
//            
//            VStack(alignment: .leading, spacing: size == .small ? 8 : 12) {
//                // Header
//                HStack {
//                    Text("今日任務")
//                        .font(size == .small ? .subheadline : .headline)
//                        .fontWeight(.bold)
//                        .foregroundColor(Color(hex: "5D4037"))
//                    Spacer()
//                    Image(systemName: "checklist")
//                        .foregroundColor(Color(hex: "5D4037"))
//                        .font(size == .small ? .caption : .body)
//                }
//                
//                if tasks.isEmpty {
//                    Spacer()
//                    HStack {
//                        Spacer()
//                        VStack(spacing: 8) {
//                            Text("🎉")
//                                .font(.largeTitle)
//                            Text("無待辦事項")
//                                .font(.subheadline)
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    Spacer()
//                } else {
//                    ForEach(tasks) { task in
//                        HStack(spacing: 8) {
//                            Circle()
//                                .fill(task.category.color)
//                                .frame(width: 6, height: 6)
//                            
//                            Text(task.title)
//                                .font(size == .small ? .caption2 : .caption)
//                                .fontWeight(.medium)
//                                .foregroundColor(Color(hex: "5D4037"))
//                                .lineLimit(1)
//                            
//                            Spacer()
//                            
//                            if task.priority == .urgent {
//                                Text("急")
//                                    .font(.caption2)
//                                    .fontWeight(.bold)
//                                    .foregroundColor(.white)
//                                    .padding(.horizontal, 6)
//                                    .padding(.vertical, 2)
//                                    .background(Color.red)
//                                    .cornerRadius(4)
//                            }
//                        }
//                        .padding(size == .small ? 6 : 8)
//                        .background(Color.white.opacity(0.8))
//                        .cornerRadius(8)
//                    }
//                    
//                    if size == .medium && tasks.count < 5 {
//                        Spacer()
//                    }
//                }
//                
//                if size == .small && !tasks.isEmpty {
//                    Spacer()
//                }
//            }
//            .padding(size == .small ? 12 : 16)
//        }
//    }
//    
//    enum WidgetSize {
//        case small, medium
//    }
//}
//
//#Preview {
//    WidgetPreviewTestView()
//        .environmentObject(TaskViewModel())
//}
