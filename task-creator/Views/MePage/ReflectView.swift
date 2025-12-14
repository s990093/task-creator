import SwiftUI
import _Concurrency

struct ReflectView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var selectedMood: Mood = .neutral
    @State private var reflectionText: String = ""
    @State private var analysisResult: String?
    @State private var isAnalyzing: Bool = false
    
    private let aiService = AIService()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Image(systemName: "pencil.tip.crop.circle")
                        .font(.title2)
                        .foregroundColor(.purple)
                    Text("每日反思")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Input Card
                VStack(spacing: 20) {
                    Text("今天過得怎麼樣？")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Mood Picker
                    HStack(spacing: 30) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Button(action: { selectedMood = mood }) {
                                Text(mood.rawValue)
                                    .font(.system(size: 40))
                                    .padding(10)
                                    .background(
                                        Circle()
                                            .stroke(selectedMood == mood ? mood.color : Color.clear, lineWidth: 3)
                                    )
                                    .scaleEffect(selectedMood == mood ? 1.2 : 1.0)
                                    .animation(.spring(), value: selectedMood)
                            }
                        }
                    }
                    
                    // Text Editor
                    ZStack(alignment: .topLeading) {
                        if reflectionText.isEmpty {
                            Text("例如：英文單字背得比較慢，但數學作業準時寫完了...")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(12)
                        }
                        
                        TextEditor(text: $reflectionText)
                            .frame(height: 120)
                            .padding(4)
                            .scrollContentBackground(.hidden)
                            .background(Color(hex: "0F172A"))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }
                    
                    // Submit Button
                    Button(action: saveReflection) {
                        HStack {
                            Text("記錄下來")
                                .fontWeight(.bold)
                            Image(systemName: "pencil")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .opacity(reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1)
                }
                .padding(20)
                .background(Color(hex: "1E293B"))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // AI Analysis Section
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "brain.head.profile")
                            .foregroundColor(.cyan)
                        Text("AI 每日分析")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    .padding(.horizontal)
                    
                    if let result = analysisResult {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(result)
                                .font(.body)
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            HStack {
                                Button(action: {
                                    UIPasteboard.general.string = result
                                }) {
                                    Label("複製", systemImage: "doc.on.doc")
                                        .font(.caption)
                                        .foregroundColor(.cyan)
                                }
                                
                                Spacer()
                                
                                Button(action: { analysisResult = nil }) {
                                    Text("清除")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.top, 8)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(hex: "1E293B"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else {
                        Button(action: performAnalysis) {
                            HStack {
                                if isAnalyzing {
                                    ProgressView()
                                        .tint(.white)
                                        .padding(.trailing, 8)
                                    Text("分析中...")
                                } else {
                                    Image(systemName: "wand.and.stars")
                                    Text("生成今日分析")
                                }
                            }
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isAnalyzing)
                        .padding(.horizontal)
                    }
                }
                
                // History
                VStack(alignment: .leading, spacing: 16) {
                    Text("歷史紀錄")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.reflections) { reflection in
                        HStack(alignment: .top, spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(reflection.date.formatted(.dateTime.year().month().day()))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(reflection.content)
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .lineLimit(3)
                            }
                            
                            Spacer()
                            
                            Text(reflection.mood.rawValue)
                                .font(.title2)
                        }
                        .padding()
                        .background(Color(hex: "1E293B"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                
                Spacer().frame(height: 80)
            }
        }
    }
    
    func saveReflection() {
        guard !reflectionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.addReflection(mood: selectedMood, content: reflectionText)
        reflectionText = ""
        selectedMood = .neutral
        
        // Dismiss keyboard
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func performAnalysis() {
        isAnalyzing = true
        // Explicitly use _Concurrency.Task to avoid conflict with Task model
        _Concurrency.Task {
            do {
                let result = try await aiService.analyzePerformance(
                    tasks: viewModel.tasks,
                    focusSessions: viewModel.focusSessions
                )
                
                await MainActor.run {
                    withAnimation {
                        self.analysisResult = result
                        self.isAnalyzing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.analysisResult = "分析失敗：\(error.localizedDescription)"
                    self.isAnalyzing = false
                }
            }
        }
    }
    
}

#Preview {
    ZStack {
        AppTheme.background.ignoresSafeArea()
        ReflectView()
            .environmentObject(TaskViewModel())
    }
}
