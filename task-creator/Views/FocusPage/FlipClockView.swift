import SwiftUI

enum ClockStyle: CaseIterable {
    case flip
    case digital
    case fluidDigital
}

struct FlipClockView: View {
    @Binding var timeRemaining: TimeInterval
    @Binding var isRunning: Bool
    @Binding var totalTime: TimeInterval
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentStyle: ClockStyle = .flip
    
    // Timer to ensure updates happen even if parent view is paused
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var minutes: Int {
        Int(timeRemaining) / 60
    }
    
    var seconds: Int {
        Int(timeRemaining) % 60
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.ignoresSafeArea()
                
                // Main Content (Rotated)
                ZStack {
                    // Exit Button (Top Left in Landscape)
                    VStack {
                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                                    .padding(32) // Larger touch area
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    .zIndex(100) // Ensure button is always on top
                    
                    // Style Switch Button (Bottom Left in Landscape)
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: cycleStyle) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 32))
                                    .foregroundColor(.white)
                                    .opacity(0.6)
                                    .padding(32)
                            }
                            Spacer()
                        }
                    }
                    .zIndex(100)
                    
                    // Clock Content
                    Group {
                        switch currentStyle {
                        case .flip:
                            FlipClockContent(minutes: minutes, seconds: seconds)
                                .transition(.move(edge: .top))
                        case .digital:
                            DigitalClockView(minutes: minutes, seconds: seconds, progress: totalTime > 0 ? timeRemaining / totalTime : 0)
                                .transition(.move(edge: .trailing))
                        case .fluidDigital:
                            FluidDigitalClockView(minutes: minutes, seconds: seconds, progress: totalTime > 0 ? timeRemaining / totalTime : 0)
                                .transition(.move(edge: .bottom))
                        }
                    }
                }
                .frame(width: geo.size.height, height: geo.size.width) // Swap dimensions for landscape
                .rotationEffect(.degrees(90)) // Rotate 90 degrees
                .position(x: geo.size.width / 2, y: geo.size.height / 2) // Center in screen
            }
        }
        .ignoresSafeArea()
        .statusBar(hidden: true)
        .onReceive(timer) { _ in
            guard isRunning && timeRemaining > 0 else { return }
            timeRemaining -= 1
        }
    }
    
    func cycleStyle() {
        withAnimation(.spring()) {
            let allStyles = ClockStyle.allCases
            if let currentIndex = allStyles.firstIndex(of: currentStyle) {
                let nextIndex = (currentIndex + 1) % allStyles.count
                currentStyle = allStyles[nextIndex]
            }
        }
    }
}
