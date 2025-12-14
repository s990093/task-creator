import SwiftUI
import Vision

class FaceEstimator: ObservableObject {
    // Metrics
    @Published var headTilt: Double = 0.0 // Roll
    @Published var headYaw: Double = 0.0  // Turn
    @Published var headPitch: Double = 0.0 // Pitch (Ratio)
    
    // Status
    @Published var isGoodPosture: Bool = true
    @Published var statusMessage: String = "Initializing..."
    
    // Debug
    @Published var debugLog: String = "Waiting for camera..."
    @Published var currentObservation: VNFaceObservation?
    
    // State Tracking
    private var badPostureStartTime: Date?
    
    // Session Data
    struct PostureDataPoint: Identifiable {
        let id = UUID()
        let timestamp: TimeInterval
        let pitch: Double
        let isGood: Bool
    }
    
    @Published var sessionData: [PostureDataPoint] = []
    @Published var accumulatedReadingTime: TimeInterval = 0
    @Published var isSessionActive: Bool = false
    
    private var sessionStartTime: Date?
    private var lastGoodPostureTime: Date?
    
    // MARK: - Session Control
    
    func startSession() {
        DispatchQueue.main.async {
            self.sessionData = []
            self.accumulatedReadingTime = 0
            self.isSessionActive = true
            self.sessionStartTime = Date()
            self.lastGoodPostureTime = nil
            self.badPostureStartTime = nil
            self.updateDebugLog("Session Started")
        }
    }
    
    func stopSession() {
        DispatchQueue.main.async {
            self.isSessionActive = false
            self.sessionStartTime = nil
            self.currentObservation = nil // Clear observation
            self.updateDebugLog("Session Ended")
        }
    }
    
    func updateNoFace() {
        DispatchQueue.main.async {
            self.currentObservation = nil
        }
        updatePostureStatus(isInstantaneouslyBad: true, badMessage: "No Face Detected")
    }
    
    func processObservation(_ observation: VNFaceObservation) {
        // 1. Update Visualization & Metrics
        guard let landmarks = observation.landmarks else {
            updateDebugLog("No landmarks detected")
            return
        }
        
        // Calculate Metrics
        var tilt: Double = 0.0
        var yaw: Double = 0.0
        var pitchRatio: Double = 0.0
        
        // --- Head Tilt (Roll) ---
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye {
            let lCenter = averagePoint(leftEye.normalizedPoints)
            let rCenter = averagePoint(rightEye.normalizedPoints)
            let dy = rCenter.y - lCenter.y
            let dx = rCenter.x - lCenter.x
            tilt = atan2(dy, dx) * 180 / .pi
        }
        
        // --- Head Yaw (Turn) ---
        if let nose = landmarks.nose, let contour = landmarks.faceContour {
            let noseCenter = averagePoint(nose.normalizedPoints)
            let points = contour.normalizedPoints
            if let minX = points.map({ $0.x }).min(),
               let maxX = points.map({ $0.x }).max() {
                let faceWidth = maxX - minX
                let noseRelX = noseCenter.x - minX
                let ratio = noseRelX / faceWidth
                yaw = (ratio - 0.5) * 180
            }
        }
        
        // --- Head Pitch (Look Down) ---
        if let leftEye = landmarks.leftEye, let rightEye = landmarks.rightEye,
           let nose = landmarks.nose, let innerLips = landmarks.innerLips {
            
            let lEyeY = averagePoint(leftEye.normalizedPoints).y
            let rEyeY = averagePoint(rightEye.normalizedPoints).y
            let eyeY = (lEyeY + rEyeY) / 2.0
            let noseY = averagePoint(nose.normalizedPoints).y
            let mouthY = averagePoint(innerLips.normalizedPoints).y
            
            let eyeToNose = eyeY - noseY
            let noseToMouth = noseY - mouthY
            
            if noseToMouth > 0.01 {
                pitchRatio = eyeToNose / noseToMouth
            }
        }
        
        // 2. Publish Metrics
        DispatchQueue.main.async {
            self.headTilt = tilt
            self.headYaw = yaw
            self.headPitch = pitchRatio
            self.currentObservation = observation
        }
        
        // 3. Evaluate Posture
        let isTiltBad = abs(tilt) > FocusConfig.headTiltMax
        let isYawBad = abs(yaw) > FocusConfig.headYawMax
        let isPitchBad = pitchRatio < FocusConfig.pitchMin
        
        let isBad = isTiltBad || isYawBad || isPitchBad
        var message = "Reading (Good)"
        
        if isPitchBad { message = "Look Down!" }
        else if isTiltBad { message = "Head Tilted!" }
        else if isYawBad { message = "Face Forward!" }
        
        updatePostureStatus(isInstantaneouslyBad: isBad, badMessage: message)
        
        // 4. Record Data (if session active)
        if isSessionActive, let startTime = sessionStartTime {
            let now = Date()
            let elapsed = now.timeIntervalSince(startTime)
            
            // Record Data Point
            let dataPoint = PostureDataPoint(
                timestamp: elapsed,
                pitch: pitchRatio,
                isGood: !isBad
            )
            
            DispatchQueue.main.async {
                self.sessionData.append(dataPoint)
                
                // Update Reading Time
                if !isBad {
                    if let lastGood = self.lastGoodPostureTime {
                        let timeDiff = now.timeIntervalSince(lastGood)
                        // Only add reasonable time increments (e.g., < 1s) to avoid jumps
                        if timeDiff < 1.0 {
                            self.accumulatedReadingTime += timeDiff
                        }
                    }
                    self.lastGoodPostureTime = now
                } else {
                    self.lastGoodPostureTime = nil
                }
            }
        }
    }
    
    private func updatePostureStatus(isInstantaneouslyBad: Bool, badMessage: String) {
        DispatchQueue.main.async {
            if isInstantaneouslyBad {
                // If this is the start of bad posture, record time
                if self.badPostureStartTime == nil {
                    self.badPostureStartTime = Date()
                }
                
                // Check elapsed time
                let elapsed = Date().timeIntervalSince(self.badPostureStartTime!)
                if elapsed >= FocusConfig.postureGracePeriod {
                    // Grace period over, flag as bad
                    self.isGoodPosture = false
                    self.statusMessage = badMessage
                    self.debugLog = "Bad Posture Detected"
                } else {
                    // Still in grace period
                    self.isGoodPosture = true
                    self.statusMessage = "Reading (Good)"
                    let remaining = Int(ceil(FocusConfig.postureGracePeriod - elapsed))
                    self.debugLog = "Pending: \(badMessage) (\(remaining)s)"
                }
            } else {
                // Posture is good, reset timer
                self.badPostureStartTime = nil
                self.isGoodPosture = true
                self.statusMessage = "Reading (Good)"
                self.debugLog = "Tracking Face (Good)"
            }
        }
    }
    
    private func averagePoint(_ points: [CGPoint]) -> CGPoint {
        guard !points.isEmpty else { return .zero }
        let sum = points.reduce(CGPoint.zero) { CGPoint(x: $0.x + $1.x, y: $0.y + $1.y) }
        return CGPoint(x: sum.x / CGFloat(points.count), y: sum.y / CGFloat(points.count))
    }
    
    private func updateDebugLog(_ message: String) {
        DispatchQueue.main.async {
            self.debugLog = message
        }
    }
}
