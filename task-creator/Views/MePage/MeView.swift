import SwiftUI

struct MeView: View {
    @State private var selectedTab = 0 // 0: AI Coach, 1: Review, 2: Settings
    
    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Profile Header
                HStack(spacing: 20) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .blue], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 70, height: 70)
                        
                        Text("我")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
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
                
                // Segmented Control
                HStack(spacing: 0) {
                    TabButton(title: "AI 週報", isSelected: selectedTab == 0) { selectedTab = 0 }
                    TabButton(title: "回顧", isSelected: selectedTab == 1) { selectedTab = 1 }
                    TabButton(title: "設定", isSelected: selectedTab == 2) { selectedTab = 2 }
                    TabButton(title: "課表", isSelected: selectedTab == 3) { selectedTab = 3 }
                }
                .padding()
                .background(Color(hex: "1E293B"))
                
                // Content
                TabView(selection: $selectedTab) {
                    AICoachView()
                        .tag(0)
                    
                    ReviewView()
                        .tag(1)
                    
                    AISettingsView()
                        .tag(2)
                    
                    ScheduleView()
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Rectangle()
                    .fill(isSelected ? Color.brandBlue : Color.clear)
                    .frame(height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    MeView()
        .environmentObject(TaskViewModel())
}

#Preview {
    MeView()
        .environmentObject(TaskViewModel())
}
