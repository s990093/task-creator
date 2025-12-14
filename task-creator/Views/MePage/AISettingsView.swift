import SwiftUI

struct AISettingsView: View {
    @StateObject private var profileManager = UserProfileManager.shared
    @State private var expandedSections: Set<String> = ["identity"]
    @State private var isOptimizing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header Card
                HStack(spacing: 12) {
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 24))
                        .foregroundColor(Color(hex: "60A5FA"))
                        .frame(width: 48, height: 48)
                        .background(Color(hex: "1E40AF").opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI 認知核心")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("在此定義您的身份、目標與偏好。AI 將讀取此核心設定，為您生成客製化的學習計畫與回應。")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .lineLimit(2)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color(hex: "1E3A8A").opacity(0.3), Color(hex: "1E293B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Identity Section
                ExpandableSection(
                    icon: "person.text.rectangle.fill",
                    iconColor: "60A5FA",
                    title: "個人基本 (Identity)",
                    sectionId: "identity",
                    isExpanded: expandedSections.contains("identity")
                ) {
                    toggleSection("identity")
                } content: {
                    IdentitySection(profileManager: profileManager)
                }
                
                // Goals Section
                ExpandableSection(
                    icon: "flag.fill",
                    iconColor: "10B981",
                    title: "目標與優先順序 (Goals)",
                    sectionId: "goals",
                    isExpanded: expandedSections.contains("goals")
                ) {
                    toggleSection("goals")
                } content: {
                    GoalsSection(profileManager: profileManager)
                }
                
                // Learning Style Section
                ExpandableSection(
                    icon: "slider.horizontal.3",
                    iconColor: "A855F7",
                    title: "學習風格 (Style)",
                    sectionId: "style",
                    isExpanded: expandedSections.contains("style")
                ) {
                    toggleSection("style")
                } content: {
                    LearningStyleSection(profileManager: profileManager)
                }
                
                // Resources Section (Placeholder)
                ExpandableSection(
                    icon: "clock.fill",
                    iconColor: "F59E0B",
                    title: "資源與環境 (Resources)",
                    sectionId: "resources",
                    isExpanded: expandedSections.contains("resources")
                ) {
                    toggleSection("resources")
                } content: {
                    PlaceholderSection(message: "即將推出")
                }
                
                // Tech Section (Placeholder)
                ExpandableSection(
                    icon: "chevron.left.forwardslash.chevron.right",
                    iconColor: "06B6D4",
                    title: "格式與隱私 (Tech)",
                    sectionId: "tech",
                    isExpanded: expandedSections.contains("tech")
                ) {
                    toggleSection("tech")
                } content: {
                    PlaceholderSection(message: "即將推出")
                }
                
                // AI Sync Button
                Button {
                    optimizeAI()
                } label: {
                    HStack(spacing: 12) {
                        if isOptimizing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "sparkles")
                        }
                        Text(isOptimizing ? "同步中..." : "AI 核心同步優化")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: "4F46E5"), Color(hex: "7C3AED")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .disabled(isOptimizing)
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical)
        }
        .background(Color.black.ignoresSafeArea())
    }
    
    private func toggleSection(_ id: String) {
        withAnimation(.spring(response: 0.3)) {
            if expandedSections.contains(id) {
                expandedSections.remove(id)
            } else {
                expandedSections.insert(id)
            }
        }
    }
    
    private func optimizeAI() {
        isOptimizing = true
        
        // Simulate AI optimization
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isOptimizing = false
            
            // Show success feedback (could use a toast)
            print("AI Core synced with profile: \(profileManager.profile)")
        }
    }
}

// MARK: - Expandable Section
struct ExpandableSection<Content: View>: View {
    let icon: String
    let iconColor: String
    let title: String
    let sectionId: String
    let isExpanded: Bool
    let onTap: () -> Void
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: iconColor))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: iconColor).opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding()
                .background(Color(hex: "1E293B"))
                .cornerRadius(isExpanded ? [.topLeft, .topRight] : .allCorners, 16)
            }
            
            // Content
            if isExpanded {
                content()
                    .padding()
                    .background(Color(hex: "1E293B").opacity(0.5))
                    .cornerRadius([.bottomLeft, .bottomRight], 16)
            }
        }
        .padding(.horizontal)
    }
}

struct PlaceholderSection: View {
    let message: String
    
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundColor(.gray)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
    }
}

// MARK: - Corner Radius Extension
extension View {
    func cornerRadius(_ corners: UIRectCorner, _ radius: CGFloat) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
