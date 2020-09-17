import Foundation

protocol GridCellContents: class, CustomDebugStringConvertible {

}

open class GridCell: CustomDebugStringConvertible {
    weak var contents: GridCellContents?
    let properties: GridCellProperties

    public var debugDescription: String { "Cell at \(properties.gridPosition)" }

    init(gridPosition: KGPoint) {
        self.properties = GridCellProperties(gridPosition: gridPosition)
    }

    static func == (lhs: GridCell, rhs: GridCell) -> Bool {
        lhs.properties.gridPosition == rhs.properties.gridPosition
    }
}

struct GridCellProperties: CustomDebugStringConvertible {
    let debugDescription: String
    let gridPosition: KGPoint

    init(gridPosition: KGPoint) {
        self.gridPosition = gridPosition
        self.debugDescription = "\(gridPosition)"
    }
}
