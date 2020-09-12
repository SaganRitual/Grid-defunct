import Foundation

/// Defines a grid of cells and functions for working with it
struct Grid {
    private let indexer: GridIndexer
    private let locator: GridCellLocator

    /// Instantiate a 2-dimensional grid of cells with the origin (0, 0) in
    /// the center
    ///
    /// - Parameters:
    ///   - gridDimensionsCells: the desired size of the grid.
    ///   - cMaxSenseRings: the number of rings for the indexer to create. See
    ///   notes on the indexer for details.
    ///
    /// Note that the size of the grid will be adjusted downward as necessary
    /// to ensure that (0, 0) is the center cell, with the same number of cells
    /// above as below, and on the right as on the left.
    init(_ gridDimensionsCells: KGSize, cMaxSenseRings: Int = 1) {
        self.locator = .init(
            gridDimensionsCells: gridDimensionsCells
        )

        self.indexer = .init(
            locator: self.locator, cMaxSenseRings: cMaxSenseRings
        )
    }

    func area() -> Int { locator.gridDimensionsCells.area() }
}

extension Grid {
    func cellAt(_ absoluteIndex: Int) -> GridCell { locator.cellAt(absoluteIndex) }
    func cellAt(_ position: KGPoint) -> GridCell { locator.cellAt(position) }
    func cellAt(_ localIx: Int, from center: GridCell) -> Grid.AsteroidPoint {
        indexer.localIndexToRealGrid(localIx, from: center)
    }
}

extension Grid {
    func localIndexToRealGrid(
        _ localIx: Int, from center: GridCell
    ) -> Grid.AsteroidPoint {
        return indexer.localIndexToRealGrid(localIx, from: center)
    }

    func localIndexToVirtualGrid(
        _ localIx: Int, from center: GridCell
    ) -> KGPoint {
        return indexer.localIndexToVirtualGrid(localIx, from: center)
    }
}

extension Grid {
    func absoluteIndex(of position: KGPoint) -> Int { locator.absoluteIndex(of: position) }
    func gridPosition(of index: Int) -> KGPoint { locator.gridPosition(of: index) }

    func randomCellIndex() -> Int {
        let cCellsInGrid = locator.gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }

    func randomCell() -> GridCell { cellAt(randomCellIndex()) }
}

extension Grid {
    struct AsteroidPoint {
        let realCell: GridCell
        let relativeVirtualPosition: KGPoint
    }

    func first(
        fromCenterAt absoluteGridIndex: Int, cCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            fromCellAt: absoluteGridIndex, cCells: cCells, where: predicate
        )
    }

    func first(
        fromCenterAt centerCell: GridCell, cCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            from: centerCell, cCells: cCells, where: predicate
        )
    }
}
