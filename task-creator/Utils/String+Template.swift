import Foundation

extension String {
    func fill(_ values: [String: String]) -> String {
        var result = self
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}
