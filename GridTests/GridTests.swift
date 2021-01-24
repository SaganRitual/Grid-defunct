// We are a way for the cosmos to know itself. -- C. Sagan
// swiftlint:disable function_body_length
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

class TestGridSyncCell: GridSyncCellProtocol {
    let gridPosition: GridPoint
    var isLocked: Bool = false

    init(gridPosition: GridPoint) { self.gridPosition = gridPosition }
}

struct TestGridSyncCellFactory: GridCellFactoryProtocol {
    func makeCell(gridPosition: GridPoint) -> GridCellProtocol {
        TestGridSyncCell(gridPosition: gridPosition)
    }
}

class GridTests: XCTestCase {
    let side: Int = 99
    var grid: Grid!
    var half: Int { side / 2 }

    let callbackQueue = DispatchQueue(
        label: "test.callback",
        attributes: .concurrent,
        target: DispatchQueue.global()
    )

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
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridCellFactory())

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
        self.grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridCellFactory())

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
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridCellFactory())

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
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridCellFactory())

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

    func testGridSyncLock() throws {

        let concurrentQueue = DispatchQueue(
            label: "test.dq",
            attributes: .concurrent,
            target: DispatchQueue.global()
        )

        let dimensions = GridSize(width: 13, height: 13)
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridSyncCellFactory())
        let sync = GridSync(grid)

        let pointsToLock: [GridPoint] = [
            GridPoint(x:  1, y:  0), GridPoint(x: -1, y: -1), GridPoint(x:  2, y: -1),
            GridPoint(x:  0, y: -2), GridPoint(x: -2, y:  0), GridPoint(x: -2, y:  1),
            GridPoint(x: -2, y:  2), GridPoint(x:  0, y:  2), GridPoint(x:  2, y:  2),
            GridPoint(x:  2, y:  1)
        ]

        let firstLockupCompletion = XCTestExpectation()
        firstLockupCompletion.expectedFulfillmentCount = pointsToLock.count + 1

        let expectedLockmap = [
            false, true, true, false, true, true, true, true,
            true, false, true, true, false, true, true, true,
            false, false, false, true, false, true, false, false
        ]

        pointsToLock.forEach {
            let cell = sync.cellAt($0)
            let delay = Double.random(in: 0..<0.01)

            sync.lockCell(cell: cell) {
                concurrentQueue.asyncAfter(deadline: .now() + delay) {
                    sync.releaseLock(cell: cell)
                    firstLockupCompletion.fulfill()
                }
            }
        }

        var lockmap = [Bool]()

        sync.lockArea(center: sync.cellAt(.zero), cRings: 2) {
            lockmap = $0
            XCTAssert(lockmap == expectedLockmap, "actual lockmap \(lockmap)")
            firstLockupCompletion.fulfill()
        }

        wait(for: [firstLockupCompletion], timeout: 2)

        let secondLockupCompletion = XCTestExpectation()

        sync.releaseLocks(from: sync.cellAt(.zero), lockmap: lockmap)

        sync.lockArea(center: sync.cellAt(.zero), cRings: 2) { lockmap in
            XCTAssert(lockmap.allSatisfy { $0 == true }, "lockmap should be all true: \(lockmap)")
            secondLockupCompletion.fulfill()
        }

        wait(for: [secondLockupCompletion], timeout: 1)
    }

    func testGridSyncDeferral() throws {
        let dimensions = GridSize(width: 13, height: 13)
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridSyncCellFactory())
        let sync = GridSync(grid)

        let p0 = sync.cellAt(GridPoint(x: -1, y: +1))

        let exp1 = XCTestExpectation(description: "#1 gets deferred; runs again when first lock is released")
        let exp2 = XCTestExpectation(description: "#2 gets deferred; runs again when #1 lock is released")

        sync.lockCell(cell: p0) {
            sync.lockCell(cell: p0) { exp1.fulfill(); sync.releaseLock(cell: p0) }
            sync.lockCell(cell: p0) { exp2.fulfill(); sync.releaseLock(cell: p0) }

            sync.releaseLock(cell: p0)
        }

        wait(for: [exp1, exp2], timeout: 1)
    }

    func testGridSyncLoad() throws {
        let dimensions = GridSize(width: 49, height: 49)
        let grid = Grid(size: dimensions, cellLayoutType: .fullGrid, cellFactory: TestGridSyncCellFactory())

        let concurrentQueue = DispatchQueue(
            label: "test.dq",
            attributes: .concurrent,
            target: DispatchQueue.global()
        )

        let sync = GridSync(
            grid, callbackQueue: concurrentQueue, maxDeferralDepth: 75
        )

        let cLoops = 100_000

        let expectation = XCTestExpectation(description: "Await completion")
        expectation.expectedFulfillmentCount = cLoops

        func lockCell(cell toLock: GridSyncCellProtocol) {
            let delay = Double.random(in: 0..<0.01)

            sync.lockCell(cell: toLock) {
                concurrentQueue.asyncAfter(deadline: .now() + delay) {
                    sync.releaseLock(cell: toLock)
                    expectation.fulfill()
                }
            }
        }

        let forcedDeferrals = XCTestExpectation(description: "Forced deferrals")
        var iCallBullshit = 0

        func lockArea(center: GridSyncCellProtocol) {
            let delay = Double.random(in: 0..<0.01)

            sync.lockArea(center: center, cRings: 3) { lockmap in
                if let checkDeferIx = lockmap.indices.filter({ lockmap[$0] == false }).randomElement() {
                    iCallBullshit += 1

                    let checkDefer = sync.cellAt(checkDeferIx + 1, from: center)
                    sync.lockCell(cell: checkDefer) {
                        concurrentQueue.asyncAfter(deadline: .now() + delay) {
                            sync.releaseLock(cell: checkDefer)
                            forcedDeferrals.fulfill()
                        }
                    }
                }

                concurrentQueue.asyncAfter(deadline: .now() + delay) {
                    sync.releaseLocks(from: center, lockmap: lockmap)
                    expectation.fulfill()
                }
            }
        }

        for _ in 0..<cLoops {
            let randomCell = (grid.randomCell() as? GridSyncCellProtocol)!

            if Bool.random() { lockCell(cell: randomCell) }
            else             { lockArea(center: randomCell) }
        }

        wait(for: [expectation], timeout: 10)

        // Because the api won't let me start at zero
        forcedDeferrals.expectedFulfillmentCount = iCallBullshit

        if forcedDeferrals.expectedFulfillmentCount > 1 {
            forcedDeferrals.expectedFulfillmentCount -= 1
        }

        print("forced \(forcedDeferrals.expectedFulfillmentCount), bullshit \(iCallBullshit)")

        wait(for: [forcedDeferrals], timeout: 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
