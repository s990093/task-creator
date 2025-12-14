import SwiftUI

// MARK: - 企鵝 Loading 動畫
struct PenguinLoadingView: View {
    @State private var isSpinning = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Loading...")
                .font(.title3)
                .foregroundColor(.gray)
            
            ZStack {
                // 企鵝身體
                VStack(spacing: 0) {
                    // 頭部
                    Circle()
                        .fill(Color(hex: "5A6E7F"))
                        .frame(width: 80, height: 80)
                        .overlay(
                            // 臉
                            VStack(spacing: 8) {
                                // 眼睛
                                HStack(spacing: 20) {
                                    Circle()
                                        .fill(.black)
                                        .frame(width: 6, height: 6)
                                    Circle()
                                        .fill(.black)
                                        .frame(width: 6, height: 6)
                                }
                                .offset(y: -5)
                                
                                // 嘴巴
                                Capsule()
                                    .fill(Color.orange)
                                    .frame(width: 12, height: 4)
                            }
                        )
                        .overlay(
                            // 白色肚皮部分
                            Circle()
                                .fill(.white)
                                .frame(width: 40, height: 50)
                                .offset(y: 15)
                        )
                    
                    // 身體
                    RoundedRectangle(cornerRadius: 40)
                        .fill(Color(hex: "5A6E7F"))
                        .frame(width: 90, height: 60)
                        .overlay(
                            // 白色肚皮
                            RoundedRectangle(cornerRadius: 30)
                                .fill(.white)
                                .frame(width: 50, height: 50)
                        )
                    
                    // 腳
                    HStack(spacing: 20) {
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: 20, height: 8)
                        Capsule()
                            .fill(Color.orange)
                            .frame(width: 20, height: 8)
                    }
                    .offset(y: -5)
                }
                
                // 左手（抱著螢幕的手）
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "4A9B8E"))
                    .frame(width: 30, height: 50)
                    .rotationEffect(.degrees(-20))
                    .offset(x: -45, y: 20)
                
                // 右手（抱著螢幕的手）
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(hex: "4A9B8E"))
                    .frame(width: 30, height: 50)
                    .rotationEffect(.degrees(20))
                    .offset(x: 45, y: 20)
                
                // 螢幕（中間的 loading spinner）
                RoundedRectangle(cornerRadius: 8)
                    .fill(.white)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .trim(from: 0, to: 0.7)
                            .stroke(
                                Color(hex: "4A9B8E"),
                                style: StrokeStyle(lineWidth: 4, lineCap: .round)
                            )
                            .frame(width: 30, height: 30)
                            .rotationEffect(.degrees(isSpinning ? 360 : 0))
                            .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: isSpinning)
                    )
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .offset(y: 30)
            }
            .onAppear {
                isSpinning = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    PenguinLoadingView()
}
