import Foundation

/// Defines a grid of cells and functions for navigating it
public struct Grid {
    private let indexer: GridIndexer
    private let navigator: GridNavigator

    /// Instantiate a 2-dimensional grid of cells with the origin (0, 0) in
    /// the center
    ///
    /// - Parameters:
    ///   - size: the desired size of the grid.
    ///   - cellFactory: makes cells that adhere to GridCellProtocol
    ///
    /// Note that the dimensions of the grid must be odd, to ensure that (0, 0)
    /// is the center cell, with the same number of cells above as below, and
    /// on the right as on the left.
    public init(
        size: GridSize,
        cellFactory: GridCellFactoryProtocol
    ) {
        precondition(
            size.width % 2 == 1 && size.height % 2 == 1,
            "Width and height of the grid must both be odd"
        )

        self.navigator = .init(size: size, cellFactory: cellFactory)
        self.indexer = .init(size: size, locator: self.navigator)
    }

    /// Conveniences to make the client code easier to read
    public var area: Int { navigator.size.area() }
    public var height: Int { navigator.size.height }
    public var size: GridSize { GridSize(width: width, height: height) }
    public var width: Int { navigator.size.width }

    /// Indicates whether the specified position is on the grid
    ///
    /// - Parameter position: The position to check
    ///
    /// - Returns: A Bool indicating whether the point is on the grid
    public func isOnGrid(_ position: GridPoint) -> Bool { locator.isOnGrid(position) }

    /// For iterating over all the cells in the grid
    /// - Warning: Although the index is an Int, don't try to use it
    /// for calculating offsets or positions of cells. Instead, if you need
    /// to know the position of a cell, grab the cell using the iterator then
    /// get cell.properties.gridPosition
    public func makeIterator() -> IndexingIterator<[GridCellProtocol]> {
        navigator.theCells.makeIterator()
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
    public func cellAt(_ position: GridPoint) -> GridCellProtocol { locator.cellAt(position) }

    /// Gets the cell at the "ring index" relative to the indicated cell
    ///
    /// - Parameters:
    ///   - localIx: The index to offset from the center
    ///   - center: The position of cell to use as the center; a typical use for this
    ///     function is to enable your game gremlin to read information ("sensory"
    ///     input) in the surrounding cells, out to any arbitrary distance
    ///
    /// - Returns: If there is such a cell, the cell is returned; if the computed
    ///             position is off the grid, returns nil
    public func cellAt(_ localIx: Int, from centerPoint: GridPoint) -> GridCellProtocol? {
        cellAt(localIx, from: cellAt(centerPoint))
    }

    /// Gets the cell at the "ring index" relative to the indicated cell
    ///
    /// - Parameters:
    ///   - localIx: The index to offset from the center
    ///   - center: The position of cell to use as the center; a typical use for this
    ///     function is to enable your game gremlin to read information ("sensory"
    ///     input) in the surrounding cells, out to any arbitrary distance
    ///
    /// - Returns: If there is such a cell, the cell is returned; if the computed
    ///             position is off the grid, returns nil
    public func cellAt(_ localIx: Int, from centerCell: GridCellProtocol) -> GridCellProtocol? {
        let p = indexer.localIndexToRealGrid(localIx, from: centerCell)
        return isOnGrid(p) ? cellAt(p) : nil
    }

    /// Gets the cell at the "ring index" relative to the indicated cell
    ///
    /// - Parameters:
    ///   - localIx: The index to offset from the center
    ///   - center: The position of cell to use as the center; a typical use for this
    ///     function is to enable your game gremlin to read information ("sensory"
    ///     input) in the surrounding cells, out to any arbitrary distance
    ///
    /// - Returns: An AsteroidPoint with real cell and virtual grid position
    public func asteroidPoint(_ localIx: Int, from centerPoint: GridPoint) -> Grid.AsteroidPoint {
        asteroidPoint(localIx, from: cellAt(centerPoint))
    }

    /// Gets the cell at the "ring index" relative to the indicated cell
    ///
    /// - Parameters:
    ///   - localIx: The index to offset from the center
    ///   - center: The cell to use as the center; a typical use for this
    ///     function is to enable your game gremlin to read information ("sensory"
    ///     input) in the surrounding cells, out to any arbitrary distance
    ///
    /// - Returns: An AsteroidPoint with real cell and virtual grid position
    public func asteroidPoint(_ localIx: Int, from centerCell: GridCellProtocol) -> Grid.AsteroidPoint {
        return indexer.localIndexToAsteroidGrid(localIx, from: centerCell)
    }

    /// Get a random cell from the grid
    /// - Returns: A random cell
    public func randomCell() -> GridCellProtocol {
        let w2 = width / 2, h2 = height / 2
        let p = GridPoint(x: Int.random(in: -w2...w2), y: Int.random(in: -h2...h2))
        return cellAt(p)
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
        let realCell: GridCellProtocol
        let relativeVirtualPosition: GridPoint

        var isOnGrid: Bool { realCell.gridPosition == relativeVirtualPosition }
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
        fromCenterAt centerCell: GridCellProtocol, cMaxCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            from: centerCell, cMaxCells: cMaxCells, where: predicate
        )
    }
}
