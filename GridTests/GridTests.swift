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

    func testPositionCalculations() throws {
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

        let c4 = Grid.randomCell()
        let c5 = Grid.cellAt(c4.properties.gridAbsoluteIndex)
        let c6 = Grid.cellAt(c5.properties.gridPosition)
        let c7 = Grid.cellAt(c5.properties.gridAbsoluteIndex)
        XCTAssert(
            c4 == c5 && c5 == c6 && c6 == c7,
            "Conversion between absolute index to grid position failed"
        )
    }

    class Food: GridCellContents {
        let foodValue = 42
    }

    func testIndexer() throws {
        let f1 = Grid.cellAt(KGPoint(x: 21, y: -13)) // Random point
        let f2 = Grid.cellAt(f1.properties.gridPosition + KGPoint(x: 1, y: 1))

        let food = Food()
        f2.contents = food

        let f3 = Grid.first(fromCenterAt: f1, cCells: 9) { asteroid in
            (asteroid.realCell.contents as? Food) != nil
        }

        guard let check = f3, check.realCell == f2 else {
            XCTAssert(false, "Food not found where expected")
            return
        }

        f2.contents = nil

        let f4 = Grid.first(fromCenterAt: f1, cCells: 9) { asteroid in
            (asteroid.realCell.contents as? Food) != nil
        }

        XCTAssert(f4 == nil, "Found food that isn't really there")
    }

    func testAsteroidsUpperLeft() throws {
        let c1 = Grid.cellAt(0)

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            Grid.localIndexToRealGrid($0, from: c1)
        }

        // Check virtual positions
        let virtualPositionsOk = [
            KGPoint(x: +0, y: +0), KGPoint(x: +1, y: +0), KGPoint(x: +1, y: -1),
            KGPoint(x: +0, y: -1), KGPoint(x: -1, y: -1), KGPoint(x: -1, y: +0),
            KGPoint(x: -1, y: +1), KGPoint(x: +0, y: +1), KGPoint(x: +1, y: +1)
        ].enumerated().allSatisfy {
            adjacentCells[$0].relativeVirtualPosition == c1.properties.gridPosition + $1
        }

        XCTAssert(
            virtualPositionsOk,
            "adjacentCells in ring around upper-left corner show incorrect virtual positions"
        )

        // Check real positions
        let realPositionsOk = [
            KGPoint(x: -49, y: +49), KGPoint(x: -48, y: +49),
            KGPoint(x: -48, y: -48), KGPoint(x: -49, y: +48), KGPoint(x: +49, y: +48),
            KGPoint(x: +49, y: +49), KGPoint(x: +49, y: -49), KGPoint(x: -49, y: -49),
            KGPoint(x: -48, y: -49)
        ].enumerated().allSatisfy {
            adjacentCells[$0].realCell.properties.gridPosition == $1
        }

        XCTAssert(
            realPositionsOk,
            "adjacentCells in ring around upper-left corner show incorrect real position"
        )
    }

    func testAsteroidsLowerRight() throws {
        let c1 = Grid.cellAt(99 * 99 - 1)

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            Grid.localIndexToRealGrid($0, from: c1)
        }

        // Check virtual positions; simple offset from center
        let virtualPositionsOk = [
            KGPoint(x: +0, y: +0), KGPoint(x: +1, y: +0), KGPoint(x: +1, y: -1),
            KGPoint(x: +0, y: -1), KGPoint(x: -1, y: -1), KGPoint(x: -1, y: +0),
            KGPoint(x: -1, y: +1), KGPoint(x: +0, y: +1), KGPoint(x: +1, y: +1)
        ].enumerated().allSatisfy {
            adjacentCells[$0].relativeVirtualPosition == c1.properties.gridPosition + $1
        }

        XCTAssert(
            virtualPositionsOk,
            "adjacentCells in ring around lower-right corner show incorrect virtual positions"
        )

        // Check real positions, wrapped to other side of grid as necessary
        let realPositionsOk = [
            KGPoint(x: +49, y: -49), KGPoint(x: -49, y: -49),
            KGPoint(x: -49, y: +49), KGPoint(x: +49, y: +49), KGPoint(x: +48, y: +49),
            KGPoint(x: +48, y: -49), KGPoint(x: +48, y: -48), KGPoint(x: +49, y: -48),
            KGPoint(x: -49, y: -48)
        ].enumerated().allSatisfy {
            adjacentCells[$0].realCell.properties.gridPosition == $1
        }

        XCTAssert(
            realPositionsOk,
            "adjacentCells in ring around lower-right corner show incorrect real position"
        )
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
