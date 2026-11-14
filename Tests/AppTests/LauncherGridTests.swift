import XCTest
import MenuCore
@testable import SKsAppMenu

final class LauncherGridTests: XCTestCase {
    func testColumnsFollowViewportAndDensityWithoutZeroColumnLayouts() {
        XCTAssertEqual(LauncherGridLayout(density: .comfortable).columnCount(for: 520), 4)
        XCTAssertEqual(LauncherGridLayout(density: .spacious).columnCount(for: 520), 3)
        XCTAssertEqual(LauncherGridLayout(density: .comfortable).columnCount(for: 280), 2)
        XCTAssertEqual(LauncherGridLayout(density: .comfortable).columnCount(for: 0), 1)
    }

    func testArrowNavigationPreservesColumnsAtEdgesAndPartialLastRows() {
        let layout = LauncherGridLayout(density: .comfortable)
        XCTAssertEqual(layout.nextIndex(from: nil, direction: .down, count: 7, columns: 4), 0)
        XCTAssertEqual(layout.nextIndex(from: 2, direction: .down, count: 7, columns: 4), 6)
        XCTAssertEqual(layout.nextIndex(from: 5, direction: .up, count: 7, columns: 4), 1)
        XCTAssertEqual(layout.nextIndex(from: 4, direction: .left, count: 7, columns: 4), 4)
        XCTAssertEqual(layout.nextIndex(from: 3, direction: .right, count: 7, columns: 4), 3)
        XCTAssertEqual(layout.nextIndex(from: 5, direction: .down, count: 7, columns: 4), 5)
        XCTAssertEqual(layout.nextIndex(from: 5, direction: .right, count: 7, columns: 4), 6)
        XCTAssertEqual(layout.nextIndex(from: 6, direction: .right, count: 7, columns: 4), 6)
    }

    func testEmptyOrFilteredSelectionsNeverReferenceRemovedApps() {
        let layout = LauncherGridLayout(density: .compact)
        XCTAssertNil(layout.nextIndex(from: 0, direction: .right, count: 0, columns: 1))
        XCTAssertEqual(layout.nextIndex(from: 20, direction: .right, count: 2, columns: 1), 0)
    }
}
