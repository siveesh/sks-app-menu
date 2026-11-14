import Foundation
import MenuCore

struct LauncherGridLayout {
    enum Direction { case left, right, up, down }
    let density: LauncherDensity
    static let spacing: Double = 12
    static let padding: Double = 16

    var minimumCellWidth: Double {
        switch density {
        case .compact: 96
        case .comfortable: 112
        case .spacious: 144
        }
    }

    var cellHeight: Double {
        switch density {
        case .compact: 100
        case .comfortable: 124
        case .spacious: 152
        }
    }

    func columnCount(for width: Double) -> Int {
        guard width.isFinite else { return 1 }
        let usable = max(0, width - Self.padding * 2)
        return max(1, Int(min(64, (usable + Self.spacing) / (minimumCellWidth + Self.spacing))))
    }

    func nextIndex(from current: Int?, direction: Direction, count: Int, columns: Int) -> Int? {
        guard count > 0 else { return nil }
        guard let current, (0..<count).contains(current) else { return 0 }
        let columns = max(1, columns)
        switch direction {
        case .left: return current % columns == 0 ? current : current - 1
        case .right: return current % columns == columns - 1 ? current : min(count - 1, current + 1)
        case .up: return current >= columns ? current - columns : current
        case .down: return current + columns < count ? current + columns : current
        }
    }
}
