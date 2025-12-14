import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject var viewModel: TaskViewModel
    @State private var showCourseForm = false
    @State private var showImageUpload = false
    @State private var selectedCourse: Course?
    @State private var showActionSheet = false
    
    private let periods = Array(1...10)
    private let gridColumns = [GridItem(.fixed(60))] + Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            AppTheme.background.ignoresSafeArea()
            
            if viewModel.courses.isEmpty {
                emptyStateView
            } else {
                scheduleGridView
            }
            
            // Floating Action Button
            Button(action: { showActionSheet = true }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(width: 60, height: 60)
                    .background(
                        LinearGradient(
                            colors: [Color.brandBlue, Color.cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                    .shadow(color: .brandBlue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(24)
        }
        .confirmationDialog("新增課程", isPresented: $showActionSheet, titleVisibility: .visible) {
            Button("手動輸入") {
                selectedCourse = nil
                showCourseForm = true
            }
            Button("上傳圖片 (AI 辨識)") {
                showImageUpload = true
            }
            Button("取消", role: .cancel) { }
        }
        .sheet(isPresented: $showCourseForm) {
            CourseFormView(course: selectedCourse) { course in
                if selectedCourse != nil {
                    viewModel.updateCourse(course)
                } else {
                    viewModel.addCourse(course)
                }
            }
            .environmentObject(viewModel)
        }
        .sheet(isPresented: $showImageUpload) {
            ScheduleImageUploadView()
                .environmentObject(viewModel)
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            Text("還沒有課程")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("點擊右下角 + 按鈕新增課程")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
    
    // MARK: - Schedule Grid
    
    private var scheduleGridView: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header Row (Days)
                headerRow
                
                // Time Grid with Courses
                GeometryReader { geometry in
                    let dayWidth = (geometry.size.width - 60) / 7
                    let periodHeight: CGFloat = 80
                    
                    HStack(spacing: 0) {
                        // Period Labels Column
                        VStack(spacing: 0) {
                            ForEach(1...10, id: \.self) { period in
                                Text("\(period)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(width: 60, height: periodHeight)
                                    .background(Color(hex: "1E293B").opacity(0.3))
                            }
                        }
                        
                        // Days Grid
                        ZStack(alignment: .topLeading) {
                            // Background Grid
                            HStack(spacing: 0) {
                                ForEach(Day.allCases) { day in
                                    VStack(spacing: 0) {
                                        ForEach(1...10, id: \.self) { _ in
                                            Rectangle()
                                                .fill(Color(hex: "1E293B").opacity(0.2))
                                                .frame(width: dayWidth, height: periodHeight)
                                                .border(Color.gray.opacity(0.1), width: 0.5)
                                        }
                                    }
                                }
                            }
                            
                            // Course Blocks with Absolute Positioning
                            ForEach(Day.allCases) { day in
                                let dayIndex = Day.allCases.firstIndex(of: day) ?? 0
                                let courses = viewModel.getCourses(for: day)
                                
                                ForEach(courses) { course in
                                    let yOffset = CGFloat(course.startPeriod - 1) * periodHeight
                                    let height = CGFloat(course.endPeriod - course.startPeriod + 1) * periodHeight
                                    
                                    CourseBlock(course: course, onTap: {
                                        selectedCourse = course
                                        showCourseForm = true
                                    })
                                    .frame(width: dayWidth - 8, height: height - 8)
                                    .offset(x: CGFloat(dayIndex) * dayWidth + 4, y: yOffset + 4)
                                }
                            }
                        }
                    }
                }
                .frame(height: 80 * 10) // 10 periods × 80 height
            }
            .padding(.horizontal, 8)
        }
    }
    
    private var headerRow: some View {
        HStack(spacing: 0) {
            // Empty corner cell
            Text("節次")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
                .frame(width: 60, height: 50)
                .background(Color(hex: "1E293B"))
            
            ForEach(Day.allCases) { day in
                VStack(spacing: 4) {
                    Text(dayDisplayName(day))
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(dayEnglishShort(day))
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color(hex: "1E293B"))
            }
        }
    }
    
    private func dayDisplayName(_ day: Day) -> String {
        switch day {
        case .mon: return "周一"
        case .tue: return "周二"
        case .wed: return "周三"
        case .thu: return "周四"
        case .fri: return "周五"
        case .sat: return "周六"
        case .sun: return "周日"
        }
    }
    
    private func dayEnglishShort(_ day: Day) -> String {
        day.rawValue
    }
}

// MARK: - Course Block

struct CourseBlock: View {
    let course: Course
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 6) {
                Text(course.name)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer(minLength: 0)
                
                if !course.location.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                        Text(course.location)
                            .font(.system(size: 9))
                            .lineLimit(1)
                    }
                    .foregroundColor(.white.opacity(0.9))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(course.color)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ScheduleView()
        .environmentObject({
            let vm = TaskViewModel()
            
            // 周一課程
            vm.addCourse(Course(
                name: "馬克思主義基本原理概論",
                location: "九教9210",
                dayOfWeek: .mon,
                startPeriod: 3,
                endPeriod: 4,
                colorHex: "FF6B6B"
            ))
            
            // 周二課程
            vm.addCourse(Course(
                name: "市場營銷",
                location: "文科樓2-7",
                dayOfWeek: .tue,
                startPeriod: 1,
                endPeriod: 2,
                colorHex: "4ECDC4"
            ))
            
            vm.addCourse(Course(
                name: "商業研究方法",
                location: "九教9110",
                dayOfWeek: .tue,
                startPeriod: 3,
                endPeriod: 4,
                colorHex: "4ECDC4"
            ))
            
            vm.addCourse(Course(
                name: "B-談寫譯4",
                location: "文科樓2-7",
                dayOfWeek: .tue,
                startPeriod: 5,
                endPeriod: 6,
                colorHex: "4ECDC4"
            ))
            
            // 周三課程
            vm.addCourse(Course(
                name: "馬克思主義基本原理概論",
                location: "九教9210",
                dayOfWeek: .wed,
                startPeriod: 3,
                endPeriod: 4,
                colorHex: "FF6B6B"
            ))
            
            vm.addCourse(Course(
                name: "市場營銷",
                location: "文科樓2-3",
                dayOfWeek: .wed,
                startPeriod: 5,
                endPeriod: 6,
                colorHex: "4ECDC4"
            ))
            
            vm.addCourse(Course(
                name: "財經寫作",
                location: "文科樓2-7",
                dayOfWeek: .wed,
                startPeriod: 9,
                endPeriod: 10,
                colorHex: "C56AB4"
            ))
            
            // 周四課程
            vm.addCourse(Course(
                name: "大學計算機 I",
                location: "文科樓6-2",
                dayOfWeek: .thu,
                startPeriod: 1,
                endPeriod: 2,
                colorHex: "5B8DEE"
            ))
            
            vm.addCourse(Course(
                name: "公共體育選項氣排球",
                location: "",
                dayOfWeek: .thu,
                startPeriod: 3,
                endPeriod: 4,
                colorHex: "FFB84D"
            ))
            
            vm.addCourse(Course(
                name: "大學計算機 I",
                location: "",
                dayOfWeek: .thu,
                startPeriod: 7,
                endPeriod: 8,
                colorHex: "5B8DEE"
            ))
            
            // 周五課程
            vm.addCourse(Course(
                name: "商務統計學",
                location: "文科樓7-2",
                dayOfWeek: .fri,
                startPeriod: 1,
                endPeriod: 2,
                colorHex: "9B59B6"
            ))
            
            vm.addCourse(Course(
                name: "B-視聽說4",
                location: "文科樓2-7",
                dayOfWeek: .fri,
                startPeriod: 5,
                endPeriod: 6,
                colorHex: "FF8C42"
            ))
            
            vm.addCourse(Course(
                name: "市場調查與預測",
                location: "九教9110",
                dayOfWeek: .fri,
                startPeriod: 5,
                endPeriod: 6,
                colorHex: "FF8C42"
            ))
            
            return vm
        }())
}
