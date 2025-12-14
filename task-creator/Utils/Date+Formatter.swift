import Foundation

// MARK: - Date Extension for TimeZone Support
extension Date {
    /// 使用應用設定的時區格式化日期
    func formattedWithAppTimeZone(_ format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZoneManager.shared.currentTimeZone
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// 獲取在應用時區下的當前時間
    static func nowInAppTimeZone() -> Date {
        return Date()
    }
    
    /// 獲取特定時區的當前日期組件
    func components(in timezone: TimeZone = TimeZoneManager.shared.currentTimeZone) -> DateComponents {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
    }
    
    /// 檢查是否在今天（使用應用時區）
    func isToday(in timezone: TimeZone = TimeZoneManager.shared.currentTimeZone) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.isDateInToday(self)
    }
    
    /// 檢查是否在本週（使用應用時區）
    func isThisWeek(in timezone: TimeZone = TimeZoneManager.shared.currentTimeZone) -> Bool {
        var calendar = Calendar.current
        calendar.timeZone = timezone
        return calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear)
    }
}

// MARK: - Calendar Extension for TimeZone Support
extension Calendar {
    /// 獲取使用應用時區的 Calendar
    static var appTimeZone: Calendar {
        var calendar = Calendar.current
        calendar.timeZone = TimeZoneManager.shared.currentTimeZone
        return calendar
    }
}
