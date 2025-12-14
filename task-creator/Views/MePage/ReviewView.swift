import Charts
import SwiftUI
import SwiftUICore
import Foundation

struct DailyData: Identifiable {
    var id = UUID()
    var day: String
    var tasksCompleted: Int
    var focusMinutes: Int
}

struct ReviewView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    // 計算真實的每日數據
    private var weeklyData: [DailyData] {
        calculateWeeklyData()
    }
    
    var body: some View {
        ZStack {
            // 深色背景
            Color(hex: "1C2833")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.title2)
                            .foregroundColor(.cyan)
                        Text("學習回顧")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    // 1. 嵌入 WeeklyStatsView 的卡片
                    VStack(spacing: 0) {
                        WeeklyPerformanceCard(data: calculateWeeklyAnalytics())
                        
                        Divider()
                            .background(Color.white.opacity(0.1))
                            .padding(.vertical, 20)
                        
                        FocusDataCard(data: calculateWeeklyAnalytics())
                    }
                    .padding(.horizontal, 20)
                    
                    // 2. 本週任務完成趨勢圖
                    VStack(alignment: .leading, spacing: 16) {
                        Text("本週任務完成趨勢")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if weeklyData.allSatisfy({ $0.tasksCompleted == 0 }) {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.3))
                                Text("本週尚無完成任務")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                        } else {
                            Chart(weeklyData) { data in
                                BarMark(
                                    x: .value("Day", data.day),
                                    y: .value("Tasks", data.tasksCompleted)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "5DD3C6"), Color(hex: "4A90E2")],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .cornerRadius(4)
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine()
                                        .foregroundStyle(Color.white.opacity(0.1))
                                    AxisValueLabel()
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "2C3544"))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // 3. 專注時間趨勢圖
                    VStack(alignment: .leading, spacing: 16) {
                        Text("專注時間趨勢 (分鐘)")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        if weeklyData.allSatisfy({ $0.focusMinutes == 0 }) {
                            VStack(spacing: 12) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.3))
                                Text("本週尚無專注記錄")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 200)
                        } else {
                            Chart(weeklyData) { data in
                                LineMark(
                                    x: .value("Day", data.day),
                                    y: .value("Minutes", data.focusMinutes)
                                )
                                .foregroundStyle(Color(hex: "5DD3C6"))
                                .interpolationMethod(.catmullRom)
                                .lineStyle(StrokeStyle(lineWidth: 3))
                                .symbol(Circle().strokeBorder(lineWidth: 2))
                                
                                AreaMark(
                                    x: .value("Day", data.day),
                                    y: .value("Minutes", data.focusMinutes)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(hex: "5DD3C6").opacity(0.3),
                                            Color(hex: "5DD3C6").opacity(0.0)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .interpolationMethod(.catmullRom)
                            }
                            .frame(height: 200)
                            .chartYAxis {
                                AxisMarks(position: .leading) { value in
                                    AxisGridLine()
                                        .foregroundStyle(Color.white.opacity(0.1))
                                    AxisValueLabel()
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                            .chartXAxis {
                                AxisMarks { value in
                                    AxisValueLabel()
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "2C3544"))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    // 4. 已完成任務記錄表
                    VStack(alignment: .leading, spacing: 16) {
                        Text("已完成任務記錄")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        let completedTasks = getCompletedTasks()
                        
                        if completedTasks.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.white.opacity(0.3))
                                Text("尚無完成任務")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(completedTasks.prefix(10)) { task in
                                    HStack {
                                        // 完成圖示
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(Color(hex: "5DD3C6"))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(task.title)
                                                .font(.subheadline)
                                                .foregroundColor(.white)
                                                .lineLimit(1)
                                            
                                            Text(task.dueDate.formatted(.dateTime.month().day()))
                                                .font(.caption)
                                                .foregroundColor(.white.opacity(0.5))
                                        }
                                        
                                        Spacer()
                                        
                                        // 類別標籤
                                        Text(task.category.name)
                                            .font(.caption2)
                                            .fontWeight(.bold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(task.category.color)
                                            .foregroundColor(.white)
                                            .cornerRadius(6)
                                    }
                                    .padding(12)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(hex: "2C3544"))
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical, 16)
            }
        }
    }
    
    // MARK: - 計算真實數據
    func calculateWeeklyData() -> [DailyData] {
        let calendar = Calendar.current
        let now = Date()
        var data: [DailyData] = []
        
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2)
        
        let dayNames = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        
        for dayOffset in 0..<7 {
            let targetDate = calendar.date(byAdding: .day, value: dayOffset - daysFromMonday, to: now)!
            
            // 計算該天完成的任務數
            let completedCount = viewModel.tasks.filter { task in
                task.completed && calendar.isDate(task.dueDate, inSameDayAs: targetDate)
            }.count
            
            // 計算該天的專注時間（分鐘）
            let focusMinutes = Int(
                viewModel.focusSessions
                    .filter { calendar.isDate($0.startTime, inSameDayAs: targetDate) }
                    .reduce(0) { $0 + $1.duration } / 60
            )
            
            data.append(DailyData(
                day: dayNames[dayOffset],
                tasksCompleted: completedCount,
                focusMinutes: focusMinutes
            ))
        }
        
        return data
    }
    
    func calculateWeeklyAnalytics() -> WeeklyAnalytics {
        let calendar = Calendar.current
        let now = Date()
        
        // 本週任務
        let weeklyTasks = viewModel.tasks.filter { task in
            calendar.isDate(task.dueDate, equalTo: now, toGranularity: .weekOfYear)
        }
        
        let completedTasks = weeklyTasks.filter { $0.completed }.count
        let totalTasks = weeklyTasks.count
        let completionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        
        // 本週專注會話
        let weeklySessions = viewModel.focusSessions.filter { session in
            calendar.isDate(session.startTime, equalTo: now, toGranularity: .weekOfYear)
        }
        
        let totalFocusMinutes = Int(weeklySessions.reduce(0) { $0 + $1.duration } / 60)
        let completedPomodoros = weeklySessions.filter {
            $0.status == .completed && $0.duration >= 1200
        }.count
        
        // 週一到週五的每日時間
        var dailyFocusMinutes: [Int] = []
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2)
        
        for dayOffset in 0..<5 {
            let targetDate = calendar.date(byAdding: .day, value: dayOffset - daysFromMonday, to: now)!
            let daySessions = weeklySessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: targetDate)
            }
            let totalSeconds = daySessions.reduce(0.0) { $0 + $1.duration }
            dailyFocusMinutes.append(Int(totalSeconds / 60))
        }
        
        return WeeklyAnalytics(
            completedTasks: completedTasks,
            totalTasks: totalTasks,
            completionRate: completionRate,
            totalFocusMinutes: totalFocusMinutes,
            completedPomodoros: completedPomodoros,
            dailyFocusMinutes: dailyFocusMinutes
        )
    }
    
    func getCompletedTasks() -> [Task] {
        viewModel.tasks
            .filter { $0.completed }
            .sorted { $0.dueDate > $1.dueDate }
    }
}

#Preview {
    ReviewView()
        .environmentObject(TaskViewModel())
}
