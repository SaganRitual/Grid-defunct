// We are a way for the cosmos to know itself. -- C. Sagan

import XCTest
@testable import Grid

class TestFood {
    var debugDescription: String { "So long, and thanks..." }
    let foodValue = 42
}

class TestGridCell: GridCellProtocol {
    let gridPosition: GridPoint
    var food: TestFood!

    init(gridPosition: GridPoint) { self.gridPosition = gridPosition }
}

struct TestGridCellFactory: GridCellFactoryProtocol {
    func makeCell(gridPosition: GridPoint) -> GridCellProtocol {
        TestGridCell(gridPosition: gridPosition)
    }
}

class GridTests: XCTestCase {
    let side: Int = 99
    var grid: Grid!
    var half: Int { side / 2 }

    func cell(_ gridCell: GridCellProtocol) -> TestGridCell {
        (gridCell as? TestGridCell)!
    }

    func cell(at position: GridPoint) -> TestGridCell {
        return cell(grid.cellAt(position))
    }

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testForSmoke() throws {
        let dimensions = GridSize(width: side, height: side)
        let grid = Grid(size: dimensions, cellFactory: TestGridCellFactory())

        // Because grid likes odd
        let side = (self.side % 2 == 1) ? self.side : self.side - 1
        let expectedArea = side * side
        XCTAssert(
            grid.area == expectedArea,
            "\(side) x \(side) grid should contain \(expectedArea) cells, got \(grid.area)"
        )
    }

    func testIndexer() throws {
        let dimensions = GridSize(width: side, height: side)
        self.grid = Grid(size: dimensions, cellFactory: TestGridCellFactory())

        let f1Position = GridPoint(x: Int.random(in: -half...half), y: Int.random(in: -half...half))

        let f1 = cell(at: f1Position)
        let f2 = cell(at: f1Position + GridPoint(x: 1, y: 1))

        f2.food = TestFood()

        let f3 = grid.first(fromCenterAt: f1, cMaxCells: 9) { asteroid in
            self.cell(asteroid.realCell).food != nil
        }

        guard let check = f3, check.realCell === f2 else {
            XCTAssert(false, "Food not found where expected")
            return
        }

        f2.food = nil

        let f4 = grid.first(fromCenterAt: f1, cMaxCells: 9) { asteroid in
            self.cell(asteroid.realCell).food != nil
        }

        XCTAssert(f4 == nil, "Found food that isn't really there")
    }

    func testAsteroidsUpperLeft() throws {
        let dimensions = GridSize(width: side, height: side)
        let grid = Grid(size: dimensions, cellFactory: TestGridCellFactory())

        let c1 = grid.cellAt(GridPoint(x: -half, y: half))

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            grid.asteroidPoint($0, from: c1)
        }

        // Check virtual positions
        let virtualPositionsOk = [
            GridPoint(x: +0, y: +0), GridPoint(x: +1, y: +0), GridPoint(x: +1, y: -1),
            GridPoint(x: +0, y: -1), GridPoint(x: -1, y: -1), GridPoint(x: -1, y: +0),
            GridPoint(x: -1, y: +1), GridPoint(x: +0, y: +1), GridPoint(x: +1, y: +1)
        ].enumerated().allSatisfy {
            adjacentCells[$0].relativeVirtualPosition == c1.gridPosition + $1
        }

        XCTAssert(
            virtualPositionsOk,
            "adjacentCells in ring around upper-left corner show incorrect virtual positions"
        )

        // Check real positions
        let realPositionsOk = [
            GridPoint(x: -half, y: +half), GridPoint(x: -(half - 1), y: +half),
            GridPoint(x: -(half - 1), y: +(half - 1)), GridPoint(x: -half, y: +(half - 1)), GridPoint(x: +half, y: +(half - 1)),
            GridPoint(x: +half, y: +half), GridPoint(x: +half, y: -half), GridPoint(x: -half, y: -half),
            GridPoint(x: -(half - 1), y: -half)
        ].enumerated().allSatisfy {
            adjacentCells[$0].realCell.gridPosition == $1
        }

        XCTAssert(
            realPositionsOk,
            "adjacentCells in ring around upper-left corner show incorrect real position"
        )
    }

    func testAsteroidsLowerRight() throws {
        let dimensions = GridSize(width: side, height: side)
        let grid = Grid(size: dimensions, cellFactory: TestGridCellFactory())

        let c1 = grid.cellAt(GridPoint(x: half, y: -half))

        // Use scalar index to grab the cells adjacent to c1
        let adjacentCells = (0..<9).map {
            grid.asteroidPoint($0, from: c1)
        }

        // Check virtual positions; simple offset from center
        let virtualPositionsOk = [
            GridPoint(x: +0, y: +0), GridPoint(x: +1, y: +0), GridPoint(x: +1, y: -1),
            GridPoint(x: +0, y: -1), GridPoint(x: -1, y: -1), GridPoint(x: -1, y: +0),
            GridPoint(x: -1, y: +1), GridPoint(x: +0, y: +1), GridPoint(x: +1, y: +1)
        ].enumerated().allSatisfy {
            adjacentCells[$0].relativeVirtualPosition == c1.gridPosition + $1
        }

        XCTAssert(
            virtualPositionsOk,
            "adjacentCells in ring around lower-right corner show incorrect virtual positions"
        )

        // Check real positions, wrapped to other side of grid as necessary
        let realPositionsOk = [
            GridPoint(x: +half, y: -half), GridPoint(x: -half, y: -half),
            GridPoint(x: -half, y: +half), GridPoint(x: +half, y: +half), GridPoint(x: +(half - 1), y: +half),
            GridPoint(x: +(half - 1), y: -half), GridPoint(x: +(half - 1), y: -(half - 1)), GridPoint(x: +half, y: -(half - 1)),
            GridPoint(x: -half, y: -(half - 1))
        ].enumerated().allSatisfy {
            adjacentCells[$0].realCell.gridPosition == $1
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
