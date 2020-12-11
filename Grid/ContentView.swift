// We are a way for the cosmos to know itself. -- C. Sagan

import SwiftUI

class Gremlin {
    var debugDescription: String { "Gremlin \(rectangle), \(color)" }
    let color: Color
    let rectangle: Rectangle

    init(_ color: Color = .blue) {
        self.color = color
        self.rectangle = Rectangle()
    }
}

class GremlinCell: GridCellProtocol {
    weak var gremlin: Gremlin?
    let gridPosition: GridPoint

    init(gridPosition: GridPoint) { self.gridPosition = gridPosition }
}

struct GremlinCellFactory: GridCellFactoryProtocol {
    func makeCell(gridPosition: GridPoint) -> GridCellProtocol {
        GremlinCell(gridPosition: gridPosition)
    }
}

struct ContentView: View {
    let gridDimensionsCells = GridSize(width: 15, height: 15)
    let gridDimensionsPixels: CGSize
    let cellDimensionsPixels: CGSize
    var gremlins: [Gremlin]
    let grid: Grid

    init(_ gridDimensionsPixels: CGSize) {
        self.gridDimensionsPixels = gridDimensionsPixels

        self.grid = Grid(
            size: gridDimensionsCells, cellFactory: GremlinCellFactory()
        )

        cellDimensionsPixels = gridDimensionsPixels / gridDimensionsCells.asSize()

        self.gremlins = grid.makeIterator().map {
            let cell = ($0 as? GremlinCell)!

            let color: Color
            switch (cell.gridPosition.x, cell.gridPosition.y) {
            case (-3, _): color = .white
            case (-2, -1...1): color = .yellow
            case (1, -1...1): color = .yellow
            case (2, -1): color = .yellow
            case (2, 1): color = .yellow
            case (2, 0): color = .purple
            case (3, 2...3): color = .white
            case (3, (-3)...(-2)): color = .white
            case (3, -1...1): color = Color(hue: 0.15, saturation: 0, brightness: 1, opacity: 0.25)
            default: color = .blue
            }

            // Use separate variable because the cell's reference is weak.
            // Don't want the Gremlin going out of scope
            let g = Gremlin(color)
            cell.gremlin = g
            return g
        }
    }

    func cellAt(x: Int, y: Int) -> GremlinCell {
        let cell = grid.cellAt(GridPoint(x: x, y: y))
        return (cell as? GremlinCell)!
    }

    func getGremlin(_ x: Int, _ y: Int) -> some View {
        let cell = cellAt(x: x, y: y)
        return cell.gremlin!.rectangle.foregroundColor(cell.gremlin!.color)
    }

    func pixelPosition(for gridPosition: GridPoint) -> CGPoint {
        gridPosition.asPoint() + (gridDimensionsPixels.asPoint() / 2) +
        gridPosition.asPoint() * cellDimensionsPixels.asPoint()
    }

    var visibleGrid: some View {
        VStack {
            ForEach(0..<grid.height) { y in
                HStack {
                    ForEach(0..<grid.width) { x in
                        getGremlin(x - grid.width / 2, y - grid.height / 2).padding(-3)
                    }
                }
            }
        }
        .frame(width: gridDimensionsPixels.width, height: gridDimensionsPixels.height)
        .padding(7)
    }

    var labels: some View {
        return ForEach(0..<grid.area) { ix in
            let centerCell = grid.cellAt(GridPoint.zero)
            let ap = grid.cellAt(ix, from: centerCell)!
            let pp = pixelPosition(for: ap.gridPosition)

            Text("\(ap.gridPosition.debugDescription)").position(pp)
        }
    }

    var body: some View {
        HStack {
            visibleGrid
            VStack {
                ForEach(0..<5) { _ in
                    Rectangle().foregroundColor(.blue)
                }
            }.frame(width: cellDimensionsPixels.width, height: cellDimensionsPixels.height)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { gr in ContentView(gr.size) }
    }
}
