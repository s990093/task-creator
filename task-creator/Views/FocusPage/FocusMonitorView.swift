import SwiftUI
import Vision
import AVFoundation

// MARK: - Focus Monitor View
struct FocusMonitorView: View {
    @ObservedObject var faceEstimator: FaceEstimator
    @State private var showDebugPanel = true
    @Binding var isMonitoring: Bool
    
    var body: some View {
        ZStack {
            // 1. Camera Feed
            CameraView(faceEstimator: faceEstimator, isMonitoring: $isMonitoring)
                .edgesIgnoringSafeArea(.all)
            
            // 2. Face Overlay
            if let observation = faceEstimator.currentObservation {
                FaceOverlayView(
                    observation: observation,
                    yaw: faceEstimator.headYaw,
                    tilt: faceEstimator.headTilt
                )
                .edgesIgnoringSafeArea(.all) // Fix alignment
                .zIndex(1)
            }
            
            // 3. UI Overlay
            VStack {
                // Top Bar
                HStack {
                    Spacer()
                    Button(action: { showDebugPanel.toggle() }) {
                        Image(systemName: showDebugPanel ? "eye.fill" : "eye.slash.fill")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 50)
                .padding(.trailing)
                
                Spacer()
                
                // Bottom Panel
                if showDebugPanel {
                    DebugPanel(faceEstimator: faceEstimator)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            AVCaptureDevice.requestAccess(for: .video) { _ in }
        }
    }
}

#Preview {
    FocusMonitorView(faceEstimator: FaceEstimator(), isMonitoring: .constant(true))
}
