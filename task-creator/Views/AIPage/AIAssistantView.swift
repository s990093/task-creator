import SwiftUI

struct CommonTask: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let prompt: String
}

struct AIAssistantView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    @State private var inputText: String = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @FocusState private var isInputFocused: Bool
    
    private let aiService = AIService()
    @State private var showingIdentityDialog = false
    @State private var identityInput = ""
    
    // Welcome & History
    @State private var isFirstLaunch = false
    @State private var showWelcomeAnimation = false
    @State private var typingText = ""
    @State private var showAddedToast = false
    private let welcomeMessage = "嗨！我是您的 AI 學習教練。為了幫您配置最佳環境，請告訴我您的目前身份與學習目標。"
    private let historyKey = "aiChatHistory"
    
    // Common Tasks Data
    private let commonTasks: [CommonTask] = [
        CommonTask(title: "安排今日行程", subtitle: "根據我的習慣規劃", prompt: "請幫我安排今天的行程，考慮到我的習慣..."),
        CommonTask(title: "建立新專案", subtitle: "協助規劃專案任務", prompt: "我想建立一個新專案，請幫我規劃相關任務..."),
        CommonTask(title: "描述你的身份", subtitle: "生成個人化任務類型", prompt: "GENERATE_TASK_TYPES:"),
        CommonTask(title: "心情日記", subtitle: "記錄今天的心情", prompt: "我想記錄今天的心情...")
    ]

    var body: some View {
        ZStack {
            // Dark Background
            Color.black.ignoresSafeArea()
            
            ZStack {
                // Main Content
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Messages Area
                    if messages.isEmpty && !showWelcomeAnimation {
                        Spacer()
                    } else {
                        chatAreaView
                    }
                    
                    // Common Tasks - Always Show at Bottom
                    commonTasksView
                        .padding(.bottom, 8)
                }
                
                // Welcome Typing Animation Overlay
                if showWelcomeAnimation {
                    VStack {
                        Spacer()
                        
                        HStack(alignment: .bottom, spacing: 12) {
                            // AI Avatar
                            Image(systemName: "brain.head.profile")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(Color(hex: "4F46E5"))
                                .clipShape(Circle())
                            
                            // Typing text bubble
                            highlightedTypingText(typingText)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color(hex: "1E293B"))
                                .cornerRadius(20, corners: [.topLeft, .topRight, .bottomRight])
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        
                        Spacer()
                            .frame(height: 200)
                    }
                    .animation(.spring(response: 0.4), value: showWelcomeAnimation)
                }
                
                // Added Toast
                if showAddedToast {
                    VStack {
                        Text("✅ 已添加選中的任務")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color(hex: "34C759"))
                            .cornerRadius(12)
                            .shadow(radius: 10)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 60)
                        
                        Spacer()
                    }
                    .zIndex(100)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            inputAreaView
        }
        .onTapGesture {
            isInputFocused = false
        }
        .onAppear {
            loadChatHistory()
            checkFirstLaunch()
        }
        .overlay(
            identityDialogOverlay
        )
        .background(Color.black)
    }
    
    // ... (existing code)


    
    // MARK: - Subviews
    
    private var headerView: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                Text("AI Assistant")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Image(systemName: "sparkles")
                    .font(.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(hex: "2D2D2D"))
            .foregroundColor(Color(hex: "A78BFA")) // Purple tint
            .clipShape(Capsule())
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.black)
    }
    
    private var commonTasksView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(commonTasks) { task in
                    Button {
                        if task.prompt.hasPrefix("GENERATE_TASK_TYPES:") {
                            showIdentityDialog()
                        } else {
                            inputText = task.prompt
                            sendMessage()
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(task.subtitle)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .frame(width: 200)
                        .padding()
                        .background(Color(hex: "1E293B"))
                        .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Chat Area
    
    private var chatAreaView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach($messages) { $message in
                        messageRow(message: $message)
                    }
                    
                    if isTyping {
                        typingIndicator
                    }
                }
                .padding(.vertical)
            }
            .onChange(of: messages.count) { _ in
                withAnimation {
                    proxy.scrollTo(messages.last?.id, anchor: .bottom)
                }
            }
            .onChange(of: isTyping) { typing in
                if typing {
                    withAnimation {
                        proxy.scrollTo("typing", anchor: .bottom)
                    }
                }
            }
        }
    }
    
    private func messageRow(message: Binding<ChatMessage>) -> some View {
        VStack(spacing: 8) {
            MessageBubble(message: message.wrappedValue)
            
            // Render TaskType suggestions if available
            if let taskTypes = message.wrappedValue.suggestedTaskTypes, !taskTypes.isEmpty {
                VStack(spacing: 8) {
                    let taskTypesBinding = Binding(
                        get: { message.wrappedValue.suggestedTaskTypes ?? [] },
                        set: { message.wrappedValue.suggestedTaskTypes = $0 }
                    )
                    
                    ForEach(taskTypesBinding) { $taskType in
                        TaskTypeSuggestionCard(taskType: $taskType)
                    }
                    
                    Button {
                        addSelectedTaskTypes(from: message.wrappedValue)
                    } label: {
                        Text("添加選中的任務類型")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "4F46E5"))
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
                .padding(.leading, 56)
                .padding(.trailing)
            }
            
            // Render task suggestions if available
            if let tasks = message.wrappedValue.suggestedTasks, !tasks.isEmpty {
                VStack(spacing: 8) {
                    let tasksBinding = Binding(
                        get: { message.wrappedValue.suggestedTasks ?? [] },
                        set: { message.wrappedValue.suggestedTasks = $0 }
                    )
                    
                    ForEach(tasksBinding) { $task in
                        TaskSuggestionCard(task: $task)
                    }
                    
                    Button {
                        addSelectedTasks(from: message.wrappedValue)
                    } label: {
                        Text("添加選中的任務")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "4F46E5"))
                            .cornerRadius(12)
                    }
                    .accessibilityIdentifier("AddSelectedTasksButton")
                    .padding(.horizontal)
                    .padding(.top, 4)
                }
                .padding(.leading, 56) // Indent to align with AI bubble
                .padding(.trailing)
            }
        }
        .id(message.wrappedValue.id)
    }
    
    
    private var typingIndicator: some View {
        HStack {
            ProgressView()
                .tint(.white)
            Text("AI 正在思考...")
                .foregroundColor(.gray)
                .font(.caption)
        }
        .padding()
        .id("typing")
    }
    
    // MARK: - Input Area
    
    private var inputAreaView: some View {
        HStack(spacing: 12) {
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 44, height: 44)
                    .background(Color(hex: "2C2C2E"))
                    .clipShape(Circle())
            }
            
            HStack {
                if speechRecognizer.isRecording {
                    Spacer()
                    WaveformView(isRecording: true)
                    Spacer()
                } else {
                    TextField("Ask anything", text: $inputText)
                        .foregroundColor(.white)
                        .focused($isInputFocused)
                        .submitLabel(.send)
                        .onSubmit(sendMessage)
                        .accessibilityIdentifier("AIInput")
                }
                
                Spacer()
                
                if inputText.isEmpty && !speechRecognizer.isRecording {
                    Button(action: {
                        if speechRecognizer.isRecording {
                            speechRecognizer.stopTranscribing()
                        } else {
                            speechRecognizer.startTranscribing()
                        }
                    }) {
                        Image(systemName: speechRecognizer.isRecording ? "stop.circle.fill" : "mic")
                            .font(.system(size: 20))
                            .foregroundColor(speechRecognizer.isRecording ? .red : .gray)
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "waveform")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Circle())
                    }
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .accessibilityIdentifier("AISendButton")
                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)
            .background(Color(hex: "2C2C2E"))
            .clipShape(Capsule())
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color.black)
        .onChange(of: speechRecognizer.transcript) { newTranscript in
            if !newTranscript.isEmpty {
                inputText = newTranscript
            }
        }
    }
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Stop voice recording if active
        if speechRecognizer.isRecording {
            speechRecognizer.stopTranscribing()
        }
        
        let userMsg = ChatMessage(role: .user, content: inputText)
        messages.append(userMsg)
        
        let currentInput = inputText
        inputText = ""
        isTyping = true
        
        // 🔍 DEBUG: Print user message and context
        print("═══════════════════════════════════════")
        print("🚀 AI REQUEST STARTED")
        print("═══════════════════════════════════════")
        print("📝 User Message: \(currentInput)")
        print("📊 Conversation History Count: \(messages.count)")
        print("👤 User Profile: \(UserProfileManager.shared.profile)")
        print("═══════════════════════════════════════\n")
        
        _Concurrency.Task {
            do {
                // Prepare context (simplified for now)
                let context = UserContext(identity: nil, goals: nil, preferences: nil)
                
                let (response, tasks) = try await aiService.chatWithAssistant(
                    message: currentInput,
                    conversationHistory: messages.dropLast(),
                    userContext: context
                )
                
                await MainActor.run {
                    let aiMsg = ChatMessage(role: .assistant, content: response, suggestedTasks: tasks)
                    messages.append(aiMsg)
                    isTyping = false
                    saveChatHistory()
                }
            } catch {
                await MainActor.run {
                    let errorMsg = ChatMessage(role: .assistant, content: "抱歉，我遇到了一些問題：\(error.localizedDescription)")
                    messages.append(errorMsg)
                    isTyping = false
                    saveChatHistory()
                }
            }
        }
    }
    
    private func addSelectedTasks(from message: ChatMessage) {
        guard let tasks = message.suggestedTasks else { return }
        let selectedTasks = tasks.filter { $0.isSelected }
        
        guard !selectedTasks.isEmpty else { return }
        
        for task in selectedTasks {
            // Find or create category
            let categoryName = task.category
            var category = viewModel.categories.first { $0.name == categoryName }
            
            if category == nil {
                // Create new category if not exists
                // Use AI suggested details if available, otherwise default
                let icon = task.categoryIcon ?? "tag.fill"
                let colorHex = task.categoryColor ?? "8E8E93"
                
                let newCategory = Category(
                    name: categoryName,
                    icon: icon,
                    colorHex: colorHex
                )
                viewModel.categories.append(newCategory)
                category = newCategory
            }
            
            // Map priority
            let priority: Priority
            switch task.priority.lowercased() {
            case "urgent": priority = .urgent
            default: priority = .normal
            }
            
            // Create Task
            // Use default task type for now
            var finalType = viewModel.taskTypes.first
            if finalType == nil {
                let newType = TaskType(name: "一般", icon: "circle", isSystem: true)
                viewModel.taskTypes.append(newType)
                finalType = newType
            }
            
            let newTask = Task(
                title: task.title,
                type: finalType!,
                category: category!,
                priority: priority,
                day: nil // Inbox
            )
            
            viewModel.addTask(newTask)
        }
        
        // Mark selected tasks as added
        if let messageIndex = messages.firstIndex(where: { $0.id == message.id }) {
            if var updatedTasks = messages[messageIndex].suggestedTasks {
                for i in updatedTasks.indices {
                    if updatedTasks[i].isSelected {
                        updatedTasks[i].isAdded = true
                    }
                }
                messages[messageIndex].suggestedTasks = updatedTasks
            }
        }
        
        // Show success feedback
        withAnimation {
            showAddedToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showAddedToast = false
            }
        }
    }
    
    // MARK: - Identity Dialog
    
    @ViewBuilder
    private var identityDialogOverlay: some View {
        if showingIdentityDialog {
            ZStack {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showingIdentityDialog = false
                        identityInput = ""
                    }
                
                VStack(spacing: 20) {
                    Text("請描述您的身份")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("例如:我是資工系大三學生")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    TextField("請輸入...", text: $identityInput)
                        .textFieldStyle(.roundedBorder)
                        .padding()
                    
                    HStack(spacing: 12) {
                        Button("取消") {
                            showingIdentityDialog = false
                            identityInput = ""
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray)
                        .cornerRadius(12)
                        
                        Button("確定") {
                            generateTaskTypesFromIdentity()
                            showingIdentityDialog = false
                        }
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(hex: "4F46E5"))
                        .cornerRadius(12)
                        .disabled(identityInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(24)
                .background(Color(hex: "1C1C1E"))
                .cornerRadius(20)
                .padding(.horizontal, 40)
            }
        }
    }
    
    private func showIdentityDialog() {
        showingIdentityDialog = true
    }
    
    private func generateTaskTypesFromIdentity() {
        guard !identityInput.isEmpty else { return }
        
        let identity = identityInput
        identityInput = ""
        
        // 🔍 DEBUG: Print identity request
        print("═══════════════════════════════════════")
        print("🎯 GENERATE TASK TYPES REQUEST")
        print("═══════════════════════════════════════")
        print("👤 Identity Input: \(identity)")
        print("═══════════════════════════════════════\n")
        
        isTyping = true
        
        _Concurrency.Task {
            do {
                let (response, taskTypes, categories) = try await aiService.generateTaskTypes(userIdentity: identity)
                
                await MainActor.run {
                    let aiMsg = ChatMessage(role: .assistant, content: response, suggestedTaskTypes: taskTypes)
                    messages.append(aiMsg)
                    isTyping = false
                    
                    // Auto-add generated categories to TaskViewModel
                    for category in categories {
                        if !viewModel.categories.contains(where: { $0.name == category.name }) {
                            viewModel.addCategory(name: category.name, icon: category.icon, colorHex: category.colorHex)
                        }
                    }
                    
                    // Show feedback
                    print("✅ Added \(categories.count) categories to TaskViewModel")
                }
            } catch {
                await MainActor.run {
                    let errorMsg = ChatMessage(role: .assistant, content: "抱歉，生成任務類型時遇到問題：\(error.localizedDescription)")
                    messages.append(errorMsg)
                    isTyping = false
                }
            }
        }
    }
    
    private func addSelectedTaskTypes(from message: ChatMessage) {
        guard let taskTypes = message.suggestedTaskTypes else { return }
        let selectedTaskTypes = taskTypes.filter { $0.isSelected }
        
        guard !selectedTaskTypes.isEmpty else { return }
        
        for taskType in selectedTaskTypes {
            let newTaskType = TaskType(name: taskType.name, icon: taskType.icon, isSystem: false)
            viewModel.taskTypes.append(newTaskType)
        }
        
        // Mark selected TaskTypes as added
        if let messageIndex = messages.firstIndex(where: { $0.id == message.id }) {
            if var updatedTaskTypes = messages[messageIndex].suggestedTaskTypes {
                for i in updatedTaskTypes.indices {
                    if updatedTaskTypes[i].isSelected {
                        updatedTaskTypes[i].isAdded = true
                    }
                }
                messages[messageIndex].suggestedTaskTypes = updatedTaskTypes
            }
        }
        
        // Show success feedback
        withAnimation {
            showAddedToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showAddedToast = false
            }
        }
    }
    
    // MARK: - Chat History Persistence
    
    private func saveChatHistory() {
        if let encoded = try? JSONEncoder().encode(messages) {
            UserDefaults.standard.set(encoded, forKey: historyKey)
        }
    }
    
    private func loadChatHistory() {
        if let data = UserDefaults.standard.data(forKey: historyKey),
           let decoded = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            messages = decoded
        }
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedKey = "aiAssistantHasLaunched"
        let hasLaunched = UserDefaults.standard.bool(forKey: hasLaunchedKey)
        
        if !hasLaunched {
            isFirstLaunch = true
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            showWelcomeMessage()
        }
    }
    
    private func showWelcomeMessage() {
        showWelcomeAnimation = true
        startTypingAnimation()
    }
    
    private func startTypingAnimation() {
        typingText = ""
        var currentIndex = 0
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if currentIndex < welcomeMessage.count {
                let index = welcomeMessage.index(welcomeMessage.startIndex, offsetBy: currentIndex)
                typingText.append(welcomeMessage[index])
                currentIndex += 1
            } else {
                timer.invalidate()
                // Add to messages after typing completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let welcomeMsg = ChatMessage(role: .assistant, content: welcomeMessage)
                    messages.append(welcomeMsg)
                    saveChatHistory()
                    showWelcomeAnimation = false
                }
            }
        }
    }
    
    // MARK: - Typing Text with Highlighting
    
    private func highlightedTypingText(_ content: String) -> some View {
        let keywords = ["目前身份", "學習目標"]
        var attributedString = AttributedString(content)
        
        // Highlight keywords in purple
        for keyword in keywords {
            var searchRange = attributedString.startIndex..<attributedString.endIndex
            while let range = attributedString[searchRange].range(of: keyword) {
                attributedString[range].foregroundColor = Color(hex: "A78BFA") // Purple
                attributedString[range].font = .body.bold()
                
                // Move search range forward
                if range.upperBound < attributedString.endIndex {
                    searchRange = range.upperBound..<attributedString.endIndex
                } else {
                    break
                }
            }
        }
        
        return Text(attributedString)
            .font(.body)
            .foregroundColor(.white)
    }
}



