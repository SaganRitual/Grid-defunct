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
    enum LayoutType { case fullGrid, q1YDown, q1YUp }

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
        case .q1YDown:  layoutFactory = GridCellLayoutFactoryQ1YDown()
        case .q1YUp:    layoutFactory = GridCellLayoutFactoryQ1YUp()
        }

        self.layout = layoutFactory.makeLayout(size: size)
        self.theCells = self.layout.setupCells(cellFactory: cellFactory)
    }

    func cell(at position: GridPoint) -> GridCellProtocol {
         theCells[layout.cellIndex(at: position)]
    }

    func cellIndex(at position: GridPoint) -> Int {
        layout.cellIndex(at: position)
    }

    func randomCell() -> GridCellProtocol { theCells.randomElement()! }

    static func cRingsToCells(cRings: Int) -> Int {
        let cellsPerSide = cRingsToSide(cRings: cRings)
        return cellsPerSide * cellsPerSide
    }

    static func cRingsToSide(cRings: Int) -> Int { 2 * cRings + 1 }
}

extension GridNavigator {
    func isOnGrid(_ position: GridPoint) -> Bool {
        let hw = size.width / 2, hh = size.height / 2
        return (-hw...hw).contains(position.x) && (-hh...hh).contains(position.y)
    }
}
