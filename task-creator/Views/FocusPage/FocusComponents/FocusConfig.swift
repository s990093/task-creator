import SwiftUI

struct FocusConfig {
    // Detection Settings
    static let minConfidence: Float = 0.5
    
    // Posture Thresholds
    static let headTiltMax: Double = 15.0   // Degrees (Roll - Head leaning left/right)
    static let headYawMax: Double = 20.0    // Degrees (Turn - Looking left/right)
    static let pitchMin: Double = 0.8       // Ratio (Higher = Looking Down). Neutral is ~1.0-1.5.
    
    // Timing
    static let postureGracePeriod: TimeInterval = 5.0 // Seconds to wait before flagging bad posture
    
    // UI Settings
    static let faceContourColor: Color = .green
    static let featureColor: Color = .yellow
    static let lineWidth: CGFloat = 2
}
