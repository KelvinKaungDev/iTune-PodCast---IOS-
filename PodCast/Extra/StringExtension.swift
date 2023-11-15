import Foundation

extension String {
    func secureHttp() -> String {
        return self.contains("https") ? self : self.replacingOccurrences(of: "http", with: "https")
    }
}
