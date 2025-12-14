import Foundation

class AIService {
    private let apiKey: String
    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!
    
    private var prompts: Prompts?
    
    init() {
        // Try to load API key from Config.plist (local file, not in git)
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let configDict = NSDictionary(contentsOfFile: configPath) as? [String: Any],
           let apiKey = configDict["OPENAI_API_KEY"] as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
        }
        // Fallback to Info.plist
        else if let apiKey = Bundle.main.object(forInfoDictionaryKey: "OPENAI_API_KEY") as? String, !apiKey.isEmpty {
            self.apiKey = apiKey
        }
        // Fallback to environment variable
        else if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty {
            self.apiKey = apiKey
        }
        // No API key found
        else {
            self.apiKey = ""
            print("⚠️ WARNING: OpenAI API key not found in Config.plist, Info.plist, or environment variables")
        }
        loadPrompts()
    }
    
    private func loadPrompts() {
        guard let url = Bundle.main.url(forResource: "Prompts", withExtension: "json") else {
            print("Error: Prompts.json not found")
            return
        }
        
        do {
            let data = try Data(contentsOf: url)
            self.prompts = try JSONDecoder().decode(Prompts.self, from: data)
        } catch {
            print("Error decoding Prompts.json: \(error)")
        }
    }
    
    func analyzePerformance(tasks: [Task], focusSessions: [FocusSession]) async throws -> String {
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        // 1. Prepare Data Summary
        let completedTasks = tasks.filter { $0.completed }
        let totalFocusTime = focusSessions.reduce(0) { $0 + $1.duration }
        let focusCategories = Dictionary(grouping: focusSessions, by: { $0.category })
            .mapValues { sessions in sessions.reduce(0) { $0 + $1.duration } }
        
        let taskSummary = """
        Total Tasks: \(tasks.count)
        Completed: \(completedTasks.count)
        Completion Rate: \(tasks.isEmpty ? 0 : Int((Double(completedTasks.count) / Double(tasks.count)) * 100))%
        """
        
        let completedSessionsCount = focusSessions.filter { $0.status == .completed }.count
        
        let focusSummary = """
        Total Focus Time: \(Int(totalFocusTime / 60)) minutes
        Completed Pomodoros: \(completedSessionsCount)
        Focus Breakdown: \(focusCategories.map { "\($0.key.name): \(Int($0.value / 60))m" }.joined(separator: ", "))
        """
        
        let prompt = prompts.analyzePerformance.fill([
            "taskSummary": taskSummary,
            "focusSummary": focusSummary
        ])

        // 2. Create Request
        let messages    = [
            ["role": "system", "content": "你是一位樂於助人且充滿動力的生產力教練。"],
            ["role": "user", "content": prompt]
        ]
        
        return try await sendRequest(messages: messages)
    }
    
    // MARK: - Study Plan Generation
    
    /// 根據科目與目標，生成 3 個適合今天完成的具體任務標題
    func generateStudyPlan(subject: String, goal: String) async throws -> [String] {
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        let prompt = prompts.generateStudyPlan.fill([
            "subject": subject,
            "goal": goal
        ])
        
        let messages = [
            ["role": "system", "content": "你是一位專業的 AI 讀書計畫教練，擅長把大目標拆解成今天可以完成的 3 個小任務。"],
            ["role": "user", "content": prompt]
        ]
        
        let content = try await sendRequest(messages: messages)
        
        // Parse lines that look like "1. 任務內容"
        let lines = content
            .split(separator: "\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        let titles: [String] = lines.compactMap { line in
            if let dotIndex = line.firstIndex(of: ".") {
                let titleStart = line.index(after: dotIndex)
                let rawTitle = line[titleStart...].trimmingCharacters(in: .whitespacesAndNewlines)
                return rawTitle.isEmpty ? nil : String(rawTitle)
            } else {
                return line
            }
        }
        
        // 確保最多 3 個任務
        return Array(titles.prefix(3))
    }
    
    // MARK: - Task Polishing
    
    /// 使用 AI 潤色任務標題，使其更具體、更有行動力
    func polishTaskTitle(_ input: String) async throws -> String {
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        let prompt = prompts.polishTaskTitle.fill([
            "input": input
        ])
        
        let messages = [
            ["role": "system", "content": "你是一位擅長優化任務標題的 AI 助手。"],
            ["role": "user", "content": prompt]
        ]
        
        let content = try await sendRequest(messages: messages)
        return content.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Schedule Recognition from Image
    
    /// 從課表圖片中提取課程資訊
    func extractScheduleFromImage(_ imageData: Data) async throws -> [Course] {
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        let base64Image = imageData.base64EncodedString()
        let prompt = prompts.extractScheduleFromImage
        
        let messages: [[String: Any]] = [
            [
                "role": "system",
                "content": "你是一位專業的課表資訊提取助手，擅長從圖片中識別課程表並輸出結構化數據。"
            ],
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": prompt
                    ],
                    [
                        "type": "image_url",
                        "image_url": "data:image/png;base64,\(base64Image)"
                    ]
                ]
            ]
        ]
        
        let content = try await sendRequest(messages: messages, model: "gpt-4o")
        return try parseCourseJSON(content)
    }
    
    // MARK: - AI Assistant Chat
    
    struct ChatResponse: Codable {
        let response: String
        let tasks: [SuggestedTaskJSON]
    }
    
    struct SuggestedTaskJSON: Codable {
        let title: String
        let category: String
        let categoryDetails: CategoryDetailsJSON?
        let priority: String
        
        struct CategoryDetailsJSON: Codable {
            let icon: String
            let colorHex: String
        }
    }

    func chatWithAssistant(
        message: String,
        conversationHistory: ArraySlice<ChatMessage>,
        userContext: UserContext? = nil
    ) async throws -> (response: String, suggestedTasks: [SuggestedTask]) {
        
        // Check for mock mode
        if ProcessInfo.processInfo.arguments.contains("-mockAI") {
            // Simulate network delay
//            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            
            let mockResponse = "這是模擬的 AI 回應！我會建議以下任務："
            let mockTasks = [
                SuggestedTask(title: "完成數學作業", category: "學習", categoryIcon: "function", categoryColor: "FF6B6B", priority: "urgent"),
                SuggestedTask(title: "複習英文單字", category: "學習", categoryIcon: "book.fill", categoryColor: "4ECDC4", priority: "normal")
            ]
            
            return (mockResponse, mockTasks)
        }
        
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        // Use UserProfileManager to get context if not provided
        let context = userContext ?? UserProfileManager.shared.getUserContext()
        
        // Format conversation history
        let historyString = conversationHistory.map { msg in
            let role = msg.role == .user ? "User" : "Assistant"
            return "\(role): \(msg.content)"
        }.joined(separator: "\n")
        
        // Build user context string
        var contextString = "User Identity: \(context.identity ?? "Not provided")\n"
        if let goals = context.goals, !goals.isEmpty {
            contextString += "Goals: \(goals.joined(separator: ", "))\n"
        }
        if let prefs = context.preferences {
            contextString += "Preferences:\n"
            for (key, value) in prefs {
                contextString += "  - \(key): \(value)\n"
            }
        }
        
        // Construct the full prompt
        let fullPrompt = """
        \(prompts.aiAssistantChat)
        
        === USER CONTEXT ===
        \(contextString)
        
        === CONVERSATION HISTORY ===
        \(historyString)
        
        === CURRENT MESSAGE ===
        User: \(message)
        
        Please respond naturally and helpfully.
        """
        
        // 🔍 DEBUG: Print complete prompt
        print("═══════════════════════════════════════")
        print("🤖 SENDING TO AI")
        print("═══════════════════════════════════════")
        print("📋 System Prompt:")
        print(prompts.aiAssistantChat)
        print("\n👤 User Context:")
        print(contextString)
        print("\n💬 Conversation History (\(conversationHistory.count) messages):")
        print(historyString.isEmpty ? "(No history)" : historyString)
        print("\n✉️ Current Message:")
        print(message)
        print("\n📦 Full Prompt Length: \(fullPrompt.count) characters")
        print("═══════════════════════════════════════\n")
        
        let messages = [
            ["role": "system", "content": "你是一位 TaskFlow AI 學習規劃助理。"],
            ["role": "user", "content": fullPrompt]
        ]
        
        let content = try await sendRequest(messages: messages)
        
        // Parse JSON response
        // Clean up markdown code blocks if present
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if jsonString.hasPrefix("```json") {
            jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
        }
        if jsonString.hasPrefix("```") {
            jsonString = jsonString.replacingOccurrences(of: "```", with: "")
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse AI response"])
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: jsonData)
        
        let suggestedTasks = chatResponse.tasks.map { taskJSON in
            SuggestedTask(
                title: taskJSON.title,
                category: taskJSON.category,
                categoryIcon: taskJSON.categoryDetails?.icon,
                categoryColor: taskJSON.categoryDetails?.colorHex,
                priority: taskJSON.priority
            )
        }
        
        return (chatResponse.response, suggestedTasks)
    }
    
    // MARK: - TaskType Generation
    
    struct TaskTypeResponse: Codable {
        let response: String?
        let taskTypes: [TaskTypeJSON]
        let categories: [CategoryJSON]?
    }
    
    struct TaskTypeJSON: Codable {
        let name: String
        let icon: String
        let colorHex: String?
    }
    
    struct CategoryJSON: Codable {
        let name: String
        let icon: String
        let colorHex: String
    }
    
    func generateTaskTypes(userIdentity: String) async throws -> (response: String, taskTypes: [SuggestedTaskType], categories: [Category]) {
        guard let prompts = prompts else { throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Prompts not loaded"]) }
        
        let prompt = prompts.generateTaskTypes.replacingOccurrences(of: "{{userIdentity}}", with: userIdentity)
        
        // 🔍 DEBUG: Print prompt
        print("═══════════════════════════════════════")
        print("🎯 GENERATE TASK TYPES & CATEGORIES")
        print("═══════════════════════════════════════")
        print("👤 User Identity: \(userIdentity)")
        print("\n📋 Full Prompt:")
        print(prompt)
        print("═══════════════════════════════════════\n")
        
        let messages = [
            ["role": "system", "content": "你是 TaskFlow AI 任務規劃專家。"],
            ["role": "user", "content": prompt]
        ]
        
        let content = try await sendRequest(messages: messages)
        
        // Parse JSON response
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if jsonString.hasPrefix("```json") {
            jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
        }
        if jsonString.hasPrefix("```") {
            jsonString = jsonString.replacingOccurrences(of: "```", with: "")
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to parse AI response"])
        }
        
        let taskTypeResponse = try JSONDecoder().decode(TaskTypeResponse.self, from: jsonData)
        
        let suggestedTaskTypes = taskTypeResponse.taskTypes.map { typeJSON in
            SuggestedTaskType(
                name: typeJSON.name,
                icon: typeJSON.icon,
                colorHex: typeJSON.colorHex
            )
        }
        
        let categories = taskTypeResponse.categories?.map { catJSON in
            Category(
                name: catJSON.name,
                icon: catJSON.icon,
                colorHex: catJSON.colorHex
            )
        } ?? []
        
        let response = taskTypeResponse.response ?? "已為您生成任務類型和分類"
        
        // 🔍 DEBUG: Print results
        print("═══════════════════════════════════════")
        print("✅ AI RESPONSE RECEIVED")
        print("═══════════════════════════════════════")
        print("📝 Response: \(response)")
        print("\n📦 Generated \(suggestedTaskTypes.count) Task Types:")
        for taskType in suggestedTaskTypes {
            print("  - \(taskType.name) (\(taskType.icon))")
        }
        print("\n📂 Generated \(categories.count) Categories:")
        for category in categories {
            print("  - \(category.name) (\(category.icon), #\(category.colorHex))")
        }
        print("═══════════════════════════════════════\n")
        
        return (response, suggestedTaskTypes, categories)
    }
    
    // MARK: - Helper Methods
    
    private func sendRequest(messages: [Any], model: String = "gpt-5-nano-2025-08-07") async throws -> String {
        let requestBody: [String: Any] = [
            "model": model,
            "messages": messages
        ]
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("OpenAI API Error: \(errorJson)")
            }
            throw URLError(.badServerResponse)
        }
        
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return openAIResponse.choices.first?.message.content ?? ""
    }
    
    /// 從 AI 回應中解析課程 JSON
    private func parseCourseJSON(_ content: String) throws -> [Course] {
        // Extract JSON array from content (remove markdown code blocks if present)
        var jsonString = content.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks
        if jsonString.hasPrefix("```json") {
            jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
        }
        if jsonString.hasPrefix("```") {
            jsonString = jsonString.replacingOccurrences(of: "```", with: "")
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw NSError(domain: "AIAnalysisService", code: -1, userInfo: [NSLocalizedDescriptionKey: "無法解析課表資料"])
        }
        
        struct CourseJSON: Codable {
            let name: String
            let location: String
            let dayOfWeek: String
            let startPeriod: Int
            let endPeriod: Int
        }
        
        let coursesJSON = try JSONDecoder().decode([CourseJSON].self, from: jsonData)
        
        // Convert to Course objects
        let courses: [Course] = coursesJSON.compactMap { courseJSON in
            // Validate and map day
            guard let day = Day.allCases.first(where: { $0.rawValue.lowercased() == courseJSON.dayOfWeek.lowercased() }) else {
                print("Invalid day: \(courseJSON.dayOfWeek)")
                return nil
            }
            
            // Validate periods
            guard (1...10).contains(courseJSON.startPeriod),
                  (1...10).contains(courseJSON.endPeriod),
                  courseJSON.endPeriod >= courseJSON.startPeriod else {
                print("Invalid periods: \(courseJSON.startPeriod) - \(courseJSON.endPeriod)")
                return nil
            }
            
            return Course(
                name: courseJSON.name,
                location: courseJSON.location,
                dayOfWeek: day,
                startPeriod: courseJSON.startPeriod,
                endPeriod: courseJSON.endPeriod,
                colorHex: CourseColor.randomPreset()
            )
        }
        
        return courses
    }
}
