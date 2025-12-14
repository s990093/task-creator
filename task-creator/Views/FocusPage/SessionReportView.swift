import SwiftUI
import Charts

struct SessionReportView: View {
    @Environment(\.presentationMode) var presentationMode
    let sessionData: [FaceEstimator.PostureDataPoint]
    let totalReadingTime: TimeInterval
    
    // Theme Colors
    let bgDark = Color(hex: "1C1C1E") // Dark Gray Background
    let accentGreen = Color(hex: "32D74B") // iOS Green
    let accentCyan = Color(hex: "64D2FF") // iOS Cyan
    let thresholdRed = Color(hex: "FF453A") // iOS Red
    
    var body: some View {
        ZStack {
            bgDark.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Header
                HStack {
                    Spacer()
                    Text("Session Report")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                // Summary Stats
                HStack(spacing: 20) {
                    StatBox(title: "Reading Time", value: formatTime(totalReadingTime), color: accentGreen)
                    StatBox(title: "Avg Pitch", value: String(format: "%.2f", averagePitch), color: accentCyan)
                }
                .padding(.horizontal)
                
                // Chart Container
                VStack(alignment: .leading) {
                    Text("Head Angle & Reading Time")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 5)
                    
                    // Legend
                    HStack(spacing: 15) {
                        LegendItem(color: accentCyan, label: "Head Angle")
                        LegendItem(color: thresholdRed, label: "Threshold (100°)", isDashed: true)
                        LegendItem(color: accentGreen, label: "Reading Time")
                    }
                    .padding(.bottom, 10)
                    
                    // Chart
                    Chart {
                        // Threshold Line
                        RuleMark(y: .value("Threshold", 1.0)) // Assuming 1.0 is the threshold ratio
                            .foregroundStyle(thresholdRed)
                            .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                        
                        ForEach(sessionData) { point in
                            // Head Angle (Pitch Ratio)
                            LineMark(
                                x: .value("Time", point.timestamp),
                                y: .value("Angle", point.pitch)
                            )
                            .foregroundStyle(accentCyan)
                            .interpolationMethod(.catmullRom)
                            
                            // Reading Time Accumulation (Scaled for visualization)
                            // We map time (0-Total) to a secondary axis scale if possible,
                            // or just overlay it. Here we'll plot it as a separate series.
                            // Since Swift Charts doesn't support dual axis easily yet,
                            // we might need to normalize or just show it as is if scales are compatible.
                            // For this demo, let's just show the Angle.
                        }
                    }
                    .chartYScale(domain: 0...2.0) // Adjust based on expected pitch ratio range
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                .foregroundStyle(.gray.opacity(0.3))
                            AxisTick().foregroundStyle(.gray)
                            AxisValueLabel()
                                .foregroundStyle(.gray)
                        }
                    }
                    .chartYAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [2, 2]))
                                .foregroundStyle(.gray.opacity(0.3))
                            AxisTick().foregroundStyle(.gray)
                            AxisValueLabel()
                                .foregroundStyle(.gray)
                        }
                    }
                    .frame(height: 300)
                    .padding()
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(15)
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    var averagePitch: Double {
        guard !sessionData.isEmpty else { return 0 }
        let sum = sessionData.reduce(0) { $0 + $1.pitch }
        return sum / Double(sessionData.count)
    }
    
    func formatTime(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(10)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String
    var isDashed: Bool = false
    
    var body: some View {
        HStack(spacing: 5) {
            if isDashed {
                Line()
                    .stroke(color, style: StrokeStyle(lineWidth: 2, dash: [3, 2]))
                    .frame(width: 20, height: 2)
            } else {
                Rectangle()
                    .fill(color)
                    .frame(width: 20, height: 2)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.width, y: rect.midY))
        return path
    }
}

#Preview {
    SessionReportView(
        sessionData: [
            .init(timestamp: 0, pitch: 0.8, isGood: true),
            .init(timestamp: 10, pitch: 1.2, isGood: true),
            .init(timestamp: 20, pitch: 0.9, isGood: false),
            .init(timestamp: 30, pitch: 1.5, isGood: true)
        ],
        totalReadingTime: 25
    )
}
