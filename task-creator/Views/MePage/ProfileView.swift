import SwiftUI
import UniformTypeIdentifiers

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var showingExportAlert = false
    @State private var showingImportAlert = false
    @State private var showingImportConfirm = false
    @State private var alertMessage = ""
    @State private var exportURL: URL?
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .opacity(0)
                    
                    Spacer()
                    
                    Text("個人設定")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Profile Card
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Text("我")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("未來的你")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("Lv.5 探索者")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan.opacity(0.2))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.cyan, lineWidth: 1)
                                    )
                                
                                Text("已加入 28 天")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(24)
                    .background(Color(hex: "1E293B"))
                    .cornerRadius(16)
                }
                .padding()
                
                // Settings List
                VStack(spacing: 0) {
                    // Dark Mode
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("深色模式")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .tint(.cyan)
                    }
                    .padding()
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Daily Reminder
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("每日提醒")
                                .foregroundColor(.white)
                            Spacer()
                            Text("20:00")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Export
                    Button(action: exportData) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("匯出學習紀錄")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Import
                    Button(action: { showingImportConfirm = true }) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("匯入學習紀錄")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Logout
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("登出帳號")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .background(Color(hex: "1E293B"))
                .cornerRadius(16)
                .padding()
                
                Spacer()
                
                Text("Digital Coach v1.2.0 • Build 202311")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
        .sheet(isPresented: $showingExportSheet, content: {
            if let url = exportURL {
                ActivityView(activityItems: [url])
            }
        })
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result: result)
        }
        .alert("匯出成功", isPresented: $showingExportAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("匯入結果", isPresented: $showingImportAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .alert("確認匯入", isPresented: $showingImportConfirm) {
            Button("取消", role: .cancel) { }
            Button("確定", role: .destructive) {
                showingImportPicker = true
            }
        } message: {
            Text("匯入將會覆蓋當前所有學習紀錄，此操作無法撤銷。確定要繼續嗎？")
        }
    }
    
    // MARK: - Export Function
    
    private func exportData() {
        let exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "version": "1.0",
            "tasks": viewModel.tasks.map { task in
                [
                    "id": task.id,
                    "title": task.title,
                    "completed": task.completed,
                    "categoryName": task.category.name,
                    "categoryIcon": task.category.icon,
                    "categoryColorHex": task.category.colorHex,
                    "typeName": task.type.name,
                    "typeIcon": task.type.icon,
                    "priority": task.priority.rawValue,
                    "day": task.day?.rawValue ?? "",
                    "dueDate": ISO8601DateFormatter().string(from: task.dueDate),
                    "completedDate": task.completedDate != nil ? ISO8601DateFormatter().string(from: task.completedDate!) : ""
                ]
            },
            "focusSessions": viewModel.focusSessions.map { session in
                [
                    "id": session.id,
                    "categoryName": session.category.name,
                    "categoryIcon": session.category.icon,
                    "categoryColorHex": session.category.colorHex,
                    "duration": session.duration,
                    "startTime": ISO8601DateFormatter().string(from: session.startTime),
                    "endTime": ISO8601DateFormatter().string(from: session.endTime),
                    "status": session.status.rawValue
                ]
            },
            "reflections": viewModel.reflections.map { reflection in
                [
                    "id": reflection.id,
                    "date": ISO8601DateFormatter().string(from: reflection.date),
                    "mood": reflection.mood.rawValue,
                    "content": reflection.content
                ]
            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
            let fileName = "TaskCreator_\(dateFormatter.string(from: Date())).json"
            
            // 使用 Documents 目錄而不是 temp 目錄
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let fileURL = documentsURL.appendingPathComponent(fileName)
            
            // 如果文件已存在，先刪除
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            
            try jsonData.write(to: fileURL)
            
            exportURL = fileURL
            showingExportSheet = true
            
            print("✅ 文件已保存到: \(fileURL.path)")
            
        } catch {
            alertMessage = "匯出失敗：\(error.localizedDescription)"
            showingExportAlert = true
        }
    }
    
    // MARK: - Import Function
    
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            do {
                let data = try Data(contentsOf: url)
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                
                guard let json = json else {
                    alertMessage = "無效的文件格式"
                    showingImportAlert = true
                    return
                }
                
                var importedTasks = 0
                var importedSessions = 0
                var importedReflections = 0
                
                if let tasksData = json["tasks"] as? [[String: Any]] {
                    viewModel.tasks.removeAll()
                    for taskDict in tasksData {
                        if let task = parseTask(from: taskDict) {
                            viewModel.tasks.append(task)
                            importedTasks += 1
                        }
                    }
                }
                
                if let sessionsData = json["focusSessions"] as? [[String: Any]] {
                    viewModel.focusSessions.removeAll()
                    for sessionDict in sessionsData {
                        if let session = parseSession(from: sessionDict) {
                            viewModel.focusSessions.append(session)
                            importedSessions += 1
                        }
                    }
                }
                
                if let reflectionsData = json["reflections"] as? [[String: Any]] {
                    viewModel.reflections.removeAll()
                    for reflectionDict in reflectionsData {
                        if let reflection = parseReflection(from: reflectionDict) {
                            viewModel.reflections.append(reflection)
                            importedReflections += 1
                        }
                    }
                }
                
                alertMessage = "成功匯入 \(importedTasks) 個任務、\(importedSessions) 個專注會話和 \(importedReflections) 個反思記錄"
                showingImportAlert = true
                
            } catch {
                alertMessage = "匯入失敗：\(error.localizedDescription)"
                showingImportAlert = true
            }
            
        case .failure(let error):
            alertMessage = "選擇文件失敗：\(error.localizedDescription)"
            showingImportAlert = true
        }
    }
    
    // MARK: - Parsing Helpers
    
    private func parseTask(from dict: [String: Any]) -> Task? {
        guard let id = dict["id"] as? String,
              let title = dict["title"] as? String,
              let completed = dict["completed"] as? Bool,
              let categoryName = dict["categoryName"] as? String,
              let categoryIcon = dict["categoryIcon"] as? String,
              let categoryColorHex = dict["categoryColorHex"] as? String,
              let typeName = dict["typeName"] as? String,
              let typeIcon = dict["typeIcon"] as? String,
              let priorityRaw = dict["priority"] as? String,
              let dueDateString = dict["dueDate"] as? String,
              let dueDate = ISO8601DateFormatter().date(from: dueDateString),
              let priority = Priority(rawValue: priorityRaw) else {
            return nil
        }
        
        let dayString = dict["day"] as? String ?? ""
        let day = dayString.isEmpty ? nil : Day(rawValue: dayString)
        
        let completedDateString = dict["completedDate"] as? String ?? ""
        let completedDate = completedDateString.isEmpty ? nil : ISO8601DateFormatter().date(from: completedDateString)
        
        let category = Category(name: categoryName, icon: categoryIcon, colorHex: categoryColorHex, isSystem: false)
        let type = TaskType(name: typeName, icon: typeIcon, isSystem: false)
        
        return Task(
            id: id,
            title: title,
            type: type,
            category: category,
            priority: priority,
            day: day,
            completed: completed,
            completedDate: completedDate,
            dueDate: dueDate,
            customCategory: nil
        )
    }
    
    private func parseSession(from dict: [String: Any]) -> FocusSession? {
        guard let id = dict["id"] as? String,
              let categoryName = dict["categoryName"] as? String,
              let categoryIcon = dict["categoryIcon"] as? String,
              let categoryColorHex = dict["categoryColorHex"] as? String,
              let duration = dict["duration"] as? TimeInterval,
              let startTimeString = dict["startTime"] as? String,
              let startTime = ISO8601DateFormatter().date(from: startTimeString),
              let endTimeString = dict["endTime"] as? String,
              let endTime = ISO8601DateFormatter().date(from: endTimeString),
              let statusRaw = dict["status"] as? String,
              let status = FocusStatus(rawValue: statusRaw) else {
            return nil
        }
        
        let category = Category(name: categoryName, icon: categoryIcon, colorHex: categoryColorHex, isSystem: false)
        
        return FocusSession(
            id: id,
            startTime: startTime,
            endTime: endTime,
            duration: duration,
            category: category,
            status: status
        )
    }
    
    private func parseReflection(from dict: [String: Any]) -> Reflection? {
        guard let id = dict["id"] as? String,
              let dateString = dict["date"] as? String,
              let date = ISO8601DateFormatter().date(from: dateString),
              let moodRaw = dict["mood"] as? String,
              let mood = Mood(rawValue: moodRaw),
              let content = dict["content"] as? String else {
            return nil
        }
        
        return Reflection(
            id: id,
            date: date,
            mood: mood,
            content: content
        )
    }
}

// MARK: - Activity View Controller

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    ProfileView()
        .environmentObject(TaskViewModel())
}
