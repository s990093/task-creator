import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            // Home
            TabBarButton(icon: "square.grid.2x2", title: "首頁", isSelected: selectedTab == 0) {
                selectedTab = 0
            }
            .accessibilityIdentifier("Tab_Home")

            Spacer()

            // Tasks
            TabBarButton(icon: "book", title: "任務", isSelected: selectedTab == 1) {
                selectedTab = 1
            }
            .accessibilityIdentifier("Tab_Tasks")

            Spacer()

            // Focus
            TabBarButton(icon: "stopwatch", title: "番茄鐘", isSelected: selectedTab == 2) {
                selectedTab = 2
            }
            .accessibilityIdentifier("Tab_Pomodoro")

            Spacer()

            // AI Assistant
            TabBarButton(icon: "brain.head.profile", title: "AI 助理", isSelected: selectedTab == 3) {
                selectedTab = 3
            }
            .accessibilityIdentifier("Tab_AI")

            // Divider
            Divider()
                .frame(height: 24)
                .background(AppTheme.textSecondary.opacity(0.3))
                .padding(.horizontal, 10)

            // Me
            TabBarButton(icon: "person", title: "我的", isSelected: selectedTab == 4) {
                selectedTab = 4
            }
            .accessibilityIdentifier("Tab_Me")
        }
        .frame(height: 52)          // 🎯 這裡固定整體高度
        .padding(.horizontal, 30)
        .background(AppTheme.surface)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.textSecondary.opacity(0.1)),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 2) {         // 原本 4 → 2，更緊湊
                Image(systemName: icon)
                    .font(.system(size: 20)) // 原本 24 → 20
        
                Text(title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? Color.brandBlue : AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}
