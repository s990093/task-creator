import SwiftUI
import UserNotifications

struct PomodoroView: View {
    @StateObject private var faceEstimator = FaceEstimator()
    
    var body: some View {
        TabView {
            PomodoroTimerView(faceEstimator: faceEstimator)
            FocusMonitorView(faceEstimator: faceEstimator, isMonitoring: $faceEstimator.isSessionActive)
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .background(AppTheme.background)
        .ignoresSafeArea()
    }
}

struct PomodoroTimerView: View {
    @ObservedObject var faceEstimator: FaceEstimator
    @EnvironmentObject var viewModel: TaskViewModel
    @Environment(\.scenePhase) var scenePhase
    
    // UI State
    @State private var showGiveUpAlert = false
    @State private var showAnalysis = false
    @State private var showFocusMode = false
    @State private var showSessionReport = false
    
    var timeString: String {
        let minutes = Int(viewModel.timeRemaining) / 60
        let seconds = Int(viewModel.timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: CGFloat {
        guard viewModel.totalTime > 0 else { return 0 }
        return CGFloat(viewModel.timeRemaining / viewModel.totalTime)
    }
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea() // Slate 900 Background
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Button(action: {
                            showAnalysis = true
                        }) {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundColor(AppTheme.textPrimary)
                        }
                        .sheet(isPresented: $showAnalysis) {
                            FocusAnalysisView()
                        }
                        
                        Spacer()
                        Text("專注")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: {
                                showFocusMode = true
                            }) {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .font(.title2)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        .font(.title2)
                        .foregroundColor(AppTheme.textPrimary)
                    }
                    .padding()
                    
                    // Focus Target Selector
                    Menu {
                        ForEach(viewModel.categories) { category in
                            Button(action: { viewModel.timerCategory = category }) {
                                Label(category.name, systemImage: category.icon)
                            }
                        }
                    } label: {
                        HStack {
                            Text("專注於")
                                .foregroundColor(AppTheme.textSecondary)
                            Image(systemName: viewModel.timerCategory.icon)
                                .foregroundColor(viewModel.timerCategory.color)
                            Text(viewModel.timerCategory.name)
                                .fontWeight(.bold)
                                .foregroundColor(AppTheme.textPrimary)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(AppTheme.surface) // Slate 800 Surface
                        .cornerRadius(20)
                    }
                    
                    // Mode Selector
                    HStack(spacing: 12) {
                        ModeButton(title: "番茄鐘", isSelected: viewModel.timerMode == 0) {
                            viewModel.setTimerMode(0)
                        }
                        ModeButton(title: "倒計時", isSelected: viewModel.timerMode == 1) {
                            viewModel.setTimerMode(1)
                        }
                        ModeButton(title: "正計時", isSelected: viewModel.timerMode == 2) {
                            viewModel.setTimerMode(2)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Timer Circle
                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(AppTheme.surface, lineWidth: 20)
                            .frame(width: 280, height: 280)
                        
                        // Progress Circle
                        Circle()
                            .trim(from: 0, to: viewModel.timerMode == 2 ? 1 : progress)
                            .stroke(
                                Color(hex: "FF453A"), // iOS Dark Mode Red
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: viewModel.timeRemaining)
                        
                        // Ticks
                        ForEach(0..<60) { i in
                            Rectangle()
                                .fill(i % 5 == 0 ? AppTheme.textPrimary : AppTheme.textSecondary.opacity(0.5))
                                .frame(width: i % 5 == 0 ? 2 : 1, height: i % 5 == 0 ? 15 : 10)
                                .offset(y: -120)
                                .rotationEffect(.degrees(Double(i) * 6))
                        }
                        .frame(width: 280, height: 280)
                        
                        // Timer Text
                        VStack(spacing: 5) {
                            Text(timeString)
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.textPrimary)
                            
                            Text(viewModel.isTimerRunning ? "專注中..." : "準備開始")
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Controls
                    if viewModel.isTimerRunning {
                        HStack(spacing: 40) {
                            Button(action: {
                                withAnimation {
                                    showGiveUpAlert = true
                                }
                            }) {
                                VStack {
                                    Image(systemName: "xmark")
                                        .font(.title)
                                        .foregroundColor(Color(hex: "FF453A"))
                                        .frame(width: 60, height: 60)
                                        .background(AppTheme.textPrimary)
                                        .clipShape(Circle())
                                        .shadow(color: AppTheme.textPrimary.opacity(0.1), radius: 5, x: 0, y: 2)
                                    Text("放棄")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                            
                            Button(action: { viewModel.toggleTimer() }) {
                                VStack {
                                    Image(systemName: "pause.fill")
                                        .font(.title)
                                        .foregroundColor(Color(hex: "FF9F0A")) // System Orange
                                        .frame(width: 60, height: 60)
                                        .background(AppTheme.textPrimary)
                                        .clipShape(Circle())
                                        .shadow(color: AppTheme.textPrimary.opacity(0.1), radius: 5, x: 0, y: 2)
                                    Text("暫停")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                }
                            }
                        }
                    } else {
                        Button(action: {
                            viewModel.toggleTimer()
                            faceEstimator.startSession()
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                    .foregroundColor(AppTheme.background)
                                .font(.headline)
                                Text("開始專注")
                            }
                            .font(.headline)
                            .foregroundColor(AppTheme.background)
                            .frame(width: 200, height: 50)
                            .background(AppTheme.textPrimary) // High contrast white button
                            .cornerRadius(25)
                            .shadow(color: AppTheme.textPrimary.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                    }
                    
                    
                    
                    Spacer()
                        .frame(height: 20) // Add some spacing instead of flexible spacer
                    
                    // Bottom Stats Area
                    HStack(spacing: 15) {
                        StatCard(title: "今日專注", value: calculateTodayFocusTime(), icon: "clock")
                        StatCard(title: "失敗次數", value: "\(calculateAbandonedCount())", icon: "xmark.circle")
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            
            // Custom Alert Overlay
            if showGiveUpAlert {
                ZStack {
                    Color.black.opacity(0.6)
                        .ignoresSafeArea()
                        .onTapGesture {
                            // Optional: Dismiss on background tap
                            // withAnimation { showGiveUpAlert = false }
                        }
                    
                    VStack(spacing: 20) {
                        Text("確定要放棄嗎？")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("放棄後將不會記錄此次專注時間。")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        HStack(spacing: 0) {
                            Button(action: {
                                withAnimation {
                                    showGiveUpAlert = false
                                }
                            }) {
                                Text("繼續")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            
                            Divider()
                                .frame(height: 44)
                            
                            Button(action: {
                                viewModel.endSession(completed: false)
                                faceEstimator.stopSession()
                                showSessionReport = true
                                withAnimation {
                                    showGiveUpAlert = false
                                }
                            }) {
                                Text("放棄")
                                    .font(.headline)
                                    .foregroundColor(.red)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .padding(.top, 10)
                    }
                    .padding(.top, 24)
                    .background(Color.white)
                    .cornerRadius(16)
                    .frame(width: 300)
                    .shadow(radius: 20)
                }
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .fullScreenCover(isPresented: $showFocusMode) {
            FlipClockView(timeRemaining: $viewModel.timeRemaining, isRunning: $viewModel.isTimerRunning, totalTime: $viewModel.totalTime)
        }
        .sheet(isPresented: $showSessionReport) {
            SessionReportView(
                sessionData: faceEstimator.sessionData,
                totalReadingTime: faceEstimator.accumulatedReadingTime
            )
        }
        .onAppear {
            viewModel.requestNotificationPermission()
        }
        .onChange(of: viewModel.timeRemaining) { remaining in
            if remaining == 0 && viewModel.isTimerRunning {
                // Timer finished naturally
                faceEstimator.stopSession()
                showSessionReport = true
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.checkBackgroundTime()
            }
        }
    }
    
    // MARK: - Logic
    
    func calculateTodayFocusTime() -> String {
        let todaySessions = viewModel.focusSessions.filter {
            Calendar.current.isDateInToday($0.startTime) && $0.status == .completed
        }
        let totalSeconds = todaySessions.reduce(0) { $0 + $1.duration }
        let minutes = Int(totalSeconds) / 60
        return "\(minutes)m"
    }
    
    func calculateAbandonedCount() -> Int {
        viewModel.focusSessions.filter {
            Calendar.current.isDateInToday($0.startTime) && $0.status == .abandoned
        }.count
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption)
                    .foregroundColor(AppTheme.textSecondary)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(AppTheme.textSecondary)
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppTheme.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppTheme.surface)
        .cornerRadius(15)
    }
}

struct ModeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? AppTheme.background : AppTheme.textSecondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AppTheme.textPrimary : Color.clear)
                .cornerRadius(20)
        }
    }
}

#Preview {
    PomodoroView()
        .environmentObject(TaskViewModel())
}
