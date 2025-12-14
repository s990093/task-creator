import SwiftUI

struct DebugPanel: View {
    @ObservedObject var faceEstimator: FaceEstimator
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Focus Monitor (Face)")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 20) {
                StatItem(
                    label: "Head Pitch",
                    value: String(format: "%.2f", faceEstimator.headPitch),
                    threshold: "> \(String(format: "%.1f", FocusConfig.pitchMin))",
                    isGood: faceEstimator.headPitch > FocusConfig.pitchMin
                )
                
                StatItem(
                    label: "Head Tilt",
                    value: String(format: "%.1f°", faceEstimator.headTilt),
                    threshold: "<\(Int(FocusConfig.headTiltMax))°",
                    isGood: abs(faceEstimator.headTilt) < FocusConfig.headTiltMax
                )
                
                StatItem(
                    label: "Face Turn",
                    value: String(format: "%.1f°", faceEstimator.headYaw),
                    threshold: "<\(Int(FocusConfig.headYawMax))°",
                    isGood: abs(faceEstimator.headYaw) < FocusConfig.headYawMax
                )
            }
            
            Divider().background(Color.gray)
            
            Text(faceEstimator.statusMessage)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(faceEstimator.isGoodPosture ? .green : .red)
            
            Text(faceEstimator.debugLog)
                .font(.caption2)
                .foregroundColor(.yellow)
                .lineLimit(1)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(15)
        .padding(.horizontal)
        .padding(.bottom, 30)
    }
}

struct StatItem: View {
    let label: String
    let value: String
    let threshold: String
    let isGood: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(isGood ? .green : .red)
            Text(threshold)
                .font(.caption2)
                .foregroundColor(.gray.opacity(0.8))
        }
        .frame(minWidth: 80)
    }
}
