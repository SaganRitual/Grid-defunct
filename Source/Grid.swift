import Foundation

/// Defines a grid of cells and functions for navigating it
public struct Grid {
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
    public init(_ gridDimensionsCells: KGSize, cMaxSenseRings: Int = 1) {
        self.locator = .init(
            gridDimensionsCells: gridDimensionsCells
        )

        self.indexer = .init(
            locator: self.locator, cMaxSenseRings: cMaxSenseRings
        )
    }

    /// Conveniences to make the client code easier to read
    public var area: Int { locator.gridDimensionsCells.area() }
    public var height: Int { locator.gridDimensionsCells.height }
    public var size: KGSize { KGSize(width: width, height: height) }
    public var width: Int { locator.gridDimensionsCells.width }

    /// Indicates whether the specified position is on the grid
    ///
    /// - Parameter position: The position to check
    ///
    /// - Returns: A Bool indicating whether the point is on the grid
    public func isOnGrid(_ position: KGPoint) -> Bool { locator.isOnGrid(position) }

    /// For iterating over all the cells in the grid
    /// - Warning: Although the index is an Int, don't try to use it
    /// for calculating offsets or positions of cells. Instead, if you need
    /// to know the position of a cell, grab the cell using the iterator then
    /// get cell.properties.gridPosition
    public func makeIterator() -> IndexingIterator<[GridCell]> {
        locator.theCells.makeIterator()
    }
}

extension Grid {
    /// Gets the cell at the indicated coordinates on the grid
    ///
    /// - Parameter position: The cell's position on the grid. The point (0, 0)
    ///     is in the center of the grid, with y increasing upward and x increasing
    ///     to the right
    ///
    /// - Returns: The indicated cell
    public func cellAt(_ position: KGPoint) -> GridCell { locator.cellAt(position) }

    /// Gets the cell at the "ring index" relative to the indicated cell
    ///
    /// - Parameters:
    ///   - localIx: The index to offset from the center
    ///   - center: The cell to use as the center; a typical use for this
    ///     function is to enable your game gremlin to read information ("sensory"
    ///     input) in the surrounding cells, out to any arbitrary distance
    ///
    /// - Returns: The indicated cell
    public func cellAt(_ localIx: Int, from center: GridCell) -> Grid.AsteroidPoint {
        indexer.localIndexToRealGrid(localIx, from: center)
    }
}

extension Grid {
    /// For use with sensory functions, ie, functions that read cell contents
    /// via an index relative to a center
    ///
    /// - Parameters:
    ///   - realCell: the cell at the real grid location corresponding to the
    ///     center+localIx. This is where you will want to place your gremlin
    ///     to make it wrap to the other edge of the grid
    ///   - relativeVirtualPosition: a position (not a cell) that's not on
    ///     the grid, where the gremlin would go if the grid were actually to
    ///     extend far enough
    public struct AsteroidPoint {
        let realCell: GridCell
        let relativeVirtualPosition: KGPoint
    }

    /// Find the first cell from among the cells surrounding the center that
    /// results in `predicate(_: AsteroidPoint)` returning `true`
    ///
    /// - Parameters:
    ///   - centerCell: The cell from which to offset
    ///   - cMaxCells: The maximum number of cells to read for the search
    ///   - predicate: Your function for testing the characteristics of
    ///   candidate cells.
    ///
    /// - Returns: The first qualifying cell, or `nil` if no qualifying cell is found
    public func first(
        fromCenterAt centerCell: GridCell, cMaxCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            from: centerCell, cMaxCells: cMaxCells, where: predicate
        )
    }
}
