import SwiftUI

struct OnboardingView: View {
    @State private var isAnimating = false
    @State private var showText = false
    
    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.slate900, Color(hex: "0F172A")]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Logo Icon
                ZStack {
                    // Glow Effect
                    Circle()
                        .fill(Color.brandBlue.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                        .scaleEffect(isAnimating ? 1.2 : 0.8)
                    
                    Image(systemName: "square.stack.3d.up.fill")
                        .font(.system(size: 80))
                        .foregroundColor(Color.brandBlue)
                        .symbolEffect(.bounce, value: isAnimating) // iOS 17 symbol effect if available, otherwise just scale
                        .shadow(color: Color.brandBlue.opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .scaleEffect(isAnimating ? 1.0 : 0.3)
                .opacity(isAnimating ? 1.0 : 0.0)
                
                // App Name
                Text("TaskFlow")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .offset(y: showText ? 0 : 20)
                    .opacity(showText ? 1.0 : 0.0)
            }
        }
        .onAppear {
            // Sequence of animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.5, blendDuration: 0)) {
                isAnimating = true
            }
            
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                showText = true
            }
        }
    }
}

#Preview {
    OnboardingView()
}
