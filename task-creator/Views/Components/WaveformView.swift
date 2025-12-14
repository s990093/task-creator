import SwiftUICore
struct WaveformView: View {
    var isRecording: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(hex: "A78BFA"))
                    .frame(width: 4, height: isRecording ? 20 : 4)
                    .scaleEffect(y: isRecording ? CGFloat.random(in: 0.5...1.2) : 1.0)
                    .animation(
                        isRecording
                            ? Animation.easeInOut(duration: 0.2).repeatForever().delay(Double(index) * 0.1)
                            : .default,
                        value: isRecording
                    )
            }
        }
        .frame(height: 24)
    }
}
