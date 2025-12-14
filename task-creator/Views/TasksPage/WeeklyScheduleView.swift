import SwiftUI
import UniformTypeIdentifiers

struct WeeklyScheduleView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Namespace var animation
    
    let days = Day.allCases
    
    var body: some View {
        GeometryReader { geometry in
            let isDesktop = geometry.size.width > 600
            
            ScrollView(isDesktop ? .horizontal : .vertical, showsIndicators: false) {
                if isDesktop {
                    HStack(spacing: 16) {
                        ForEach(days) { day in
                            DayColumn(day: day, namespace: animation)
                                .frame(width: (geometry.size.width - 64) / 5) // Distribute width
                        }
                    }
                    .padding()
                    .frame(minWidth: geometry.size.width, minHeight: geometry.size.height)
                } else {
                    VStack(spacing: 24) {
                        ForEach(days) { day in
                            DayColumn(day: day, namespace: animation)
                        }
                    }
                    .padding()
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }
}

struct DayColumn: View {
    let day: Day
    var namespace: Namespace.ID
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isTargeted = false
    
    var dayTasks: [Task] {
        viewModel.tasks.filter { $0.day == day && !$0.completed }
    }
    
    var busynessColor: Color {
        let count = dayTasks.count
        if count >= 5 {
            return Color(hex: "FF453A") // Red
        } else if count >= 3 {
            return Color(hex: "FF9F0A") // Yellow/Orange
        } else {
            return Color(hex: "30D158") // Green
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Text(day.rawValue.uppercased())
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppTheme.textSecondary)
                    .tracking(1)
                
                Spacer()
                
                // Busyness Indicator
                Circle()
                    .fill(busynessColor)
                    .frame(width: 8, height: 8)
                    .shadow(color: busynessColor.opacity(0.5), radius: 4, x: 0, y: 0) // Glow effect
                
                if !dayTasks.isEmpty {
                    Text("\(dayTasks.count)")
                        .font(.caption)
                        .padding(6)
                        .background(AppTheme.surface)
                        .clipShape(Circle())
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
            .padding(.bottom, 4)
            .padding(.horizontal, 4)
            
            // Task List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(dayTasks) { task in
                        TaskCardView(task: task, namespace: namespace)
                            .onDrag {
                                NSItemProvider(object: task.id as NSString)
                            }
                    }
                }
                .padding(4)
            }
            
            Spacer()
        }
        .padding()
        .background(isTargeted ? AppTheme.surface.opacity(0.5) : AppTheme.surface.opacity(0.3))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isTargeted ? Color.brandBlue : AppTheme.textSecondary.opacity(0.1), lineWidth: isTargeted ? 2 : 1)
        )
        .onDrop(of: [UTType.text], delegate: TaskDropDelegate(day: day, viewModel: viewModel, isTargeted: $isTargeted))
    }
}
