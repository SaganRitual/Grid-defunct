// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

public protocol GridCellProtocol: class {
    var gridPosition: GridPoint { get }
}

public extension GridCellProtocol {
    static func == (lhs: GridCellProtocol, rhs: GridCellProtocol) -> Bool {
        lhs.gridPosition == rhs.gridPosition
    }
}

public protocol GridCellFactoryProtocol {
    func makeCell(gridPosition: GridPoint) -> GridCellProtocol
}

struct GridNavigator {
    let size: GridSize
    let theCells: [GridCellProtocol]

    init(size: GridSize, cellFactory: GridCellFactoryProtocol) {
        self.size = size

        self.theCells = GridNavigator.setupCells(
            size: size,
            cellFactory: cellFactory
        )
    }

    func cellAt(_ position: GridPoint) -> GridCellProtocol {
        cellAt(absoluteIndex(of: position))
    }
}

extension GridNavigator {
    func isOnGrid(_ position: GridPoint) -> Bool {
        let hw = size.width / 2, hh = size.height / 2
        return (-hw...hw).contains(position.x) && (-hh...hh).contains(position.y)
    }
}

private extension GridNavigator {
    func absoluteIndex(of position: GridPoint) -> Int {
        let halfHeight = size.height / 2
        let yy = halfHeight - position.y

        let halfWidth = size.width / 2
        let ix = (yy * size.width) + (halfWidth + position.x)

        return ix
    }

    func cellAt(_ absoluteIndex: Int) -> GridCellProtocol { theCells[absoluteIndex] }

    static func setupCells(
        size: GridSize,
        cellFactory: GridCellFactoryProtocol
    ) -> [GridCellProtocol] {
        let cCells = size.area()

        var theCells = [GridCellProtocol]()
        theCells.reserveCapacity(cCells)

        for ix in 0..<cCells {
            let p = gridPosition(of: ix, size: size)
            let cell = cellFactory.makeCell(gridPosition: p)
            theCells.append(cell)
        }

        return theCells
    }

    static func gridPosition(of index: Int, size: GridSize) -> GridPoint {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        let y = halfHeight - (index / size.width)
        let x = (index % size.width) - halfWidth

        return GridPoint(x: x, y: y)
    }
}
