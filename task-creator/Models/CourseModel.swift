import Foundation
import SwiftUI

struct Course: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var name: String
    var location: String
    var dayOfWeek: Day
    var startPeriod: Int // 1-10
    var endPeriod: Int // 1-10
    var colorHex: String
    
    // Computed property for SwiftUI Color
    var color: Color {
        Color(hex: colorHex)
    }
    
    // Validation
    var isValid: Bool {
        return !name.isEmpty &&
               startPeriod >= 1 && startPeriod <= 10 &&
               endPeriod >= 1 && endPeriod <= 10 &&
               endPeriod >= startPeriod
    }
    
    // Display time range (e.g., "第3-4節")
    var periodRange: String {
        if startPeriod == endPeriod {
            return "第\(startPeriod)節"
        } else {
            return "第\(startPeriod)-\(endPeriod)節"
        }
    }
}

// Preset colors for course selection
struct CourseColor {
    static let presets: [String] = [
        "FF6B6B", // Red/Pink
        "FF8C42", // Orange
        "B8860B", // Dark Goldenrod (Yellow-brown)
        "4ECDC4", // Teal/Cyan
        "45B7D1", // Light Blue
        "5B8DEE", // Blue
        "9B59B6", // Purple
        "C56AB4", // Pink-Purple
        "E91E63"  // Deep Pink/Magenta
    ]
    
    static func randomPreset() -> String {
        return presets.randomElement() ?? presets[0]
    }
}
