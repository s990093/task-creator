import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var opacity = 0.0
    @State private var showProfile = false
    @State private var showAIPlanner = false
    @State private var showTaskCreation = false
    
    /// 今日的任務（依 dueDate 是否為今天判斷），並排序：未完成在前，已完成在後
    private var todayTasks: [Task] {
        let calendar = Calendar.current
        return viewModel.tasks
            .filter { calendar.isDateInToday($0.dueDate) }
            .sorted { t1, t2 in
                if t1.completed != t2.completed {
                    return !t1.completed
                }
                return t1.id > t2.id
            }
    }
    
    /// 今日已完成任務數量（只算今天有勾完成的）
    var completedTasks: Int {
        let calendar = Calendar.current
        return todayTasks.filter { task in
            guard task.completed, let completedDate = task.completedDate else {
                return false
            }
            return calendar.isDateInToday(completedDate)
        }.count
    }
    
    var totalTasks: Int {
        todayTasks.count
    }
    
    var progress: Double {
        totalTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)
    }
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: [Color(hex: "5B7C99"), Color(hex: "34495E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("嗨，未來的你 👋")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("今天專注在哪些科目呢？")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        Spacer()
                        
                        // Avatar with notification dot
                        ZStack(alignment: .topTrailing) {
                            Circle()
                                .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 44, height: 44)
                            
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "5B7C99"), lineWidth: 2)
                                )
                                .offset(x: 4, y: -4)
                        }
                        .onTapGesture {
                            showProfile = true
                        }
                        .sheet(isPresented: $showProfile) {
                            ProfileView()
                        }
                    }
                    .padding(.top, 8)
                    
                    // Dynamic Progress Card
                    ProgressCardView(completedTasks: completedTasks, totalTasks: totalTasks)
                    
                    // Important Dates Section
                    ImportantDatesSectionView()
                    
                    // Today's Tasks Section + AI Assistant + Task Categories
                    HStack(spacing: 12) {
                        Text("今日任務")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Task Management Category Button
                        Button {
                            showTaskCreation = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "folder.fill")
                                Text("任務類別")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.green, Color.teal],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 6)
                        }
                        
                        // AI Assistant Button
                        Button {
                            showAIPlanner = true
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                Text("AI 助手")
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                LinearGradient(
                                    colors: [Color.purple, Color.blue],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundColor(.white)
                            .cornerRadius(999)
                            .overlay(
                                RoundedRectangle(cornerRadius: 999)
                                    .stroke(Color.white.opacity(0.4), lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 6)
                        }
                    }
                    .padding(.top, 8)
                    
                    // Task Cards（顯示今日任務，未完成在前）
                    VStack(spacing: 12) {
                        ForEach(todayTasks) { task in
                            TaskCardHomeView(task: task)
                        }
                    }
                }
                .padding(.horizontal)
                .opacity(opacity)
                .offset(y: opacity == 0 ? 20 : 0)
            }
        }
        .sheet(isPresented: $showAIPlanner) {
            AIStudyPlanSheet()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $showTaskCreation) {
            QuickTaskCreationSheet()
                .environmentObject(viewModel)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                opacity = 1.0
            }
        }
    }
}


#Preview {
    HomeView()
        .environmentObject(TaskViewModel())
}
