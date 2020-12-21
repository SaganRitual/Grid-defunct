// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

protocol GridCellProtocol: class {
    var gridPosition: GridPoint { get }
}

extension GridCellProtocol {
    static func == (lhs: GridCellProtocol, rhs: GridCellProtocol) -> Bool {
        lhs.gridPosition == rhs.gridPosition
    }
}

protocol GridCellFactoryProtocol {
    func makeCell(gridPosition: GridPoint) -> GridCellProtocol
}

struct GridNavigator {
    enum LayoutType { case fullGrid, q1Only }

    let layout: GridCellLayoutProtocol
    let size: GridSize
    let theCells: [GridCellProtocol]

    init(
        size: GridSize,
        layoutType: LayoutType,
        cellFactory: GridCellFactoryProtocol
    ) {
        self.size = size

        let layoutFactory: GridCellLayoutFactoryProtocol

        switch layoutType {
        case .fullGrid: layoutFactory = GridCellLayoutFactoryFull()
        case .q1Only:   layoutFactory = GridCellLayoutFactoryQ1()
        }

        self.layout = layoutFactory.makeLayout(size: size)
        self.theCells = self.layout.setupCells(cellFactory: cellFactory)
    }

    func cell(at position: GridPoint) -> GridCellProtocol {
        theCells[layout.cellIndex(at: position)]
    }

    func randomCell() -> GridCellProtocol { theCells.randomElement()! }

    static func cRingsToCells(cRings: Int) -> Int {
        let cellsPerSide = (2 * cRings) + 1
        return cellsPerSide * cellsPerSide
    }
}

extension GridNavigator {
    func isOnGrid(_ position: GridPoint) -> Bool {
        let hw = size.width / 2, hh = size.height / 2
        return (-hw...hw).contains(position.x) && (-hh...hh).contains(position.y)
    }
}
