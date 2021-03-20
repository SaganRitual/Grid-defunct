import Foundation

/// Defines a grid of cells and functions for navigating it
struct Grid {
    private let indexer: GridIndexer
    private let navigator: GridNavigator

    /// Two-dimensional grid of cells
    ///
    /// - Parameters:
    ///   - size: the desired size of the grid
    ///   - cellLayoutType: full grid layout with (0, 0) at the center,
    ///                     or quadrant I grid with (0, 0) at the lower left
    ///   - cellFactory: makes cells that adhere to GridCellProtocol
    ///
    /// Note that for the full grid, the dimensions of the grid must be odd,
    /// to ensure that (0, 0) is the center cell, with the same number of cells
    /// above as below, and on the right as on the left.
    init(
        size: GridSize,
        cellLayoutType: GridNavigator.LayoutType,
        cellFactory: GridCellFactoryProtocol?
    ) {
//        if cellLayoutType == .fullGrid {
//            precondition(
//                size.width % 2 == 1 && size.height % 2 == 1,
//                "Width and height of the grid must both be odd"
//            )
//        }

        self.navigator = .init(
            size: size, layoutType: cellLayoutType,
            cellFactory: cellFactory ?? DefaultGridCellFactory()
        )

        self.indexer = .init(size: size, locator: self.navigator)
    }

    /// Conveniences to make the client code easier to read
    var area: Int { navigator.size.area() }
    var height: Int { navigator.size.height }
    var size: GridSize { GridSize(width: width, height: height) }
    var width: Int { navigator.size.width }

    /// Get the number of cells that would be covered by the indicated
    /// number of rings
    ///
    /// - Parameter cRings: The number of rings to calculate
    ///
    /// - Returns: The number of cells in that many rings
    static func cRingsToCells(cRings: Int) -> Int {
        GridNavigator.cRingsToCells(cRings: cRings)
    }

    /// Get the number of cells per side of the square for the rings
    ///
    /// - Parameter cRings: The number of rings to calculate
    ///
    /// - Returns: The number of cells per side for that many rings
    static func cRingsToSide(cRings: Int) -> Int {
        GridNavigator.cRingsToSide(cRings: cRings)
    }

    /// Indicates whether the specified position is on the grid
    ///
    /// - Parameter position: The position to check
    ///
    /// - Returns: A Bool indicating whether the point is on the grid
    func isOnGrid(_ position: GridPoint) -> Bool { navigator.isOnGrid(position) }

    /// For iterating over all the cells in the grid
    /// - Warning: Although the index is an Int, don't try to use it
    /// for calculating offsets or positions of cells. Instead, if you need
    /// to know the position of a cell, grab the cell using the iterator then
    /// get cell.properties.gridPosition
    func makeIterator() -> IndexingIterator<[GridCellProtocol]> {
        navigator.theCells.makeIterator()
    }
}

extension Grid {
    /// Gets the cell at an absolute index within the grid cell array.
    /// This is for easy iteration over all the cells in the grid as a
    /// 1D vector
    ///
    /// - Parameter absoluteIndex: a subscript into the array of cells
    /// in the grid
    ///
    /// - Returns: The (x, y) coordinates of the cell in its place
    /// on the grid plane
    func gridPosition(of absoluteIndex: Int) -> GridPoint {
        navigator.layout.gridPosition(of: absoluteIndex)
    }

    /// Gets the cell at the indicated coordinates on the grid
    ///
    /// - Parameter position: The cell's position on the grid. The point (0, 0)
    ///     is in the center of the grid, with y increasing upward and x increasing
    ///     to the right
    ///
    /// - Returns: The indicated cell
    func cellAt(_ position: GridPoint) -> GridCellProtocol { navigator.cell(at: position) }

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
    func cellAt(_ localIx: Int, from centerPoint: GridPoint) -> GridCellProtocol? {
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
    func cellAt(_ localIx: Int, from centerCell: GridCellProtocol) -> GridCellProtocol? {
        let p = indexer.localIndexToRealGrid(localIx, from: centerCell)
        return isOnGrid(p) ? cellAt(p) : nil
    }

    /// Gets the index of the cell at the indicated coordinates on the grid
    ///
    /// - Parameter position: The cell's position on the grid. The point (0, 0)
    ///     is in the center of the grid, with y increasing upward and x increasing
    ///     to the right
    ///
    /// - Returns: The index of the indicated cell
    func cellIndex(at gridPosition: GridPoint) -> Int {
        navigator.cellIndex(at: gridPosition)
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
    func asteroidPoint(_ localIx: Int, from centerPoint: GridPoint) -> Grid.AsteroidPoint {
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
    func asteroidPoint(_ localIx: Int, from centerCell: GridCellProtocol) -> Grid.AsteroidPoint {
        return indexer.localIndexToAsteroidGrid(localIx, from: centerCell)
    }

    /// Gets the ring index corresponding to the offset
    ///
    /// - Parameters:
    ///   - offset: The offset from the center, ie, GridPoint(x: 0, y 0)
    static func offsetToLocalIndex(_ offset: GridPoint) -> Int {
        GridIndexer.offsetToLocalIndex(offset)
    }

    /// Get a random cell from the grid
    /// - Returns: A random cell
    func randomCell() -> GridCellProtocol { navigator.randomCell() }
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
    struct AsteroidPoint {
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
    func first(
        fromCenterAt centerCell: GridCellProtocol, cMaxCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            from: centerCell, cMaxCells: cMaxCells, where: predicate
        )
    }

    /// Find the first cell from among the cells surrounding the center that
    /// results in `predicate(_: AsteroidPoint)` returning `true`
    ///
    /// - Parameters:
    ///   - centerPosition: The GridPoint from which to offset
    ///   - cMaxCells: The maximum number of cells to read for the search
    ///   - predicate: Your function for testing the characteristics of
    ///   candidate cells.
    ///
    /// - Returns: The first qualifying cell, or `nil` if no qualifying cell is found
    func first(
        fromCenterAt centerPosition: GridPoint, cMaxCells: Int,
        where predicate: @escaping (AsteroidPoint) -> Bool
    ) -> AsteroidPoint? {
        indexer.first(
            from: cellAt(centerPosition), cMaxCells: cMaxCells, where: predicate
        )
    }
}
