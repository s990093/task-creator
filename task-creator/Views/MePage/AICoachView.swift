import SwiftUI

struct AICoachView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var isAnalyzing = false
    @State private var currentAnalysisText: String?
    @State private var currentStrategyText: String?
    
    private let aiService = AIService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Title for the Tab Content
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.title)
                        .foregroundColor(Color(hex: "FF69B4")) // Hot Pink
                    Text("AI 教練週報")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Main Analysis Card
                VStack(alignment: .leading, spacing: 0) {
                    // Analysis Section
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color(hex: "4F46E5")) // Indigo
                                .cornerRadius(10)
                            
                            Text("本週表現分析")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        if isAnalyzing {
                            // Marquee / Loading Animation
                            MarqueeText(text: "AI 正在分析您的學習數據... 正在生成策略... 請稍候...", font: .body)
                                .frame(height: 60)
                        } else if let analysisText = currentAnalysisText {
                            ColoredMarkdownText(text: analysisText)
                                .font(.body)
                                .lineSpacing(6)
                        } else {
                            Text("尚無本週分析資料，點擊下方按鈕開始生成。")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(24)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 1)
                        .padding(.horizontal, 24)
                    
                    // Strategy Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("下週建議策略")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        if isAnalyzing {
                            PenguinLoadingView()
                                .frame(height: 200)
                        } else if let strategyText = currentStrategyText {
                            Text(strategyText)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineSpacing(6)
                        }
                    }
                    .padding(24)
                }
                .background(
                    LinearGradient(
                        colors: [Color(hex: "312E81"), Color(hex: "1E1B4B")], // Deep Indigo Gradient
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal)
                .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
                
                // Generate Button
                if !isAnalyzing {
                    Button(action: performAnalysis) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("生成最新週報")
                        }
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "4F46E5"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                }
                
                // History List
                VStack(alignment: .leading, spacing: 16) {
                    Text("歷史週報")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                    
                    ForEach(viewModel.aiAnalysisRecords) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.date.formatted(.dateTime.year().month().day()))
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                Text(record.content.prefix(50) + "...")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(hex: "1E293B"))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                Spacer().frame(height: 100)
            }
        }
        .onAppear {
            // Load latest record if exists
            if let latest = viewModel.aiAnalysisRecords.first, Calendar.current.isDateInThisWeek(latest.date) {
                parseResult(latest.content)
            }
        }
    }
    
    func performAnalysis() {
        isAnalyzing = true
        _Concurrency.Task {
            do {
                let result = try await aiService.analyzePerformance(
                    tasks: viewModel.tasks,
                    focusSessions: viewModel.focusSessions
                )
                
                await MainActor.run {
                    withAnimation {
                        parseResult(result)
                        viewModel.addAIAnalysisRecord(content: result)
                        isAnalyzing = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.currentAnalysisText = "分析失敗：\(error.localizedDescription)"
                    self.isAnalyzing = false
                }
            }
        }
    }
    
    func parseResult(_ result: String) {
        let components = result.components(separatedBy: "---")
        if components.count >= 2 {
            self.currentAnalysisText = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
            self.currentStrategyText = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            self.currentAnalysisText = result
            self.currentStrategyText = nil
        }
    }
}


// MARK: - Colored Markdown Text View
struct ColoredMarkdownText: View {
    let text: String
    
    var body: some View {
        buildColoredText()
            .lineSpacing(6)
    }
    
    private func buildColoredText() -> Text {
        var currentText = text
        var result: Text = Text("")
        var isFirst = true
        
        while !currentText.isEmpty {
            // Check for <數字> tag
            if let numberStart = currentText.range(of: "<數字>"),
               let numberEnd = currentText.range(of: "</數字>", range: numberStart.upperBound..<currentText.endIndex) {
                
                // Add text before tag
                if numberStart.lowerBound > currentText.startIndex {
                    let beforeText = String(currentText[..<numberStart.lowerBound])
                    if isFirst {
                        result = Text(beforeText).foregroundColor(.white.opacity(0.9))
                        isFirst = false
                    } else {
                        result = result + Text(beforeText).foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Add colored number
                let numberContent = String(currentText[numberStart.upperBound..<numberEnd.lowerBound])
                result = result + Text(numberContent)
                    .foregroundColor(Color(hex: "00D9FF"))
                    .bold()
                
                // Continue with remaining text
                currentText = String(currentText[numberEnd.upperBound...])
                
            } else if let categoryStart = currentText.range(of: "<類別>"),
                      let categoryEnd = currentText.range(of: "</類別>", range: categoryStart.upperBound..<currentText.endIndex) {
                
                // Add text before tag
                if categoryStart.lowerBound > currentText.startIndex {
                    let beforeText = String(currentText[..<categoryStart.lowerBound])
                    if isFirst {
                        result = Text(beforeText).foregroundColor(.white.opacity(0.9))
                        isFirst = false
                    } else {
                        result = result + Text(beforeText).foregroundColor(.white.opacity(0.9))
                    }
                }
                
                // Add colored category
                let categoryContent = String(currentText[categoryStart.upperBound..<categoryEnd.lowerBound])
                result = result + Text(categoryContent)
                    .foregroundColor(Color(hex: "BF5AF2"))
                    .bold()
                
                // Continue with remaining text
                currentText = String(currentText[categoryEnd.upperBound...])
                
            } else {
                // No more tags, add remaining text
                if isFirst {
                    result = Text(currentText).foregroundColor(.white.opacity(0.9))
                } else {
                    result = result + Text(currentText).foregroundColor(.white.opacity(0.9))
                }
                break
            }
        }
        
        return result
    }
}


struct MarqueeText: View {
    let text: String
    let font: Font
    @State private var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(.horizontal, showsIndicators: false) {
                Text(text)
                    .font(font)
                    .foregroundColor(.cyan)
                    .offset(x: offset)
                    .onAppear {
                        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                            offset = -geo.size.width
                        }
                    }
            }
            .disabled(true) // Disable manual scrolling
        }
    }
}

extension Calendar {
    func isDateInThisWeek(_ date: Date) -> Bool {
        return isDate(date, equalTo: Date(), toGranularity: .weekOfYear)
    }
}
