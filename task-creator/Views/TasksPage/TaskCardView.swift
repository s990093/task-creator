import SwiftUI

struct TaskCardView: View {
    let task: Task
    var namespace: Namespace.ID?
    
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    // Determine task status based on completion and date
    private var taskStatus: TaskStatus {
        let calendar = Calendar.current
        let todayStart = calendar.startOfDay(for: Date())
        let dueDayStart = calendar.startOfDay(for: task.dueDate)
        
        // 已完成優先
        if task.completed {
            return .completed
        }
        
        // 只要「截止日期」在今天之前的日期，才算逾期
        if dueDayStart < todayStart {
            return .overdue
        }
        
        // 今天或未來的日期，都視為進行中 / 未開始
        return .pending
    }
    
    enum TaskStatus {
        case completed
        case pending
        case overdue
        
        var color: Color {
            switch self {
            case .completed: return Color(hex: "30D158") // Green
            case .pending: return Color(hex: "FFD60A") // Yellow
            case .overdue: return Color(hex: "FF453A") // Red
            }
        }
        
        var label: String {
            switch self {
            case .completed: return "✅ 已完成"
            case .pending: return "⏳ 進行中"
            case .overdue: return "❗逾期"
            }
        }
        
        var icon: String {
            switch self {
            case .completed: return "checkmark.circle.fill"
            case .pending: return "clock.fill"
            case .overdue: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            // Left Color Bar (Category Identifier)
            Rectangle()
                .fill(task.category.color)
                .frame(width: 4)
            
            // Card Content
            VStack(alignment: .leading, spacing: 12) {
                // Top: Category Icon + Name + Menu
                HStack {
                    // Category Icon + Name
                    HStack(spacing: 6) {
                        Image(systemName: task.category.icon)
                            .font(.caption)
                            .foregroundColor(task.category.color)
                        
                        Text(task.category.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // More Options Menu
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("編輯", systemImage: "pencil")
                        }
                        
                        Button {
                            withAnimation(.spring()) {
                                viewModel.toggleCompletion(id: task.id)
                            }
                        } label: {
                            Label(task.completed ? "標記未完成" : "標記完成", systemImage: task.completed ? "circle" : "checkmark.circle")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.body)
                    }
                }
                
                // Task Title
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                // Status Capsule + Due Date
                HStack {
                    // Status Capsule Badge
                    HStack(spacing: 4) {
                        Image(systemName: taskStatus.icon)
                            .font(.caption2)
                        Text(taskStatus.label)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(taskStatus.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(taskStatus.color.opacity(0.15))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(taskStatus.color.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer()
                    
                    // Due Date
                    Text(task.dueDate.formatted(.dateTime.month().day()))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(12)
        }
        .background(Color(hex: "2C3544")) // Slightly lighter card background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
        .sheet(isPresented: $showEditSheet) {
            TaskEditSheet(task: task)
        }
        .alert("刪除任務", isPresented: $showDeleteAlert) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                withAnimation {
                    viewModel.deleteTask(id: task.id)
                }
            }
        } message: {
            Text("確定要刪除「\(task.title)」嗎？")
        }
    }
}
