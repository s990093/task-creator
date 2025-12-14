import SwiftUI

struct DateCardView: View {
    let date: ImportantDate
    
    var daysRemaining: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfTargetDate = calendar.startOfDay(for: date.date)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTargetDate)
        return components.day ?? 0
    }
    
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top Row: Color Bar and Date
            HStack(alignment: .top) {
                // Color Bar
                Capsule()
                    .fill(Color(hex: date.color))
                    .frame(width: 6, height: 24)
                
                Spacer()
                
                // Date
                Text(dateString)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            // Title
            Text(date.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            // Bottom Row: Countdown and Icon
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("倒數")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(max(0, daysRemaining))")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("天")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Image(systemName: date.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: date.color).opacity(0.8))
            }
        }
        .padding(16)
        .frame(width: 160, height: 160)
        .background(Color(hex: "2C3E50")) // Dark blue-grey background
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            DateCardView(date: ImportantDate(title: "第一次模擬考", date: Date().addingTimeInterval(86400 * 8), color: "FF5252", icon: "clock"))
            DateCardView(date: ImportantDate(title: "期末報告繳交", date: Date().addingTimeInterval(86400 * 13), color: "FF9800", icon: "doc.text"))
        }
    }
}
