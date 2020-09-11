import Foundation

struct Grid {
    static private(set) var theGrid: Grid!
    static private(set) var gridDimensionsCells: KGSize!

    let theCells: [GridCell]
    let indexer: GridIndexer

    static func makeGrid(_ gridDimensionsCells: KGSize, cMaxSenseRings: Int = 1) {
        let wc_ = gridDimensionsCells.width
        let hc_ = gridDimensionsCells.height

        // Ensure odd width and height, such that (0, 0) is a cell at the
        // center of the grid, and such that there are the same number of cells
        // above (0, 0) as below, and the same number of cells to the right as
        // to the left.
        let wc = wc_ - ((wc_ % 2) == 0 ? 1 : 0)
        let hc = hc_ - ((hc_ % 2) == 0 ? 1 : 0)

        Grid.gridDimensionsCells = KGSize(width: wc, height: hc)

        theGrid = .init(cMaxSenseRings)
    }

    private init(_ cMaxSenseRings: Int) {
        self.indexer = .init(cMaxSenseRings: cMaxSenseRings)

        let cCells = Grid.gridDimensionsCells.area()
        self.theCells = Grid.setupCells(cCells)
    }

    static private func setupCells(_ cCells: Int) -> [GridCell] {
        var theCells = [GridCell]()
        theCells.reserveCapacity(cCells)

        for cellAbsoluteIndex in 0..<cCells {
            theCells.append(GridCell(cellAbsoluteIndex))
        }

        return theCells
    }
}

extension Grid {
    static func cellAt(_ absoluteIndex: Int) -> GridCell {
        theGrid.theCells[absoluteIndex]
    }

    static func cellAt(_ position: KGPoint) -> GridCell {
        cellAt(absoluteIndex(of: position))
    }

    static func cellAt(
        _ localIx: Int, from center: GridCell
    ) -> (GridCell, KGPoint) {
        theGrid.indexer.localIndexToRealGrid(localIx, from: center)
    }
}

extension Grid {
    static func first(
        fromCenterAt absoluteGridIndex: Int, cCells: Int,
        where predicate: @escaping (GridCell, KGPoint) -> Bool
    ) -> (GridCell, KGPoint)? {
        theGrid.indexer.first(
            fromCenterAt: absoluteGridIndex, cCells: cCells, where: predicate
        )
    }

    static func first(
        fromCenterAt centerCell: GridCell, cCells: Int,
        where predicate: @escaping (GridCell, KGPoint) -> Bool
    ) -> (GridCell, KGPoint)? {
        theGrid.indexer.first(
            fromCenterAt: centerCell, cCells: cCells, where: predicate
        )
    }
}

extension Grid {
    static func absoluteIndex(of position: KGPoint) -> Int {
        let halfHeight = Grid.gridDimensionsCells.height / 2
        let yy = halfHeight - position.y

        let halfWidth = Grid.gridDimensionsCells.width / 2
        return (yy * Grid.gridDimensionsCells.width) + (halfWidth + position.x)
    }

    static func gridPosition(of index: Int) -> KGPoint {
        let halfWidth = gridDimensionsCells.width / 2
        let halfHeight = gridDimensionsCells.height / 2

        let y = halfHeight - (index / gridDimensionsCells.width)
        let x = (index % gridDimensionsCells.width) - halfWidth

        return KGPoint(x: x, y: y)
    }

    static func randomCellIndex() -> Int {
        let cCellsInGrid = gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }

    static func randomCell() -> GridCell { cellAt(randomCellIndex()) }
}
