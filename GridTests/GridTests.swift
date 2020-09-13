// We are a way for the cosmos to know itself. -- C. Sagan

import XCTest
@testable import Grid

class GridTests: XCTestCase {
    let side: Int = 99
    var half: Int { side / 2 }

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForSmoke() throws {
        let dimensions = KGSize(width: side, height: side)
        let grid = Grid(dimensions)
        let expectedArea = (side - 1) * (side - 1)  // Because grid likes odd
        XCTAssert(
            grid.area == expectedArea,
            "\(side) x \(side) grid should contain \(expectedArea) cells, got \(grid.area)"
        )
    }

    class Food: GridCellContents {
        let foodValue = 42
    }

    func testIndexer() throws {
        let dimensions = KGSize(width: side, height: side)
        let grid = Grid(dimensions)

        let f1 = grid.cellAt(KGPoint(x: Int.random(in: -half...half), y: Int.random(in: -half...half)))
        let f2 = grid.cellAt(f1.properties.gridPosition + KGPoint(x: 1, y: 1))

        let food = Food()
        f2.contents = food

        let f3 = grid.first(fromCenterAt: f1, cMaxCells: 9) { asteroid in
            (asteroid.realCell.contents as? Food) != nil
        }

        guard let check = f3, check.realCell == f2 else {
            XCTAssert(false, "Food not found where expected")
            return
        }

        f2.contents = nil

        let f4 = grid.first(fromCenterAt: f1, cMaxCells: 9) { asteroid in
            (asteroid.realCell.contents as? Food) != nil
        }

        XCTAssert(f4 == nil, "Found food that isn't really there")
    }

    func testAsteroidsUpperLeft() throws {
        let dimensions = KGSize(width: side, height: side)
        let grid = Grid(dimensions)

        let c1 = grid.cellAt(KGPoint(x: -half, y: half))

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            grid.cellAt($0, from: c1)
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
            KGPoint(x: -half, y: +half), KGPoint(x: -(half - 1), y: +half),
            KGPoint(x: -(half - 1), y: +(half - 1)), KGPoint(x: -half, y: +(half - 1)), KGPoint(x: +half, y: +(half - 1)),
            KGPoint(x: +half, y: +half), KGPoint(x: +half, y: -half), KGPoint(x: -half, y: -half),
            KGPoint(x: -(half - 1), y: -half)
        ].enumerated().allSatisfy {
            adjacentCells[$0].realCell.properties.gridPosition == $1
        }

        XCTAssert(
            realPositionsOk,
            "adjacentCells in ring around upper-left corner show incorrect real position"
        )
    }

    func testAsteroidsLowerRight() throws {
        let dimensions = KGSize(width: side, height: side)
        let grid = Grid(dimensions)

        let c1 = grid.cellAt(KGPoint(x: half, y: -half))

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            grid.cellAt($0, from: c1)
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
            KGPoint(x: +half, y: -half), KGPoint(x: -half, y: -half),
            KGPoint(x: -half, y: +half), KGPoint(x: +half, y: +half), KGPoint(x: +(half - 1), y: +half),
            KGPoint(x: +(half - 1), y: -half), KGPoint(x: +(half - 1), y: -(half - 1)), KGPoint(x: +half, y: -(half - 1)),
            KGPoint(x: -half, y: -(half - 1))
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
