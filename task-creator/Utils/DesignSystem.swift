import SwiftUI

extension Color {
    // Backgrounds
    static let slate900 = Color(hex: "0f172a")
    static let slate800 = Color(hex: "1e293b")
    
    // Text
    static let slate100 = Color(hex: "f1f5f9")
    static let slate400 = Color(hex: "94a3b8")
    
    // Functional
    static let emerald500 = Color(hex: "10b981")
    static let brandBlue = Color(hex: "2563eb")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct AppTheme {
    static let background = Color.slate900
    static let surface = Color.slate800
    static let textPrimary = Color.slate100
    static let textSecondary = Color.slate400
}
