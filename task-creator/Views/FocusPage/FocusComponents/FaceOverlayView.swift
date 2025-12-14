import SwiftUI
import Vision

struct FaceOverlayView: View {
    let observation: VNFaceObservation
    let yaw: Double
    let tilt: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 1. Bounding Box
                let rect = observation.boundingBox
                let box = CGRect(
                    x: rect.origin.x * geometry.size.width,
                    y: (1 - rect.origin.y - rect.height) * geometry.size.height,
                    width: rect.width * geometry.size.width,
                    height: rect.height * geometry.size.height
                )
                Rectangle()
                    .stroke(Color.green, lineWidth: 2)
                    .frame(width: box.width, height: box.height)
                    .position(x: box.midX, y: box.midY)
                
                // 2. Landmarks
                if let landmarks = observation.landmarks {
                    Group {
                        drawDots(landmarks.faceContour, color: .red, size: geometry.size)
                        drawDots(landmarks.leftEyebrow, color: .blue, size: geometry.size)
                        drawDots(landmarks.rightEyebrow, color: .blue, size: geometry.size)
                        drawDots(landmarks.leftEye, color: .purple, size: geometry.size)
                        drawDots(landmarks.rightEye, color: .purple, size: geometry.size)
                        drawDots(landmarks.nose, color: .orange, size: geometry.size)
                        drawDots(landmarks.outerLips, color: .red, size: geometry.size)
                        drawDots(landmarks.innerLips, color: .blue, size: geometry.size)
                    }
                }
            }
        }
    }
    
    private func drawDots(_ region: VNFaceLandmarkRegion2D?, color: Color, size: CGSize) -> some View {
        Path { path in
            guard let region = region else { return }
            for p in region.normalizedPoints {
                let point = CGPoint(x: p.x * size.width, y: (1 - p.y) * size.height)
                let dotSize: CGFloat = 4
                let rect = CGRect(x: point.x - dotSize/2, y: point.y - dotSize/2, width: dotSize, height: dotSize)
                path.addEllipse(in: rect)
            }
        }
        .fill(color)
    }
}
