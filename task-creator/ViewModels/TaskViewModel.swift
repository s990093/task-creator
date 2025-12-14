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
    
    @Published var categories: [Category] = [] {
        didSet {
            saveCategories()
        }
    }
    
    @Published var taskTypes: [TaskType] = [] {
        didSet {
            saveTaskTypes()
        }
    }
    
    @Published var reflections: [Reflection] = []
    @Published var focusSessions: [FocusSession] = []
    @Published var importantDates: [ImportantDate] = []
    
    // AI Services
    private let aiService = AIService()
    
    
    private let tasksKey = "task_flow_tasks"
    
    init() {
        loadCategories()
        loadTaskTypes()
        loadTasks()
        loadReflections()
        loadFocusSessions()
        loadAIAnalysisRecords()
        loadImportantDates()
        loadCourses()
    }
    
    // MARK: - CRUD
    
    func addTask(title: String, type: TaskType, category: Category, priority: Priority, dueDate: Date = Date()) {
        let newTask = Task(title: title, type: type, category: category, priority: priority, day: nil, dueDate: dueDate)
        withAnimation {
            tasks.append(newTask)
        }
    }
    
    func addTask(_ task: Task) {
        withAnimation {
            tasks.append(task)
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
    
    // MARK: - Category Management
    
    func addCategory(name: String, icon: String, colorHex: String) {
        let newCategory = Category(name: name, icon: icon, colorHex: colorHex)
        withAnimation {
            categories.append(newCategory)
        }
    }
    
    func deleteCategory(_ category: Category) {
        guard !category.isSystem else { return }
        withAnimation {
            categories.removeAll { $0.id == category.id }
        }
    }
    
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: "categories")
        }
    }
    
    private func loadCategories() {
        if let savedCategories = UserDefaults.standard.data(forKey: "categories"),
           let decodedCategories = try? JSONDecoder().decode([Category].self, from: savedCategories) {
            categories = decodedCategories
        } else {
            categories = Category.defaults
        }
    }
    
    // MARK: - Task Type Management
    
    func addTaskType(name: String, icon: String) {
        let newType = TaskType(name: name, icon: icon)
        withAnimation {
            taskTypes.append(newType)
        }
    }
    
    func deleteTaskType(_ type: TaskType) {
        guard !type.isSystem else { return }
        withAnimation {
            taskTypes.removeAll { $0.id == type.id }
        }
    }
    
    private func saveTaskTypes() {
        if let encoded = try? JSONEncoder().encode(taskTypes) {
            UserDefaults.standard.set(encoded, forKey: "taskTypes")
        }
    }
    
    private func loadTaskTypes() {
        if let savedTypes = UserDefaults.standard.data(forKey: "taskTypes"),
           let decodedTypes = try? JSONDecoder().decode([TaskType].self, from: savedTypes) {
            taskTypes = decodedTypes
        } else {
            taskTypes = TaskType.defaults
        }
    }
    
    // MARK: - Persistence (App Group Compatible)
    
    /// Save tasks to App Group shared container
    private func saveTasks() {
        if let encoded = try? JSONEncoder().encode(tasks) {
            // Save to App Group for widget access
            sharedDefaults?.set(encoded, forKey: "tasks")
            
            // Also save to standard UserDefaults for backwards compatibility
            UserDefaults.standard.set(encoded, forKey: "tasks")
        }
    }
    
    /// Load tasks from App Group shared container (fallback to standard UserDefaults)
    func loadTasks() {
        // Try loading from App Group first
        if let savedTasks = sharedDefaults?.data(forKey: "tasks"),
           let decodedTasks = try? JSONDecoder().decode([Task].self, from: savedTasks) {
            tasks = decodedTasks
            return
        }
        
        // Fallback to standard UserDefaults (for migration)
        if let savedTasks = UserDefaults.standard.data(forKey: "tasks"),
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
    
    // MARK: - Important Dates
    
    func addImportantDate(title: String, date: Date, color: String, icon: String) {
        let newDate = ImportantDate(title: title, date: date, color: color, icon: icon)
        withAnimation {
            importantDates.append(newDate)
            // Sort by date
            importantDates.sort { $0.date < $1.date }
        }
        saveImportantDates()
    }
    
    func deleteImportantDate(id: String) {
        withAnimation {
            importantDates.removeAll { $0.id == id }
        }
        saveImportantDates()
    }
    
    func saveImportantDates() {
        if let encoded = try? JSONEncoder().encode(importantDates) {
            UserDefaults.standard.set(encoded, forKey: "importantDates")
        }
    }
    
    func loadImportantDates() {
        if let savedDates = UserDefaults.standard.data(forKey: "importantDates"),
           let decodedDates = try? JSONDecoder().decode([ImportantDate].self, from: savedDates) {
            importantDates = decodedDates
        }
    }
    
    // MARK: - Courses
    
    @Published var courses: [Course] = []
    
    func addCourse(_ course: Course) {
        withAnimation {
            courses.append(course)
        }
        saveCourses()
    }
    
    func updateCourse(_ course: Course) {
        if let index = courses.firstIndex(where: { $0.id == course.id }) {
            withAnimation {
                courses[index] = course
            }
            saveCourses()
        }
    }
    
    func deleteCourse(_ course: Course) {
        withAnimation {
            courses.removeAll { $0.id == course.id }
        }
        saveCourses()
    }
    
    func getCourses(for day: Day) -> [Course] {
        return courses.filter { $0.dayOfWeek == day }.sorted { $0.startPeriod < $1.startPeriod }
    }
    
    func saveCourses() {
        if let encoded = try? JSONEncoder().encode(courses) {
            UserDefaults.standard.set(encoded, forKey: "courses")
        }
    }
    
    func loadCourses() {
        if let savedCourses = UserDefaults.standard.data(forKey: "courses"),
           let decodedCourses = try? JSONDecoder().decode([Course].self, from: savedCourses) {
            courses = decodedCourses
        }
    }
    // MARK: - Timer State
    
    @Published var timeRemaining: TimeInterval = 25 * 60
    @Published var totalTime: TimeInterval = 25 * 60
    @Published var isTimerRunning = false
    @Published var timerMode = 0 // 0: Pomodoro, 1: Countdown, 2: Stopwatch
    @Published var timerCategory: Category = Category(name: "其他", icon: "sparkles", colorHex: "8E8E93", isSystem: true)
    
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
        content.body = "恭喜你完成了 \(timerCategory.name) 的專注時段。"
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
    
    // MARK: - AI Study Plan Helper
    
    /// 使用 AI 產生三個今日任務，並回傳任務標題陣列
    func generateAIStudyTasks(subject: String, goal: String) async throws -> [String] {
        try await aiService.generateStudyPlan(subject: subject, goal: goal)
    }
    
    /// 使用 AI 潤色任務標題
    func polishTaskTitle(_ title: String) async throws -> String {
        try await aiService.polishTaskTitle(title)
    }
}
