import Foundation

protocol GridCellContents: class {

}

class GridCell: CustomDebugStringConvertible {
    weak var contents: GridCellContents?
    let properties: GridCellProperties

    var debugDescription: String { "Cell at \(properties.gridPosition)" }

    init(_ absoluteIndex: Int, _ gridDimensionsCells: KGSize) {
        let position = GridCellLocator.gridPosition(
            of: absoluteIndex, gridDimensionsCells: gridDimensionsCells
        )

        self.properties = GridCellProperties(absoluteIndex, gridPosition: position)
    }

    static func == (lhs: GridCell, rhs: GridCell) -> Bool {
        lhs.properties.gridPosition == rhs.properties.gridPosition
    }
}

struct GridCellProperties: CustomDebugStringConvertible {
    let debugDescription: String
    let gridAbsoluteIndex: Int
    let gridPosition: KGPoint

    init(_ absoluteIndex: Int, gridPosition: KGPoint) {
        self.gridAbsoluteIndex = absoluteIndex
        self.gridPosition = gridPosition

        self.debugDescription =
            String(format: "%04d:", gridAbsoluteIndex) + "\(gridPosition)"
    }
}
