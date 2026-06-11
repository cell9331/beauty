public enum BeautyLogLevel: Int, Codable, Equatable, Comparable, Sendable {
    case none = 0
    case error = 1
    case warning = 2
    case info = 3
    case debug = 4

    public static func < (lhs: BeautyLogLevel, rhs: BeautyLogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
