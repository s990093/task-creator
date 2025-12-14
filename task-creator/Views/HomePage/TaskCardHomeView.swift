import SwiftUI

struct TaskCardHomeView: View {
    let task: Task
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private var taskProgress: Double {
        task.completed ? 1.0 : 0.6 // Mock progress for demo
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "34495E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(task.completed ? Color(hex: "30D158") : Color.clear, lineWidth: 2)
                )
            
            VStack(alignment: .leading, spacing: 12) {
                // Top Row: Category Tag + Menu
                HStack {
                    // Category Tag
                    Text(task.category.name)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(task.category.color)
                        .cornerRadius(6)
                    
                    Spacer()
                    
                    // Three Dots Menu
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("編輯", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("刪除", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.white.opacity(0.6))
                            .rotationEffect(.degrees(90))
                            .padding(8)
                    }
                }
                
                // Task Title
                Text(task.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        // Track
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 6)
                        
                        // Progress
                        Capsule()
                            .fill(Color(hex: "30D158"))
                            .frame(width: geo.size.width * taskProgress, height: 6)
                            .animation(.spring(), value: taskProgress)
                    }
                }
                .frame(height: 6)
                
                // Bottom Row: Completion Badge + Date
                HStack {
                    // Completion Badge
                    if task.completed {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundColor(Color(hex: "30D158"))
                            Text("已完成")
                                .font(.caption)
                                .foregroundColor(Color(hex: "30D158"))
                        }
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "circle")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            Text("待完成")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    
                    Spacer()
                    
                    // Due Date
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(task.dueDate.formatted(.dateTime.month().day()))
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(16)
        }
        .contentShape(Rectangle()) // Make entire card tappable
        .onTapGesture {
            withAnimation(.spring()) {
                viewModel.toggleCompletion(id: task.id)
            }
        }
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

// Edit Sheet for Task
struct TaskEditSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    let task: Task
    @State private var title: String
    @State private var selectedCategory: Category
    @State private var selectedPriority: Priority
    @State private var selectedType: TaskType
    @State private var dueDate: Date
    @State private var showManagementSheet: Bool = false
    
    init(task: Task) {
        self.task = task
        _title = State(initialValue: task.title)
        _selectedCategory = State(initialValue: task.category)
        _selectedPriority = State(initialValue: task.priority)
        _selectedType = State(initialValue: task.type)
        _dueDate = State(initialValue: task.dueDate)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                Form {
                    Section("任務資訊") {
                        TextField("任務標題", text: $title)
                        
                        // Category Picker with Management Link
                        VStack(alignment: .leading) {
                            Picker("類別", selection: $selectedCategory) {
                                ForEach(viewModel.categories) { category in
                                    HStack {
                                        Image(systemName: category.icon)
                                        Text(category.name)
                                    }
                                    .tag(category)
                                }
                            }
                            
                            Button(action: { showManagementSheet = true }) {
                                Text("管理類別...")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                            .padding(.leading, 4)
                        }
                        
                        Picker("類型", selection: $selectedType) {
                            ForEach(viewModel.taskTypes) { type in
                                HStack {
                                    Image(systemName: type.icon)
                                    Text(type.name)
                                }
                                .tag(type)
                            }
                        }
                        
                        Picker("優先級", selection: $selectedPriority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                        
                        DatePicker("截止日期", selection: $dueDate, displayedComponents: .date)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("編輯任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showManagementSheet) {
                CategoryManagementView()
            }
        }
    }
    
    func saveChanges() {
        var updatedTask = task
        updatedTask.title = title
        updatedTask.category = selectedCategory
        updatedTask.priority = selectedPriority
        updatedTask.type = selectedType
        updatedTask.dueDate = dueDate
        
        viewModel.updateTask(updatedTask)
    }
}
