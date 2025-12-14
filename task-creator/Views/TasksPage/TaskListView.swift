import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    // Input State
    @State private var newTaskTitle = ""
    @State private var selectedType: TaskType = TaskType.defaults.first!
    @State private var selectedCategory: Category = Category(name: "待定", icon: "tag", colorHex: "8E8E93")
    @State private var selectedPriority: Priority = .normal
    @State private var selectedDate = Date()
    @State private var customCategoryName = "" // Kept for safety, though likely unused
    @State private var showCreateSheet = false // FAB triggers sheet instead
    @State private var showManagementSheet = false // Show category management
    
    // 依 Category 分組的任務（僅用於顯示）
    private var tasksByCategory: [(category: Category, tasks: [Task])] {
        viewModel.categories.map { category in
            (category, viewModel.tasks.filter { $0.category.id == category.id })
        }
    }
    
    var body: some View {
        ZStack {
            // Deep Blue-Gray Gradient Background
            LinearGradient(
                colors: [Color(hex: "1C2833"), Color(hex: "2C3E50")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.title3)
                        .foregroundColor(.cyan)
                    Text("我的看板")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Category Management Button
                    Button {
                        showManagementSheet = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.trailing, 8)
                    
                    // Search Icon (Future feature)
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    // Profile Icon
                    Circle()
                        .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 36, height: 36)
                        .padding(.leading, 8)
                }
                .padding()
                
                // Boards in a single vertical list
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 20) {
                        ForEach(tasksByCategory, id: \.category) { entry in
                            // 若該科目暫無任何任務，可選擇隱藏或顯示空狀態
                            if !entry.tasks.isEmpty {
                                BoardSectionView(category: entry.category, tasks: entry.tasks)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // Space for FAB and Tab Bar
                }
            }
            
            // FAB (Floating Action Button)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: { showCreateSheet = true }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(
                                LinearGradient(
                                    colors: [Color.cyan, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                            .shadow(color: Color.cyan.opacity(0.4), radius: 15, x: 0, y: 8)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 90) // Above tab bar
                }
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            CreateTaskSheet(
                newTaskTitle: $newTaskTitle,
                selectedType: $selectedType,
                selectedCategory: $selectedCategory,
                selectedPriority: $selectedPriority,
                selectedDate: $selectedDate,
                customCategoryName: $customCategoryName,
                onSave: addTask
            )
        }
        .sheet(isPresented: $showManagementSheet) {
            CategoryManagementView()
        }
        .onAppear {
            if let first = viewModel.categories.first {
                selectedCategory = first
            }
        }
    }
    
    func addTask() {
        guard !newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        // customCategoryName is no longer used     with dynamic categories, but keeping signature compatible if needed
        viewModel.addTask(
            title: newTaskTitle,
            type: selectedType,
            category: selectedCategory,
            priority: selectedPriority,
            dueDate: selectedDate
        )
        newTaskTitle = ""
        customCategoryName = ""
        showCreateSheet = false
    }
}

// MARK: - Board Section (單一科目的看板區塊)
struct BoardSectionView: View {
    let category: Category
    let tasks: [Task]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(spacing: 8) {
                // Category Color Dot
                Circle()
                    .fill(category.color)
                    .frame(width: 8, height: 8)
                
                // Category Icon
                Image(systemName: category.icon)
                    .font(.caption)
                    .foregroundColor(category.color)
                
                // Category Name
                Text(category.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Task Count Badge
                Text("\(tasks.count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(category.color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(category.color.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 12)
            
                // Tasks in Board
            if tasks.isEmpty {
                // Empty State
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title)
                        .foregroundColor(.white.opacity(0.3))
                    Text("暫無任務")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(tasks) { task in
                        TaskCardView(task: task)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Create Task Sheet
struct CreateTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    @Binding var newTaskTitle: String
    @Binding var selectedType: TaskType
    @Binding var selectedCategory: Category
    @Binding var selectedPriority: Priority
    @Binding var selectedDate: Date
    @Binding var customCategoryName: String
    
    let onSave: () -> Void
    
    @State private var isPolishing: Bool = false
    @State private var showManagementSheet: Bool = false
    @AppStorage("ai_polish_enabled") private var aiPolishEnabled: Bool = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1C2833"), Color(hex: "2C3E50")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Form {
                    Section("任務資訊") {
                        // AI Polish Setting
                        Toggle(isOn: $aiPolishEnabled) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                    .foregroundColor(.purple)
                                Text("啟用 AI 潤色")
                            }
                        }
                        .tint(.purple)
                        
                        // Title field with AI polish button
                        HStack {
                            TextField("任務標題", text: $newTaskTitle)
                            
                            if aiPolishEnabled {
                                Button {
                                    polishTitle()
                                } label: {
                                    if isPolishing {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "wand.and.stars")
                                            .foregroundColor(.purple)
                                    }
                                }
                                .disabled(isPolishing || newTaskTitle.isEmpty)
                            }
                        }
                        
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
                        
                        // Type Picker
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
                        
                        DatePicker("截止日期", selection: $selectedDate, displayedComponents: .date)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("建立新任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("新增") {
                        saveTask()
                    }
                    .disabled(newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showManagementSheet) {
                CategoryManagementView()
            }
        }
    }
    
    private func polishTitle() {
        guard !newTaskTitle.isEmpty else { return }
        isPolishing = true
        
        _Concurrency.Task {
            do {
                let polished = try await viewModel.polishTaskTitle(newTaskTitle)
                await MainActor.run {
                    withAnimation {
                        newTaskTitle = polished
                        isPolishing = false
                    }
                }
            } catch {
                print("Polishing failed: \(error)")
                await MainActor.run {
                    isPolishing = false
                }
            }
        }
    }
    
    private func saveTask() {
        onSave()
    }
}
    

#Preview {
    TaskListView()
        .environmentObject(TaskViewModel())
}
