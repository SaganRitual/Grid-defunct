// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

struct GridCellLocator {
    let gridDimensionsCells: KGSize
    let theCells: [GridCell]

    init(gridDimensionsCells: KGSize) {
        let wc_ = gridDimensionsCells.width
        let hc_ = gridDimensionsCells.height

        // Ensure odd width and height, such that (0, 0) is a cell at the
        // center of the grid, and such that there are the same number of cells
        // above (0, 0) as below, and the same number of cells to the right as
        // to the left.
        let wc = wc_ - ((wc_ % 2) == 0 ? 1 : 0)
        let hc = hc_ - ((hc_ % 2) == 0 ? 1 : 0)

        self.gridDimensionsCells = KGSize(width: wc, height: hc)

        self.theCells = GridCellLocator.setupCells(self.gridDimensionsCells)
    }

    static private func setupCells(_ gridDimensionsCells: KGSize) -> [GridCell] {
        let cCells = gridDimensionsCells.area()

        var theCells = [GridCell]()
        theCells.reserveCapacity(cCells)

        for cellAbsoluteIndex in 0..<cCells {
            let cell = GridCell(cellAbsoluteIndex, gridDimensionsCells)
            theCells.append(cell)
        }

        return theCells
    }
}

extension GridCellLocator {
    func cellAt(_ absoluteIndex: Int) -> GridCell { theCells[absoluteIndex] }

    func cellAt(_ position: KGPoint) -> GridCell {
        cellAt(
            GridCellLocator.absoluteIndex(
                of: position, gridDimensionsCells: gridDimensionsCells
            )
        )
    }
}

extension GridCellLocator {
    func absoluteIndex(of position: KGPoint) -> Int {
        GridCellLocator.absoluteIndex(
            of: position, gridDimensionsCells: self.gridDimensionsCells
        )
    }

    static func absoluteIndex(of position: KGPoint, gridDimensionsCells: KGSize) -> Int {
        let halfHeight = gridDimensionsCells.height / 2
        let yy = halfHeight - position.y

        let halfWidth = gridDimensionsCells.width / 2
        return (yy * gridDimensionsCells.width) + (halfWidth + position.x)
    }

    func gridPosition(of index: Int) -> KGPoint {
        GridCellLocator.gridPosition(
            of: index, gridDimensionsCells: self.gridDimensionsCells
        )
    }

    static func gridPosition(of index: Int, gridDimensionsCells: KGSize) -> KGPoint {
        let halfWidth = gridDimensionsCells.width / 2
        let halfHeight = gridDimensionsCells.height / 2

        let y = halfHeight - (index / gridDimensionsCells.width)
        let x = (index % gridDimensionsCells.width) - halfWidth

        return KGPoint(x: x, y: y)
    }

    func randomCellIndex() -> Int {
        let cCellsInGrid = gridDimensionsCells.area()
        return Int.random(in: 0..<cCellsInGrid)
    }

    func randomCell() -> GridCell { cellAt(randomCellIndex()) }
}
