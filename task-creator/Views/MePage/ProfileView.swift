import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    var body: some View {
        ZStack {
            Color(hex: "0F172A").ignoresSafeArea() // Dark background
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    .opacity(0) // Hidden but takes space if needed, or just use Spacer
                    
                    Spacer()
                    
                    Text("個人設定")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Profile Card
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        // Avatar
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 80, height: 80)
                            
                            Text("我")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("未來的你")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Text("Lv.5 探索者")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.cyan)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.cyan.opacity(0.2))
                                    .cornerRadius(4)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.cyan, lineWidth: 1)
                                    )
                                
                                Text("已加入 28 天")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(24)
                    .background(Color(hex: "1E293B")) // Slate 800
                    .cornerRadius(16)
                }
                .padding()
                
                // Settings List
                VStack(spacing: 0) {
                    // Dark Mode
                    HStack {
                        Image(systemName: "moon")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("深色模式")
                            .foregroundColor(.white)
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .labelsHidden()
                            .tint(.cyan)
                    }
                    .padding()
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Daily Reminder
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("每日提醒")
                                .foregroundColor(.white)
                            Spacer()
                            Text("20:00")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Export
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("匯出學習紀錄")
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                                .font(.caption)
                        }
                        .padding()
                    }
                    
                    Divider().background(Color.gray.opacity(0.2))
                    
                    // Logout
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("登出帳號")
                                .foregroundColor(.red)
                            Spacer()
                        }
                        .padding()
                    }
                }
                .background(Color(hex: "1E293B"))
                .cornerRadius(16)
                .padding()
                
                Spacer()
                
                Text("Digital Coach v1.2.0 • Build 202311")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom)
            }
        }
    }
}

#Preview {
    ProfileView()
}
