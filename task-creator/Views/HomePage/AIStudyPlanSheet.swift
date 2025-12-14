import SwiftUI

struct AIStudyPlanSheet: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var subject: String = ""
    @State private var goal: String = ""
    @State private var isGenerating: Bool = false
    @State private var generatedTasks: [String] = []
    @State private var errorMessage: String?
    @State private var addedTaskTitles: Set<String> = []
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "151B2B"), Color(hex: "101322")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI 智能計畫")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Text("告訴我你想讀什麼，我幫你安排今日任務！")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                }
                
                // Input fields
                VStack(alignment: .leading, spacing: 12) {
                    Text("科目")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    TextField("例如：數學、英文", text: $subject)
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                    
                    Text("當前目標")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 4)
                    
                    TextField("例如：準備下週二的模擬考", text: $goal)
                        .padding()
                        .background(Color.white.opacity(0.06))
                        .cornerRadius(14)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.12), lineWidth: 1)
                        )
                }
                
                // Generate button
                Button(action: {
                    _Concurrency.Task {
                        await generatePlan()
                    }
                }) {
                    HStack {
                        if isGenerating {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isGenerating ? "AI 正在思考..." : "生成今日任務")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .shadow(color: Color.purple.opacity(0.5), radius: 16, x: 0, y: 10)
                }
                .disabled(isGenerating || subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity((isGenerating || subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.7 : 1)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red.opacity(0.8))
                }
                
                // Suggested tasks
                if !generatedTasks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("建議任務（點擊加入）")
                                .font(.headline)
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(generatedTasks.indices, id: \.self) { index in
                                    let title = generatedTasks[index]
                                    let isAdded = addedTaskTitles.contains(title)
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(title)
                                                .font(.body.weight(.semibold))
                                                .foregroundColor(.white)
                                            Text(isAdded ? "已加入今日任務" : "點擊「+」即可加入到今日任務")
                                                .font(.caption)
                                                .foregroundColor(isAdded ? Color.green.opacity(0.8) : .white.opacity(0.5))
                                        }
                                        Spacer()
                                        
                                        Button {
                                            addTaskFromSuggestion(title: title)
                                        } label: {
                                            Image(systemName: isAdded ? "checkmark" : "plus")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 32, height: 32)
                                                .background(isAdded ? Color.green : Color.blue)
                                                .clipShape(Circle())
                                        }
                                        .disabled(isAdded)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                } else {
                    Spacer()
                }
            }
            .padding(24)
        }
    }
    
    private func addTaskFromSuggestion(title: String) {
        let category = categoryFromSubject(subject)
        viewModel.addTask(title: title, type: TaskType.defaults.first!, category: category, priority: .normal)
        addedTaskTitles.insert(title)
    }
    
    private func categoryFromSubject(_ text: String) -> Category {
        let lower = text.lowercased()
        
        // 1. Try to match existing category names
        if let match = viewModel.categories.first(where: { lower.contains($0.name.lowercased()) }) {
            return match
        }
        
        // 2. Fallback for common keywords mapping to default categories
        if lower.contains("math") {
            return viewModel.categories.first { $0.name == "數學" } ?? viewModel.categories.first ?? Category.defaults.first!
        } else if lower.contains("english") || lower.contains("eng") {
            return viewModel.categories.first { $0.name == "英文" } ?? viewModel.categories.first ?? Category.defaults.first!
        } else if lower.contains("chinese") {
            return viewModel.categories.first { $0.name == "國文" } ?? viewModel.categories.first ?? Category.defaults.first!
        }
        
        // 3. Default to "Other" or the last category
        return viewModel.categories.first { $0.name == "其他" } ?? viewModel.categories.last ?? Category.defaults.last!
    }
    
    @MainActor
    private func generatePlan() async {
        guard !subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        isGenerating = true
        errorMessage = nil
        generatedTasks = []
        
        do {
            let tasks = try await viewModel.generateAIStudyTasks(subject: subject, goal: goal)
            withAnimation {
                generatedTasks = tasks
            }
        } catch {
            errorMessage = "生成任務時發生錯誤，請稍後再試一次。"
            print("AI study plan error: \(error)")
        }
        
        isGenerating = false
    }
}

#Preview {
    AIStudyPlanSheet()
        .environmentObject(TaskViewModel())
}


