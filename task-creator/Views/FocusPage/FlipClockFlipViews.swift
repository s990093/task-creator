import SwiftUI

struct FlipClockContent: View {
    var minutes: Int
    var seconds: Int
    
    var body: some View {
        HStack(spacing: 24) {
            // Minutes
            FlipNumberView(value: minutes)
            
            // Separator
            VStack(spacing: 24) {
                Circle().fill(Color(white: 0.2)).frame(width: 16, height: 16)
                Circle().fill(Color(white: 0.2)).frame(width: 16, height: 16)
            }
            
            // Seconds
            FlipNumberView(value: seconds)
        }
    }
}

struct FlipNumberView: View {
    var value: Int
    
    var body: some View {
        HStack(spacing: 8) {
            FlipCard(value: value / 10)
            FlipCard(value: value % 10)
        }
    }
}

struct FlipCard: View {
    var value: Int
    
    @State private var currentValue: Int
    @State private var nextValue: Int
    @State private var rotation: Double = 0
    
    init(value: Int) {
        self.value = value
        self._currentValue = State(initialValue: value)
        self._nextValue = State(initialValue: value)
    }
    
    var body: some View {
        ZStack {
            // 1. Static Background Layer
            // Top Half of Next Value (Revealed when card flips down)
            SingleCardFace(value: nextValue, type: .top)
            
            // Bottom Half of Current Value (Visible until covered by flip)
            SingleCardFace(value: currentValue, type: .bottom)
            
            // 2. Flipping Card Layer
            ZStack {
                if rotation <= 90 {
                    // Front of card: Top Half of Current Value
                    SingleCardFace(value: currentValue, type: .top)
                } else {
                    // Back of card: Bottom Half of Next Value
                    // We use scaleEffect(y: -1) to correct the mirroring caused by 180d rotation
                    SingleCardFace(value: nextValue, type: .bottom)
                        .scaleEffect(y: -1)
                }
            }
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 1, y: 0, z: 0),
                anchor: .center, // Pivot at the center (split line)
                perspective: 0.4
            )
        }
        .frame(width: 140, height: 200)
        .onChange(of: value) { newValue in
            // 1. Prepare state
            let previousValue = currentValue
            nextValue = newValue
            currentValue = previousValue // Keep showing old value during animation
            rotation = 0
            
            // 2. Animate
            withAnimation(.easeInOut(duration: 0.6)) {
                rotation = 180 // Flip down
            }
            
            // 3. Reset state after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                currentValue = newValue
                rotation = 0
            }
        }
    }
}

enum CardFaceType {
    case top, bottom
}

struct SingleCardFace: View {
    var value: Int
    var type: CardFaceType
    
    var body: some View {
        Text("\(value)")
            .font(.system(size: 160, weight: .bold, design: .rounded))
            .foregroundColor(Color(white: 0.9))
            .frame(width: 140, height: 200)
            .background(Color(hex: "1C1C1E"))
            .cornerRadius(16)
            .mask(
                GeometryReader { geo in
                    if type == .top {
                        Rectangle().frame(height: geo.size.height / 2)
                    } else {
                        Rectangle().frame(height: geo.size.height / 2)
                            .offset(y: geo.size.height / 2)
                    }
                }
            )
            .overlay(
                VStack {
                    if type == .top {
                        Spacer()
                        Rectangle().fill(Color.black.opacity(0.4)).frame(height: 1)
                    } else {
                        Rectangle().fill(Color.white.opacity(0.1)).frame(height: 1)
                        Spacer()
                    }
                }
            )
            .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}


