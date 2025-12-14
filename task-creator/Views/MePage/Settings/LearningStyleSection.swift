import SwiftUI

struct LearningStyleSection: View {
    @ObservedObject var profileManager: UserProfileManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Interaction Style
            VStack(alignment: .leading, spacing: 12) {
                Text("互動風格")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack(spacing: 12) {
                    StyleCard(
                        icon: "📍",
                        title: "嚴格教練",
                        style: .strict,
                        isSelected: profileManager.profile.interactionStyle == .strict
                    ) {
                        profileManager.profile.interactionStyle = .strict
                    }
                    
                    StyleCard(
                        icon: "🤝",
                        title: "溫柔鼓勵",
                        style: .gentle,
                        isSelected: profileManager.profile.interactionStyle == .gentle
                    ) {
                        profileManager.profile.interactionStyle = .gentle
                    }
                    
                    StyleCard(
                        icon: "📊",
                        title: "理性分析",
                        style: .analytical,
                        isSelected: profileManager.profile.interactionStyle == .analytical
                    ) {
                        profileManager.profile.interactionStyle = .analytical
                    }
                }
            }
            
            // Content Depth Slider
            VStack(alignment: .leading, spacing: 12) {
                Text("內容長度與偏好")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                HStack {
                    Text("簡潔要點")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("深入解析")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Slider(value: $profileManager.profile.contentDepth, in: 0...1)
                    .accentColor(Color(hex: "EC4899"))
            }
            
            // Practical vs Theory Toggle
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("偏好實作範例 > 理論")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Toggle("", isOn: $profileManager.profile.prefersPractical)
                        .labelsHidden()
                }
            }
        }
    }
}

struct StyleCard: View {
    let icon: String
    let title: String
    let style: InteractionStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.largeTitle)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hex: "A855F7").opacity(0.3) : Color.white.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: "A855F7") : Color.clear, lineWidth: 2)
            )
        }
        .foregroundColor(.white)
    }
}
