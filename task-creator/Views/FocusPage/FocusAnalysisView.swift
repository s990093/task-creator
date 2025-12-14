import SwiftUI

struct FocusAnalysisView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTimeRange = 0 // 0: Day, 1: Week, 2: Month, 3: Year
    
    var body: some View {
        ZStack {
            Color(hex: "FDF6E3").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.down")
                            .font(.title3)
                            .foregroundColor(Color(hex: "5D4037"))
                    }
                    Spacer()
                    Text("專注統計")
                        .font(.headline)
                        .foregroundColor(Color(hex: "5D4037"))
                    Spacer()
                    // Placeholder for balance
                    Image(systemName: "chevron.down")
                        .font(.title3)
                        .opacity(0)
                }
                .padding()
                
                // Time Range Selector
                HStack(spacing: 0) {
                    TimeRangeButton(title: "日", isSelected: selectedTimeRange == 0) { selectedTimeRange = 0 }
                    TimeRangeButton(title: "周", isSelected: selectedTimeRange == 1) { selectedTimeRange = 1 }
                    TimeRangeButton(title: "月", isSelected: selectedTimeRange == 2) { selectedTimeRange = 2 }
                    TimeRangeButton(title: "年", isSelected: selectedTimeRange == 3) { selectedTimeRange = 3 }
                }
                .padding(4)
                .background(Color(hex: "EFEBE9"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Summary Cards
                        HStack(spacing: 12) {
                            AnalysisCard(title: "累計番茄數", value: "\(totalPomodoros)", icon: "circle.grid.cross.fill", color: .orange)
                            AnalysisCard(title: "累計專注天數", value: "\(totalFocusDays)", icon: "calendar", color: .brown)
                        }
                        
                        HStack(spacing: 12) {
                            AnalysisCard(title: "今日專注", value: todayFocusTime, icon: "clock.fill", color: .blue)
                            AnalysisCard(title: "累計專注時長", value: totalFocusTime, icon: "hourglass", color: .purple)
                        }
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: 16) {
                            Text("專注分佈")
                                .font(.headline)
                                .foregroundColor(Color(hex: "5D4037"))
                            
                            ForEach(categoryStats, id: \.category) { stat in
                                CategoryProgressRow(
                                    category: stat.category,
                                    percentage: stat.percentage,
                                    timeString: stat.timeString,
                                    color: stat.category.color
                                )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var totalPomodoros: Int {
        viewModel.focusSessions.filter { $0.status == .completed }.count
    }
    
    var totalFocusDays: Int {
        let dates = viewModel.focusSessions.map { Calendar.current.startOfDay(for: $0.startTime) }
        return Set(dates).count
    }
    
    var todayFocusTime: String {
        let seconds = viewModel.focusSessions
            .filter { Calendar.current.isDateInToday($0.startTime) && $0.status == .completed }
            .reduce(0) { $0 + $1.duration }
        return formatTime(seconds)
    }
    
    var totalFocusTime: String {
        let seconds = viewModel.focusSessions
            .filter { $0.status == .completed }
            .reduce(0) { $0 + $1.duration }
        return formatTime(seconds)
    }
    
    var categoryStats: [(category: Category, percentage: Double, timeString: String)] {
        let completedSessions = viewModel.focusSessions.filter { $0.status == .completed }
        let totalSeconds = completedSessions.reduce(0) { $0 + $1.duration }
        
        guard totalSeconds > 0 else { return [] }
        
        var stats: [(Category, Double, String)] = []
        
        for category in viewModel.categories {
            let categorySeconds = completedSessions
                .filter { $0.category.id == category.id }
                .reduce(0) { $0 + $1.duration }
            
            if categorySeconds > 0 {
                let percentage = categorySeconds / totalSeconds
                stats.append((category, percentage, formatTime(categorySeconds)))
            }
        }
        
        return stats.sorted { $0.1 > $1.1 }
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m"
        }
    }
}

struct TimeRangeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? Color(hex: "5D4037") : Color(hex: "A1887F"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.clear)
                .cornerRadius(16)
                .shadow(color: isSelected ? Color.black.opacity(0.1) : .clear, radius: 2, x: 0, y: 1)
        }
    }
}

struct AnalysisCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(Color(hex: "8D6E63"))
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "5D4037"))
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct CategoryProgressRow: View {
    let category: Category
    let percentage: Double
    let timeString: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            // Percentage Badge
            Text("\(Int(percentage * 100))%")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(color)
                .cornerRadius(12)
            
            // Bar
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.name)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "5D4037"))
                    Spacer()
                    Text(timeString)
                        .font(.caption)
                        .foregroundColor(Color(hex: "8D6E63"))
                }
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(hex: "EFEBE9"))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(color)
                            .frame(width: geo.size.width * CGFloat(percentage), height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
    }
}

#Preview {
    FocusAnalysisView()
        .environmentObject(TaskViewModel())
}
