import SwiftUI

struct ProgressCardView: View {
    let completedTasks: Int
    let totalTasks: Int
    
    private var progress: Double {
        totalTasks == 0 ? 0 : Double(completedTasks) / Double(totalTasks)
    }
    
    private var progressState: ProgressState {
        if totalTasks == 0 { return .start }
        if progress == 1.0 { return .completed }
        if progress >= 0.8 { return .almost }
        if progress >= 0.5 { return .halfway }
        if progress >= 0.2 { return .step1 }
        return .start
    }
    
    enum ProgressState {
        case start
        case step1
        case halfway
        case almost
        case completed
        
        var color: Color {
            switch self {
            case .start: return Color.blue
            case .step1: return Color.cyan
            case .halfway: return Color(hex: "30D158") // Green
            case .almost: return Color(hex: "FF9F0A") // Orange
            case .completed: return Color(hex: "FF453A") // Red/Pink
            }
        }
        
        var slogan: String {
            switch self {
            case .start: return "開始行動吧！💪"
            case .step1: return "踏出第一步了！🎯"
            case .halfway: return "已經完成一半！🎉"
            case .almost: return "最後衝刺！🔥"
            case .completed: return "太棒了！今日達成 ⭐️"
            }
        }
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "2C3E50"))
                .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            
            VStack(spacing: 20) {
                // Top Section: Mascot + Circular Progress
                HStack(alignment: .center, spacing: 30) {
                    // Robot Mascot with Speech Bubble
                    ZStack(alignment: .topTrailing) {
                        RobotMascotView(color: progressState.color)
                            .frame(width: 140, height: 140)
                        
                        // Speech Bubble
                        Text(progressState.slogan)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(12)
                            .overlay(
                                // Speech bubble tail
                                Path { path in
                                    path.move(to: CGPoint(x: 0, y: 10))
                                    path.addLine(to: CGPoint(x: -6, y: 15))
                                    path.addLine(to: CGPoint(x: 0, y: 20))
                                }
                                .fill(Color.white)
                                .offset(x: 0, y: 0)
                                , alignment: .bottomLeading
                            )
                            .rotationEffect(.degrees(-5))
                            .offset(x: 20, y: -15)
                            .animation(.spring().delay(0.2), value: progressState)
                    }
                    
                    Spacer()
                    
                    // Circular Progress Indicator
                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 8)
                            .frame(width: 90, height: 90)
                        
                        // Progress Circle
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(progressState.color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                        
                        // Percentage Text
                        VStack(spacing: 2) {
                            Text("\(Int(progress * 100))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("(\(completedTasks)/\(totalTasks))")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Bottom Section: Linear Progress Bar
                VStack(spacing: 8) {
                    HStack {
                        Text("今日進度 (\(completedTasks)/\(totalTasks))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(Int(progress * 100))%")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    // Progress Bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            // Track
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            // Indicator
                            Capsule()
                                .fill(progressState.color)
                                .frame(width: max(8, geo.size.width * progress), height: 8)
                                .animation(.spring(), value: progress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}

// Robot Mascot View
struct RobotMascotView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // Body
            RoundedRectangle(cornerRadius: 20)
                .fill(color)
                .frame(width: 80, height: 80)
            
            // Antenna
            ZStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 4, height: 20)
                    .offset(y: -50)
                
                Circle()
                    .fill(Color(hex: "FF453A"))
                    .frame(width: 12, height: 12)
                    .offset(y: -60)
            }
            
            // Arms
            HStack(spacing: 80) {
                Capsule()
                    .fill(color)
                    .frame(width: 12, height: 40)
                    .rotationEffect(.degrees(-20))
                
                Capsule()
                    .fill(color)
                    .frame(width: 12, height: 40)
                    .rotationEffect(.degrees(20))
            }
            .offset(y: 20)
            
            // Legs
            HStack(spacing: 20) {
                Capsule()
                    .fill(color)
                    .frame(width: 16, height: 30)
                
                Capsule()
                    .fill(color)
                    .frame(width: 16, height: 30)
            }
            .offset(y: 55)
            
            // Face (on body)
            VStack(spacing: 12) {
                // Eyes
                HStack(spacing: 20) {
                    RobotEyeView()
                    RobotEyeView()
                }
                
                // Mouth (big smile)
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(to: CGPoint(x: 30, y: 0), control: CGPoint(x: 15, y: 8))
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: 30, height: 10)
            }
        }
        .animation(.spring(), value: color)
    }
}

struct RobotEyeView: View {
    var body: some View {
        ZStack {
            Circle().fill(.white).frame(width: 16, height: 16)
            Circle().fill(.black).frame(width: 8, height: 8)
        }
    }
}
