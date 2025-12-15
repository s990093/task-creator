import SwiftUI

struct QuickTaskCreationSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var taskTitle: String = ""
    @State private var selectedPriority: Priority = .normal
    
    // Default category for "今日任務"
    private let todayCategory = "今日任務"
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundGradient
                contentView
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color(hex: "5B7C99"), Color(hex: "34495E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var contentView: some View {
        VStack(spacing: 24) {
            headerSection
            formSection
            Spacer()
            addButton
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "folder.fill")
                .font(.system(size: 50))
                .foregroundColor(.white)
            
            Text("今日任務")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("快速添加任務到今日類別")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.top, 20)
    }
    
    private var formSection: some View {
        VStack(spacing: 16) {
            taskTitleField
            prioritySelection
            categoryDisplay
        }
        .padding(.horizontal, 20)
    }
    
    private var taskTitleField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("任務名稱")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("輸入任務內容...", text: $taskTitle)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .foregroundColor(.white)
        }
    }
    
    private var prioritySelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("優先級")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 12) {
                ForEach(Priority.allCases, id: \.self) { priority in
                    priorityButton(for: priority)
                }
            }
        }
    }
    
    private func priorityButton(for priority: Priority) -> some View {
        Button {
            selectedPriority = priority
        } label: {
            HStack {
                Image(systemName: selectedPriority == priority ? "checkmark.circle.fill" : "circle")
                Text(priority.rawValue)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                selectedPriority == priority
                    ? Color.white.opacity(0.3)
                    : Color.white.opacity(0.1)
            )
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    private var categoryDisplay: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("類別")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Image(systemName: "folder.fill")
                Text(todayCategory)
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.caption)
            }
            .padding()
            .background(Color.white.opacity(0.15))
            .foregroundColor(.white.opacity(0.7))
            .cornerRadius(12)
        }
    }
    
    private var addButton: some View {
        Button {
            addTask()
        } label: {
            Text("添加任務")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(addButtonBackground)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 6)
        }
        .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
    
    private var addButtonBackground: some ShapeStyle {
        if taskTitle.trimmingCharacters(in: .whitespaces).isEmpty {
            return AnyShapeStyle(Color.gray)
        } else {
            return AnyShapeStyle(LinearGradient(
                colors: [Color.green, Color.teal],
                startPoint: .leading,
                endPoint: .trailing
            ))
        }
    }
    
    private func addTask() {
        guard !taskTitle.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        // Find the "今日任務" category (must exist in defaults)
        guard let category = viewModel.categories.first(where: { $0.name == todayCategory }) else {
            print("Error: '今日任務' category not found in categories")
            return
        }
        
        // Get default task type
        var taskType = viewModel.taskTypes.first
        if taskType == nil {
            let defaultType = TaskType(name: "一般", icon: "circle", isSystem: true)
            viewModel.taskTypes.append(defaultType)
            taskType = defaultType
        }
        
        // Create the task with today's date
        let newTask = Task(
            title: taskTitle,
            type: taskType!,
            category: category,
            priority: selectedPriority,
            day: nil, // Inbox
            dueDate: Date() // Set to today
        )
        
        viewModel.addTask(newTask)
        
        // Dismiss the sheet
        dismiss()
    }
}

#Preview {
    QuickTaskCreationSheet()
        .environmentObject(TaskViewModel())
}
