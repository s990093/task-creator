import SwiftUI

struct CourseFormView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var courseName: String
    @State private var location: String
    @State private var selectedDay: Day
    @State private var startPeriod: Int
    @State private var endPeriod: Int
    @State private var selectedColorHex: String
    
    let editingCourse: Course?
    let onSave: (Course) -> Void
    
    init(course: Course? = nil, onSave: @escaping (Course) -> Void) {
        self.editingCourse = course
        self.onSave = onSave
        
        _courseName = State(initialValue: course?.name ?? "")
        _location = State(initialValue: course?.location ?? "")
        _selectedDay = State(initialValue: course?.dayOfWeek ?? .mon)
        _startPeriod = State(initialValue: course?.startPeriod ?? 1)
        _endPeriod = State(initialValue: course?.endPeriod ?? 2)
        _selectedColorHex = State(initialValue: course?.colorHex ?? CourseColor.presets[0])
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Course Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("課程名稱")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            TextField("請輸入課程名稱", text: $courseName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Location
                        VStack(alignment: .leading, spacing: 8) {
                            Text("教室 / 地點")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            TextField("請輸入教室或地點", text: $location)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Day Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("周次 (1-7)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            Picker("週次", selection: $selectedDay) {
                                ForEach(Day.allCases) { day in
                                    Text(dayDisplayName(day)).tag(day)
                                }
                            }
                            .pickerStyle(.menu)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color(hex: "1E293B"))
                            .cornerRadius(12)
                        }
                        
                        HStack(spacing: 16) {
                            // Start Period
                            VStack(alignment: .leading, spacing: 8) {
                                Text("開始節次")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Picker("開始", selection: $startPeriod) {
                                    ForEach(1...10, id: \.self) { period in
                                        Text("第 \(period) 節").tag(period)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "1E293B"))
                                .cornerRadius(12)
                            }
                            
                            // End Period
                            VStack(alignment: .leading, spacing: 8) {
                                Text("結束節次")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.gray)
                                
                                Picker("結束", selection: $endPeriod) {
                                    ForEach(1...10, id: \.self) { period in
                                        Text("第 \(period) 節").tag(period)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "1E293B"))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Color Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("顏色標籤")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.gray)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 9), spacing: 12) {
                                ForEach(CourseColor.presets, id: \.self) { colorHex in
                                    ColorCircle(
                                        colorHex: colorHex,
                                        isSelected: selectedColorHex == colorHex,
                                        action: { selectedColorHex = colorHex }
                                    )
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            if editingCourse != nil {
                                Button(action: deleteCourse) {
                                    Text("刪除")
                                        .font(.headline)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red.opacity(0.1))
                                        .cornerRadius(12)
                                }
                            }
                            
                            Button(action: saveCourse) {
                                Text("保存修改")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [Color.brandBlue, Color.cyan],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(12)
                            }
                            .disabled(!isValidForm)
                            .opacity(isValidForm ? 1.0 : 0.5)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle(editingCourse == nil ? "新增課程" : "編輯課程 (AI 識別)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
        }
    }
    
    private var isValidForm: Bool {
        !courseName.isEmpty && endPeriod >= startPeriod
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
    
    private func saveCourse() {
        let course = Course(
            id: editingCourse?.id ?? UUID().uuidString,
            name: courseName,
            location: location.isEmpty ? "教室" : location,
            dayOfWeek: selectedDay,
            startPeriod: startPeriod,
            endPeriod: endPeriod,
            colorHex: selectedColorHex
        )
        
        onSave(course)
        dismiss()
    }
    
    private func deleteCourse() {
        if let course = editingCourse {
            viewModel.deleteCourse(course)
            dismiss()
        }
    }
}

// MARK: - Supporting Views

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(hex: "1E293B"))
            .cornerRadius(12)
            .foregroundColor(.white)
    }
}

struct ColorCircle: View {
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex).opacity(0.3))
                    .frame(width: 44, height: 44)
                
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .stroke(Color.brandBlue, lineWidth: 3)
                        .frame(width: 44, height: 44)
                }
            }
        }
    }
}

#Preview {
    CourseFormView(onSave: { _ in })
        .environmentObject(TaskViewModel())
}
