import SwiftUI
import Combine
import UIKit // For HapticFeedback
import WidgetKit // For WidgetCenter

class TaskViewModel: ObservableObject {
    // MARK: - App Group Configuration
    private let appGroupID = "group.task-creator.com.task-creator"
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    @Published var tasks: [Task] = [] {
        didSet {
            saveTasks()
            // Notify widget to reload
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    @Published var reflections: [Reflection] = []
    @Published var focusSessions: [FocusSession] = []
    
    private let tasksKey = "tasks" // Simplified key for widget
    
    init() {
        loadTasks()
        loadReflections()
        loadFocusSessions()
        loadAIAnalysisRecords()
    }
    
    // MARK: - CRUD
    
    func addTask(title: String, type: TaskType = .academic, category: Category, priority: Priority, dueDate: Date = Date()) {
        let newTask = Task(title: title, type: type, category: category, priority: priority, day: nil, dueDate: dueDate)
        withAnimation {
            tasks.append(newTask)
        }
    }
    
    func deleteTask(id: String) {
        withAnimation {
            tasks.removeAll { $0.id == id }
        }
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
    }
    
    func moveTask(id: String, to day: Day?) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            withAnimation {
                var task = tasks[index]
                task.day = day
                
                // Remove from old position and append to end to ensure it appears at the bottom
                tasks.remove(at: index)
                tasks.append(task)
            }
        }
    }
    
    func toggleCompletion(id: String) {
        if let index = tasks.firstIndex(where: { $0.id == id }) {
            withAnimation {
                tasks[index].completed.toggle()
                if tasks[index].completed {
                    tasks[index].completedDate = Date()
                } else {
                    tasks[index].completedDate = nil
                }
            }
        }
    }
    
    // MARK: - Persistence (App Group Compatible)
    
    /// Save tasks to App Group shared container
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            // Save to App Group for widget access
            sharedDefaults?.set(encoded, forKey: tasksKey)
            
            // Also save to standard UserDefaults for backwards compatibility
            UserDefaults.standard.set(encoded, forKey: tasksKey)
        }
    }
    
    /// Load tasks from App Group shared container (fallback to standard UserDefaults)
    func loadTasks() {
        // Try loading from App Group first
        if let savedTasks = sharedDefaults?.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
            return
        }
        
        // Fallback to standard UserDefaults (for migration)
        if let savedTasks = UserDefaults.standard.data(forKey: tasksKey),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
            // Migrate to App Group
            saveTasks()
        }
    }
    
    // MARK: - Reflections
    
    func addReflection(mood: Mood, content: String) {
        let newReflection = Reflection(date: Date(), mood: mood, content: content)
        withAnimation {
            reflections.insert(newReflection, at: 0)
        }
        saveReflections()
    }
    
    func saveReflections() {
        if let encoded = try? JSONEncoder().encode(reflections) {
            UserDefaults.standard.set(encoded, forKey: "reflections")
        }
    }
    
    func loadReflections() {
        if let savedReflections = UserDefaults.standard.data(forKey: "reflections"),
           let decodedReflections = try? JSONDecoder().decode([Reflection].self, from: savedReflections) {
            reflections = decodedReflections
        }
    }
    
    // MARK: - Focus Sessions
    
    func addFocusSession(startTime: Date, endTime: Date, duration: TimeInterval, category: Category, status: FocusStatus) {
        let newSession = FocusSession(startTime: startTime, endTime: endTime, duration: duration, category: category, status: status)
        withAnimation {
            focusSessions.insert(newSession, at: 0)
        }
        saveFocusSessions()
    }
    
    func saveFocusSessions() {
        if let encoded = try? JSONEncoder().encode(focusSessions) {
            UserDefaults.standard.set(encoded, forKey: "focusSessions")
        }
    }
    
    func loadFocusSessions() {
        if let savedSessions = UserDefaults.standard.data(forKey: "focusSessions"),
           let decodedSessions = try? JSONDecoder().decode([FocusSession].self, from: savedSessions) {
            focusSessions = decodedSessions
        }
    }
    
    // MARK: - AI Analysis Records
    
    @Published var aiAnalysisRecords: [AIAnalysisRecord] = []
    
    func addAIAnalysisRecord(content: String) {
        let newRecord = AIAnalysisRecord(date: Date(), content: content)
        withAnimation {
            aiAnalysisRecords.insert(newRecord, at: 0)
        }
        saveAIAnalysisRecords()
    }
    
    func saveAIAnalysisRecords() {
        if let encoded = try? JSONEncoder().encode(aiAnalysisRecords) {
            UserDefaults.standard.set(encoded, forKey: "aiAnalysisRecords")
        }
    }
    
    func loadAIAnalysisRecords() {
        if let savedRecords = UserDefaults.standard.data(forKey: "aiAnalysisRecords"),
           let decodedRecords = try? JSONDecoder().decode([AIAnalysisRecord].self, from: savedRecords) {
            aiAnalysisRecords = decodedRecords
        }
    }
    // MARK: - Timer State
    
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var totalTime: TimeInterval = 25 * 60
    @Published var isTimerRunning = false
    @Published var timerMode = 0 // 0: Pomodoro, 1: Countdown, 2: Stopwatch
    @Published var timerCategory: Category = .other
    
    private var timer: Timer?
    private var timerStartTime: Date?
    private var timerTargetEndTime: Date?
    
    // MARK: - Timer Logic
    
    func toggleTimer() {
        if isTimerRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        performHapticFeedback()
        if timerStartTime == nil {
            timerStartTime = Date()
        }
        
        // Set target end time for background tracking
        if timerMode != 2 { // Not for stopwatch
            timerTargetEndTime = Date().addingTimeInterval(timeRemaining)
            scheduleNotification(at: timerTargetEndTime!)
        }
        
        isTimerRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.timerMode == 2 {
                // Stopwatch
                self.timeRemaining += 1
            } else {
                // Countdown
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endSession(completed: true)
                }
            }
        }
    }
    
    func pauseTimer() {
        timer?.invalidate()
        isTimerRunning = false
        timerTargetEndTime = nil
        cancelNotification()
    }
    
    func endSession(completed: Bool) {
        performHapticFeedback()
        timer?.invalidate()
        isTimerRunning = false
        timerTargetEndTime = nil
        cancelNotification()
        
        let endTime = Date()
        let duration = completed ? totalTime : (timerMode == 2 ? timeRemaining : totalTime - timeRemaining)
        
        if duration > 0 {
            addFocusSession(
                startTime: timerStartTime ?? Date(),
                endTime: endTime,
                duration: duration,
                category: timerCategory,
                status: completed ? .completed : .abandoned
            )
        }
        
        // Reset
        timerStartTime = nil
        if timerMode == 0 {
            timeRemaining = 25 * 60
        } else if timerMode == 1 {
            timeRemaining = 45 * 60
        } else {
            timeRemaining = 0
        }
    }
    
    func setTimerMode(_ mode: Int) {
        if !isTimerRunning {
            timerMode = mode
            if mode == 0 {
                timeRemaining = 25 * 60
                totalTime = 25 * 60
            } else if mode == 1 {
                timeRemaining = 45 * 60
                totalTime = 45 * 60
            } else {
                timeRemaining = 0
                totalTime = 0
            }
        }
    }
    
    func checkBackgroundTime() {
        if isTimerRunning, let target = timerTargetEndTime {
            let remaining = target.timeIntervalSinceNow
            if remaining <= 0 {
                timeRemaining = 0
                endSession(completed: true)
            } else {
                timeRemaining = remaining
            }
        }
    }
    
    // MARK: - Notifications & Haptics
    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }
    
    private func scheduleNotification(at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "專注完成！"
        content.body = "恭喜你完成了 \(timerCategory.rawValue) 的專注時段。"
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: "PomodoroTimer", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    private func cancelNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["PomodoroTimer"])
    }
    
    private func performHapticFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
