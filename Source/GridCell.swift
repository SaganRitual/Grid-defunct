import Foundation

class GridCell: CustomDebugStringConvertible {
    let properties: GridCellProperties

    var debugDescription: String { "Cell at \(properties.gridPosition)" }

    init(_ absoluteIndex: Int) { properties = .init(absoluteIndex) }
}

struct GridCellProperties: CustomDebugStringConvertible {
    let gridAbsoluteIndex: Int
    let gridPosition: KGPoint

    static let zero = GridCellProperties(0)

    let debugDescription: String

    init(_ absoluteIndex: Int) {
        self.gridAbsoluteIndex = absoluteIndex
        self.gridPosition = Grid.gridPosition(of: absoluteIndex)

        debugDescription =
            String(format: "%04d:", gridAbsoluteIndex) + "\(gridPosition)"
    }
}
