import SwiftUI

struct AddDateSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: TaskViewModel
    
    @State private var title = ""
    @State private var date = Date()
    
    // 保留原本的顏色與圖示資料結構
    @State private var selectedColor = "FF5252"
    @State private var selectedIcon = "calendar"
    
    // 顏色與圖示選項（沿用原本設定）
    private let colorOptions = ["FF5252", "FF9800", "FFEB3B", "4CAF50", "2196F3", "9C27B0", "E91E63"]
    private let iconOptions = ["calendar", "clock", "doc.text", "graduationcap", "pencil", "star.fill", "star.fill"]
    
    // 四種標籤類型，對應既有的 color / icon 組合
    private let tagPresets: [(label: String, color: String, icon: String)] = [
        ("考試", "FF5252", "graduationcap"),
        ("作業", "FF9800", "doc.text"),
        ("假期", "4CAF50", "sun.max.fill"),
        ("其他", "2196F3", "calendar")
    ]
    
    // 日期格式顯示用
    private var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    var body: some View {
        ZStack {
            Color(hex: "111827")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack(alignment: .center, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                            .font(.system(size: 20, weight: .bold))
                    }
                    
                    Text("新增重要日程")
                        .font(.title3.weight(.bold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white.opacity(0.7))
                            .padding(8)
                            .background(Color.white.opacity(0.06))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                VStack(alignment: .leading, spacing: 16) {
                    // 事件名稱
                    VStack(alignment: .leading, spacing: 8) {
                        Text("事件名稱")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack {
                            Image(systemName: "textformat")
                                .foregroundColor(.green)
                            TextField("例如：期末考、繳交報告", text: $title)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color(hex: "111827"))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.green, lineWidth: 1)
                        )
                        .cornerRadius(18)
                    }
                    
                    // 日期
                    VStack(alignment: .leading, spacing: 8) {
                        Text("日期")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.white.opacity(0.7))
                            
                            Text(dateDisplay)
                                .foregroundColor(.white)
                                .font(.body)
                            
                            Spacer()
                            
                            DatePicker("", selection: $date, displayedComponents: .date)
                                .labelsHidden()
                                .tint(.white)
                        }
                        .padding()
                        .background(Color.white.opacity(0.04))
                        .cornerRadius(16)
                    }
                    
                    // 標籤顏色
                    VStack(alignment: .leading, spacing: 8) {
                        Text("選擇標籤顏色")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        HStack(spacing: 12) {
                            ForEach(tagPresets, id: \.label) { preset in
                                let isSelected = selectedColor == preset.color && selectedIcon == preset.icon
                                
                                Button {
                                    selectedColor = preset.color
                                    selectedIcon = preset.icon
                                } label: {
                                    Text(preset.label)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(
                                            Color(hex: preset.color).opacity(isSelected ? 1.0 : 0.18)
                                        )
                                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }
                    
                    // 細部顏色選擇（彩色圓點）
                    VStack(alignment: .leading, spacing: 8) {
                        Text("顏色")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(colorOptions, id: \.self) { hex in
                                    Circle()
                                        .fill(Color(hex: hex))
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white, lineWidth: selectedColor == hex ? 3 : 0)
                                        )
                                        .onTapGesture {
                                            selectedColor = hex
                                        }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    
                    // 細部圖示選擇
                    VStack(alignment: .leading, spacing: 8) {
                        Text("圖示")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(iconOptions, id: \.self) { icon in
                                    let isSelected = selectedIcon == icon
                                    
                                    ZStack {
                                        Circle()
                                            .fill(isSelected ? Color.blue : Color.white.opacity(0.08))
                                            .frame(width: 60, height: 60)
                                        
                                        Image(systemName: icon)
                                            .font(.system(size: 22, weight: .medium))
                                            .foregroundColor(isSelected ? .white : .gray)
                                    }
                                    .onTapGesture {
                                        selectedIcon = icon
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 建立即可按鈕
                Button {
                    viewModel.addImportantDate(title: title, date: date, color: selectedColor, icon: selectedIcon)
                    dismiss()
                } label: {
                    HStack {
                        Text("建立日程")
                            .font(.headline)
                        Image(systemName: "checkmark.circle")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.6) : Color.green)
                    .cornerRadius(18)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
                .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

#Preview {
    AddDateSheet()
        .environmentObject(TaskViewModel())
}
