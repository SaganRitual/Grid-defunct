// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

protocol GridCellLayoutProtocol {
    var size: GridSize { get }

    func cellIndex(at position: GridPoint) -> Int
    func gridPosition(of index: Int) -> GridPoint
}

extension GridCellLayoutProtocol {

    func setupCells(
        cellFactory: GridCellFactoryProtocol
    ) -> [GridCellProtocol] {
        let cCells = size.area()

        var theCells = [GridCellProtocol]()
        theCells.reserveCapacity(cCells)

        for ix in 0..<cCells {
            let p = self.gridPosition(of: ix)
            let cell = cellFactory.makeCell(gridPosition: p)
            theCells.append(cell)
        }

        return theCells
    }
}

protocol GridCellLayoutFactoryProtocol {
    func makeLayout(size: GridSize) -> GridCellLayoutProtocol
}

struct GridCellLayoutFactoryFull: GridCellLayoutFactoryProtocol {
    func makeLayout(size: GridSize) -> GridCellLayoutProtocol {
        GridCellLayoutFull(size: size)
    }
}

struct GridCellLayoutFull: GridCellLayoutProtocol {
    let size: GridSize

    func cellIndex(at position: GridPoint) -> Int {
        let halfHeight = size.height / 2
        let yy = halfHeight - position.y

        let halfWidth = size.width / 2
        let ix = (yy * size.width) + (halfWidth + position.x)

        return ix
    }

    func gridPosition(of index: Int) -> GridPoint {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2

        let y = halfHeight - (index / size.width)
        let x = (index % size.width) - halfWidth

        return GridPoint(x: x, y: y)
    }
}

struct GridCellLayoutFactoryQ1: GridCellLayoutFactoryProtocol {
    func makeLayout(size: GridSize) -> GridCellLayoutProtocol {
        GridCellLayoutQ1(size: size)
    }
}

struct GridCellLayoutQ1: GridCellLayoutProtocol {
    let size: GridSize

    func cellIndex(at position: GridPoint) -> Int {
        position.y * size.width + position.x
    }

    func gridPosition(of index: Int) -> GridPoint {
        GridPoint(x: index % size.width, y: index / size.width)
    }
}