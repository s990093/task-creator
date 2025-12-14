import SwiftUI

struct TaskCreationView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var title: String = ""
    @State private var selectedCategory: Category = Category(name: "待定", icon: "tag", colorHex: "8E8E93")
    @State private var selectedPriority: Priority = .normal
    @State private var isPolishing: Bool = false
    @State private var showDetailedCreation: Bool = false
    @State private var draftTask: Task? = nil
    @State private var showManagementSheet: Bool = false
    
    // Auto-save draft
    @AppStorage("draft_title") private var draftTitle: String = ""
    @AppStorage("ai_polish_enabled") private var aiPolishEnabled: Bool = true
    @State private var showAutoSaveToast = false
    
    var body: some View {
        VStack(spacing: 0) {
            if showAutoSaveToast {
                HStack {
                    Image(systemName: "icloud.and.arrow.up")
                    Text("自動暫存")
                }
                .font(.caption)
                .foregroundColor(AppTheme.textSecondary)
                .padding(.bottom, 4)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            VStack(spacing: 12) {
                // AI Polish Setting Toggle
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.purple)
                        .font(.caption)
                    Text("AI 潤色")
                        .font(.caption)
                        .foregroundColor(AppTheme.textPrimary)
                    Toggle("", isOn: $aiPolishEnabled)
                        .labelsHidden()
                        .tint(.purple)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(AppTheme.surface.opacity(0.5))
                .cornerRadius(12)
                
                // Input Row
                HStack {
                    Image(systemName: "square.and.pencil")
                        .foregroundColor(AppTheme.textSecondary)
                    
                    TextField("新增任務...", text: $title)
                        .foregroundColor(AppTheme.textPrimary)
                        .onChange(of: title) { newValue in
                            draftTitle = newValue
                            if !newValue.isEmpty {
                                withAnimation { showAutoSaveToast = true }
                            } else {
                                withAnimation { showAutoSaveToast = false }
                            }
                        }
                        .accessibilityIdentifier("AddTaskField")
                    
                    // AI Polish Button (only show if enabled)
                    if !title.isEmpty && aiPolishEnabled {
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
                        .disabled(isPolishing)
                    }
                }
                .padding()
                .background(AppTheme.surface)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppTheme.textSecondary.opacity(0.2), lineWidth: 1)
                )
                
                // Controls Row
                HStack {
                    // Category Picker
                    Menu {
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(viewModel.categories) { category in
                                Label(category.name, systemImage: category.icon)
                                    .tag(category)
                            }
                        }
                        
                        Button {
                            showManagementSheet = true
                        } label: {
                            Label("管理類別...", systemImage: "gearshape")
                        }
                    } label: {
                        HStack {
                            Image(systemName: selectedCategory.icon)
                            Text(selectedCategory.name)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedCategory.color.opacity(0.2))
                        .foregroundColor(selectedCategory.color)
                        .cornerRadius(8)
                    }
                    
                    // Priority Picker
                    Menu {
                        Picker("Priority", selection: $selectedPriority) {
                            ForEach(Priority.allCases, id: \.self) { priority in
                                Text(priority.rawValue).tag(priority)
                            }
                        }
                    } label: {
                        HStack {
                            if selectedPriority == .urgent {
                                Image(systemName: "flame.fill")
                            }
                            Text(selectedPriority.rawValue)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedPriority == .urgent ? Color.red.opacity(0.2) : AppTheme.surface)
                        .foregroundColor(selectedPriority == .urgent ? .red : AppTheme.textSecondary)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.textSecondary.opacity(0.2), lineWidth: selectedPriority == .urgent ? 0 : 1)
                        )
                    }
                    
                    Spacer()
                    
                    // Detailed Creation Button
                    Button {
                        openDetailedCreation()
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(width: 36, height: 36)
                            .background(AppTheme.surface)
                            .clipShape(Circle())
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    
                    // Quick Add Button
                    Button(action: submitTask) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(Color.brandBlue)
                            .clipShape(Circle())
                    }
                    .accessibilityIdentifier("QuickAddButton")
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                }
            }
            .padding()
            .background(AppTheme.background.opacity(0.95))
            .cornerRadius(24, corners: [.topLeft, .topRight])
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: -5)
        }
        .onAppear {
            if let first = viewModel.categories.first {
                selectedCategory = first
            }
            // Restore draft
            if !draftTitle.isEmpty {
                title = draftTitle
                showAutoSaveToast = true
            }
        }
        .sheet(isPresented: $showDetailedCreation) {
            if let draft = draftTask {
                TaskDetailedCreationView(initialTask: draft) { task in
                    // Save
                    viewModel.addTask(
                        title: task.title,
                        type: task.type,
                        category: task.category,
                        priority: task.priority,
                        dueDate: task.dueDate
                    )
                    if let day = task.day {
                        viewModel.moveTask(id: viewModel.tasks.last?.id ?? "", to: day)
                    }
                    resetForm()
                    showDetailedCreation = false
                } onCancel: {
                    showDetailedCreation = false
                }
                .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showManagementSheet) {
            CategoryManagementView()
        }
    }
    
    private func submitTask() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        viewModel.addTask(
            title: title,
            type: TaskType.defaults.first!, // Default type for quick add
            category: selectedCategory,
            priority: selectedPriority
        )
        
        // Reset
        title = ""
        draftTitle = ""
        selectedPriority = .normal
        withAnimation { showAutoSaveToast = false }
    }
    
    private func polishTitle() {
        guard !title.isEmpty else { return }
        isPolishing = true
        
        _Concurrency.Task{
            do {
                let polished = try await viewModel.polishTaskTitle(title)
                await MainActor.run {
                    withAnimation {
                        title = polished
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
    
    private func openDetailedCreation() {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Create a draft task with current inputs
        draftTask = Task(
            title: title,
            type: TaskType.defaults.first!, // Default
            category: selectedCategory,
            priority: selectedPriority,
            day: nil
        )
        
        showDetailedCreation = true
    }
    
    private func resetForm() {
        title = ""
        draftTitle = ""
        selectedPriority = .normal
        draftTask = nil
        withAnimation { showAutoSaveToast = false }
    }
}

// MARK: - Detailed Task Creation View
struct TaskDetailedCreationView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    
    let initialTask: Task
    let onSave: (Task) -> Void
    let onCancel: () -> Void
    
    @State private var task: Task
    @State private var isPolishing: Bool = false
    @State private var showManagementSheet: Bool = false
    @AppStorage("ai_polish_enabled") private var aiPolishEnabled: Bool = true
    
    init(initialTask: Task, onSave: @escaping (Task) -> Void, onCancel: @escaping () -> Void) {
        self.initialTask = initialTask
        self.onSave = onSave
        self.onCancel = onCancel
        _task = State(initialValue: initialTask)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("任務內容")) {
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
                        TextField("任務名稱", text: $task.title)
                        
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
                            .disabled(isPolishing || task.title.isEmpty)
                        }
                    }
                    
                    // Category picker
                    VStack(alignment: .leading) {
                        Picker("類別", selection: $task.category) {
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
                    
                    Picker("類型", selection: $task.type) {
                        ForEach(viewModel.taskTypes) { type in
                            HStack {
                                Image(systemName: type.icon)
                                .foregroundColor(.blue)
                                Text(type.name)
                            }
                            .tag(type)
                        }
                    }
                    
                    Picker("優先級", selection: $task.priority) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            Text(priority.rawValue).tag(priority)
                        }
                    }
                    
                    DatePicker("截止日期", selection: $task.dueDate, displayedComponents: .date)
                }
                
                Section(header: Text("排程")) {
                    Picker("移動至", selection: $task.day) {
                        Text("Inbox (待辦)").tag(Optional<Day>.none)
                        ForEach(Day.allCases) { day in
                            Text(day.rawValue).tag(Optional(day))
                        }
                    }
                }
            }
            .navigationTitle("建立新任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onCancel()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("新增") {
                        onSave(task)
                    }
                    .disabled(task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .sheet(isPresented: $showManagementSheet) {
                CategoryManagementView()
            }
        }
    }
    
    private func polishTitle() {
        guard !task.title.isEmpty else { return }
        isPolishing = true
        
        _Concurrency.Task {
            do {
                let polished = try await viewModel.polishTaskTitle(task.title)
                await MainActor.run {
                    withAnimation {
                        task.title = polished
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
}


