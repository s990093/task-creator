import SwiftUI
import PhotosUI

struct ScheduleImageUploadView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var selectedImage: PhotosPickerItem?
    @State private var loadedImageData: Data?
    @State private var isRecognizing = false
    @State private var recognizedCourses: [Course] = []
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showResults = false
    
    private let aiService = AIService()
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerView
                        imageSection
                        recognizeButton
                        resultsSection
                    }
                    .padding(24)
                }
            }
            .navigationTitle("AI 課表辨識")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                }
            }
            .onChange(of: selectedImage) { _, newValue in
                _Concurrency.Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        loadedImageData = data
                        showResults = false
                        recognizedCourses = []
                    }
                }
            }
            .alert("辨識失敗", isPresented: $showError) {
                Button("確定", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.image")
                .font(.system(size: 60))
                .foregroundColor(.brandBlue)
            
            Text("上傳課表圖片")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("選擇課表圖片，AI 將自動識別課程資訊")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    @ViewBuilder
    private var imageSection: some View {
        if let imageData = loadedImageData,
           let uiImage = UIImage(data: imageData) {
            imagePreviewView(uiImage: uiImage)
        } else {
            imagePickerView
        }
    }
    
    private func imagePreviewView(uiImage: UIImage) -> some View {
        VStack(spacing: 12) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 300)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            PhotosPicker(selection: $selectedImage, matching: .images) {
                HStack {
                    Image(systemName: "photo")
                    Text("更換圖片")
                }
                .font(.subheadline)
                .foregroundColor(.brandBlue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.brandBlue.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
    
    private var imagePickerView: some View {
        PhotosPicker(selection: $selectedImage, matching: .images) {
            VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 50))
                    .foregroundColor(.brandBlue)
                
                Text("選擇圖片")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("支援 PNG、JPG 格式")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(Color(hex: "1E293B"))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [10]))
                    .foregroundColor(.brandBlue.opacity(0.3))
            )
        }
    }
    
    @ViewBuilder
    private var recognizeButton: some View {
        if loadedImageData != nil && !showResults {
            Button(action: recognizeSchedule) {
                HStack(spacing: 12) {
                    if isRecognizing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        Text("辨識中...")
                    } else {
                        Image(systemName: "wand.and.stars")
                        Text("開始辨識")
                    }
                }
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
            .disabled(isRecognizing)
        }
    }
    
    @ViewBuilder
    private var resultsSection: some View {
        if showResults {
            VStack(alignment: .leading, spacing: 16) {
                resultHeader
                Divider().background(Color.gray.opacity(0.3))
                coursesList
                actionButtons
            }
            .padding()
            .background(Color(hex: "1E293B"))
            .cornerRadius(16)
        }
    }
    
    private var resultHeader: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text("識別完成！共識別到 \(recognizedCourses.count) 門課程")
                .font(.headline)
                .foregroundColor(.white)
        }
    }
    
    private var coursesList: some View {
        ForEach(recognizedCourses) { course in
            CourseResultCard(course: course)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("重新辨識") {
                showResults = false
                recognizedCourses = []
            }
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "1E293B"))
            .cornerRadius(10)
            
            Button("保存課表") {
                saveCourses()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.green, Color.cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(10)
        }
        .padding(.top, 8)
    }
    
    private func recognizeSchedule() {
        guard let imageData = loadedImageData else { return }
        
        isRecognizing = true
        
        _Concurrency.Task {
            do {
                let courses = try await aiService.extractScheduleFromImage(imageData)
                await MainActor.run {
                    recognizedCourses = courses
                    showResults = true
                    isRecognizing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "無法識別課表，請確保圖片清晰可讀。錯誤：\(error.localizedDescription)"
                    showError = true
                    isRecognizing = false
                }
            }
        }
    }
    
    private func saveCourses() {
        for course in recognizedCourses {
            viewModel.addCourse(course)
        }
        dismiss()
    }
}

// MARK: - Supporting Views

struct CourseResultCard: View {
    let course: Course
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(course.color)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(course.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    Label(course.location, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(dayDisplayName(course.dayOfWeek), systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Label(course.periodRange, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.2))
        .cornerRadius(8)
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
}

#Preview {
    ScheduleImageUploadView()
        .environmentObject(TaskViewModel())
}
