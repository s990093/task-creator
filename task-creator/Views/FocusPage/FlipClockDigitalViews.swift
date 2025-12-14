import SwiftUI

struct DigitalClockView: View {
    var minutes: Int
    var seconds: Int
    var progress: Double
    
    var body: some View {
        ZStack {
            // Progress Indicator (Top Right)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 4)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                        
                        Text("\(Int(progress * 100))")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.green)
                    }
                    .frame(width: 40, height: 40)
                    .padding(32)
                }
                Spacer()
            }
            
            // Digital Time
            HStack(spacing: 0) {
                Text(String(format: "%02d", minutes))
                    .foregroundColor(Color(hex: "007AFF")) // Blue
                
                // Blinking Separator
                Text(":")
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.bottom, 10) // Slight adjustment for alignment
                
                Text(String(format: "%02d", seconds))
                    .foregroundColor(Color(hex: "5AC8FA")) // Light Blue/Cyan
            }
            .font(.system(size: 200, weight: .bold, design: .rounded))
            .shadow(color: Color.blue.opacity(0.3), radius: 20, x: 0, y: 0)
        }
    }
}

// MARK: - Fluid Digital Clock View
struct FluidDigitalClockView: View {
    var minutes: Int
    var seconds: Int
    var progress: Double
    
    @State private var breathOpacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Progress Ring (Top Right)
            VStack {
                HStack {
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 6)
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(Color(hex: "00D65D"), style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: progress)
                        
                        Text("\(Int(progress * 100))")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(Color(hex: "00D65D"))
                    }
                    .frame(width: 60, height: 60)
                    .padding(32)
                }
                Spacer()
            }
            
            // Huge Overlapping Digital Time
            HStack(spacing: -40) {  // Negative spacing for overlap
                FluidDigitView(digit: minutes / 10)
                FluidDigitView(digit: minutes % 10)
                
                // Breathing Colon
                VStack(spacing: 30) {
                    Circle()
                        .fill(Color.white.opacity(breathOpacity))
                        .frame(width: 20, height: 20)
                    Circle()
                        .fill(Color.white.opacity(breathOpacity))
                        .frame(width: 20, height: 20)
                }
                .padding(.horizontal, 10)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        breathOpacity = 0.5
                    }
                }
                
                FluidDigitView(digit: seconds / 10)
                FluidDigitView(digit: seconds % 10)
            }
        }
    }
}

struct FluidDigitView: View {
    let digit: Int
    @State private var currentDigit: Int
    @State private var nextDigit: Int?
    @State private var slideOffset: CGFloat = 0
    
    init(digit: Int) {
        self.digit = digit
        self._currentDigit = State(initialValue: digit)
    }
    
    var body: some View {
        ZStack {
            // Current Digit
            Text("\(currentDigit)")
                .font(.system(size: 280, weight: .black, design: .rounded))
                .foregroundColor(Color(hex: "2B92E4"))
                .blendMode(.normal)
                .offset(y: slideOffset)
                .opacity(nextDigit == nil ? 1 : 0)
            
            // Next Digit (sliding in)
            if let next = nextDigit {
                Text("\(next)")
                    .font(.system(size: 280, weight: .black, design: .rounded))
                    .foregroundColor(Color(hex: "2B92E4"))
                    .blendMode(.normal)
                    .offset(y: slideOffset + 280)
            }
        }
        .compositingGroup()  // This creates the overlay effect
        .onChange(of: digit) { newValue in
            nextDigit = newValue
            slideOffset = 0
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                slideOffset = -280
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                currentDigit = newValue
                nextDigit = nil
                slideOffset = 0
            }
        }
    }
}


