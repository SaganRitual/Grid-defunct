// We are a way for the cosmos to know itself. -- C. Sagan

import XCTest
@testable import Grid

class GridTests: XCTestCase {

    override func setUpWithError() throws {
        Grid.makeGrid(KGSize(width: 100, height: 100))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForSmoke() throws {
        let area = Grid.gridDimensionsCells.area()
        let expectedArea = 99 * 99  // Because grid likes odd
        XCTAssert(
            area == expectedArea,
            "100 x 100 grid should contain \(expectedArea) cells, got \(area)"
        )
    }

    func testCell() throws {
        let c1 = Grid.cellAt(0)
        XCTAssert(
            c1.properties.gridPosition == KGPoint(x: -49, y: 49),
            "Cell 0 should be in the upper-left corner of the grid (x: -49, y: 49)"
        )

        let c2 = Grid.cellAt(KGPoint.zero)
        let expectedIx = (49 * 99) + 49 // halfway down and halfway across
        XCTAssert(
            c2.properties.gridAbsoluteIndex == expectedIx,
            "Cell at (0, 0) should be in the center"
            + " of the grid abs index \(expectedIx)"
            + ", got \(c2.properties.gridAbsoluteIndex)"
        )

        let c3 = Grid.cellAt(99 * 99 - 1)
        let expectedPosition = KGPoint(x: 49, y: -49)
        XCTAssert(
            c3.properties.gridPosition == expectedPosition,
            "Cell at index \(99 * 99 - 1)"
            + " should be in the lower right corner"
            + " of the grid \(expectedPosition)"
            + ", got \(c3.properties.gridPosition)"
        )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
