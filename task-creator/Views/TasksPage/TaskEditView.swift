import SwiftUI

struct TaskEditView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.dismiss) var dismiss
    
    @State var task: Task
    @State private var showDeleteConfirmation = false
    @State private var isPolishing: Bool = false
    @State private var showManagementSheet: Bool = false
    @AppStorage("ai_polish_enabled") private var aiPolishEnabled: Bool = true
    
    var isCreating: Bool = false // True for creating new task, false for editing
    
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
                    
                    // Category picker with custom option
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
                
                // Delete section (only show when editing)
                if !isCreating {
                    Section {
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Text("刪除任務")
                                    .foregroundColor(.red)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isCreating ? "建立新任務" : "編輯任務")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(isCreating ? "新增" : "儲存") {
                        if isCreating {
                            // Add new task
                            viewModel.addTask(
                                title: task.title,
                                type: task.type,
                                category: task.category,
                                priority: task.priority,
                                dueDate: task.dueDate
                            )
                        } else {
                            // Update existing task
                            viewModel.updateTask(task)
                        }
                        dismiss()
                    }
                    .disabled(task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("確定要刪除嗎？", isPresented: $showDeleteConfirmation) {
                Button("刪除", role: .destructive) {
                    viewModel.deleteTask(id: task.id)
                    dismiss()
                }
                Button("取消", role: .cancel) {}
            }
            .sheet(isPresented: $showManagementSheet) {
                CategoryManagementView()
            }
            .onAppear {
                // No custom category initialization needed
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
