import SwiftUI

struct WeeklyStatsView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    // 計算本週數據
    private var weeklyData: WeeklyAnalytics {
        calculateWeeklyAnalytics()
    }
    
    var body: some View {
        ZStack {
            // 深色背景
            Color(hex: "1C2833")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 1. 本週表現分析卡片
                    WeeklyPerformanceCard(data: weeklyData)
                    
                    // 2. 專注數據卡片
                    FocusDataCard(data: weeklyData)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
        .navigationTitle("本週統計")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 計算本週數據
    func calculateWeeklyAnalytics() -> WeeklyAnalytics {
        let calendar = Calendar.current
        let now = Date()
        
        // 獲取本週任務
        let weeklyTasks = viewModel.tasks.filter { task in
            calendar.isDate(task.dueDate, equalTo: now, toGranularity: .weekOfYear)
        }
        
        let completedTasks = weeklyTasks.filter { $0.completed }.count
        let totalTasks = weeklyTasks.count
        let completionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        
        // 獲取本週專注會話
        let weeklySessions = viewModel.focusSessions.filter { session in
            calendar.isDate(session.startTime, equalTo: now, toGranularity: .weekOfYear)
        }
        
        // 計算總專注時間（分鐘）
        let totalFocusMinutes = Int(weeklySessions.reduce(0) { $0 + $1.duration } / 60)
        
        // 計算完成的番茄鐘數（至少20分鐘且完成狀態）
        let completedPomodoros = weeklySessions.filter { session in
            session.status == .completed && session.duration >= 1200
        }.count
        
        // 計算每日專注時間（週一到週五）
        var dailyFocusMinutes: [Int] = []
        let weekday = calendar.component(.weekday, from: now)
        let daysFromMonday = (weekday == 1 ? 6 : weekday - 2)  // 週日=1, 週一=2
        
        for dayOffset in 0..<5 {  // 週一到週五
            let targetDate = calendar.date(byAdding: .day, value: dayOffset - daysFromMonday, to: now)!
            
            // 篩選該天的會話
            let daySessions = weeklySessions.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: targetDate)
            }
            
            // 計算該天的總時長（分鐘）
            let totalSeconds = daySessions.reduce(0.0) { $0 + $1.duration }
            let dayMinutes = Int(totalSeconds / 60)
            
            dailyFocusMinutes.append(dayMinutes)
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
}

// MARK: - 數據模型
struct WeeklyAnalytics {
    let completedTasks: Int
    let totalTasks: Int
    let completionRate: Double
    let totalFocusMinutes: Int
    let completedPomodoros: Int
    let dailyFocusMinutes: [Int]  // [Mon, Tue, Wed, Thu, Fri]
}

// MARK: - 本週表現卡片
struct WeeklyPerformanceCard: View {
    let data: WeeklyAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 標題
            Text("本週表現分析")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            HStack(spacing: 40) {
                // 左側：圓環進度
                ZStack {
                    // 背景環
                    Circle()
                        .stroke(Color.white.opacity(0.1), lineWidth: 12)
                        .frame(width: 120, height: 120)
                    
                    // 進度環（雙色）
                    Circle()
                        .trim(from: 0, to: data.completionRate)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "5DD3C6"), Color(hex: "4A90E2")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(duration: 1.0), value: data.completionRate)
                    
                    // 百分比文字
                    VStack(spacing: 4) {
                        Text("\(Int(data.completionRate * 100))%")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(data.completedTasks)/\(data.totalTasks) Tasks")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                // 右側：總體任務完成度
                VStack(alignment: .leading, spacing: 16) {
                    Text("總體任務完成度")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    // 完成任務
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(Color(hex: "5DD3C6"))
                        Text("完成任務")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                    
                    // 待含任務
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .foregroundColor(Color(hex: "FFB84D"))
                        Text("待含任務")
                            .font(.subheadline)
                            .foregroundColor(.white)
                    }
                }
                
                Spacer()
            }
        }
        .padding(24)
        .background(Color(hex: "2C3544"))
        .cornerRadius(16)
    }
}

// MARK: - 專注數據卡片
struct FocusDataCard: View {
    let data: WeeklyAnalytics
    
    private var maxMinutes: Int {
        data.dailyFocusMinutes.max() ?? 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // 標題行
            HStack {
                Text("專注數據")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // 警告標籤（如果本週專注時間為0）
                if data.totalFocusMinutes == 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                        Text("未投入專注時間")
                            .font(.caption)
                    }
                    .foregroundColor(Color(hex: "FF6B6B"))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "FF6B6B").opacity(0.2))
                    .cornerRadius(8)
                }
            }
            
            // 柱狀圖
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(0..<5, id: \.self) { index in
                    VStack(spacing: 8) {
                        // 柱子
                        ZStack(alignment: .bottom) {
                            // 背景柱
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(width: 50, height: 120)
                            
                            // 數據柱
                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "4A90E2"), Color(hex: "5DD3C6")],
                                        startPoint: .bottom,
                                        endPoint: .top
                                    )
                                )
                                .frame(
                                    width: 50,
                                    height: maxMinutes > 0 ?
                                        CGFloat(data.dailyFocusMinutes[index]) / CGFloat(maxMinutes) * 120 : 0
                                )
                                .animation(.spring(duration: 0.8, bounce: 0.3).delay(Double(index) * 0.1), value: data.dailyFocusMinutes)
                        }
                        
                        // 星期標籤
                        Text(["一", "二", "三", "四", "五"][index])
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            
            // 底部統計
            HStack(spacing: 40) {
                // 本週投入專注時間
                VStack(alignment: .leading, spacing: 4) {
                    Text("本週投入專注時間")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(data.totalFocusMinutes)分鐘")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                // Completed Pomodoros
                VStack(alignment: .leading, spacing: 4) {
                    Text("Completed Pomodoros")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(data.completedPomodoros)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(24)
        .background(Color(hex: "2C3544"))
        .cornerRadius(16)
    }
}

#Preview {
    NavigationView {
        WeeklyStatsView()
            .environmentObject(TaskViewModel())
    }
}
