struct GridIndexer {
    private let cCellsWithinSenseRange: Int
    private let indexedGridPoints: [KGPoint]
    private let locator: GridCellLocator

    init(locator: GridCellLocator, cMaxSenseRings: Int) {
        self.locator = locator
        self.cCellsWithinSenseRange = GridIndexer.cellsWithinSenseRange(cMaxSenseRings)

        var p = [KGPoint]()
        p.reserveCapacity(cCellsWithinSenseRange)

        (0..<cCellsWithinSenseRange).forEach {
            p.append(GridIndexer.makeIndexedGridPoint($0))
        }

        indexedGridPoints = p
    }
}

extension GridIndexer {
    static func cellsWithinSenseRange(_ cSenseRings: Int) -> Int {
        let cCellsPerSide = 1 + 2 * cSenseRings
        return cCellsPerSide * cCellsPerSide
    }

    func localIndexToVirtualGrid(
        _ localIx: Int, from center: GridCell
    ) -> KGPoint {
        indexedGridPoints[localIx] + center.properties.gridPosition
    }

    func localIndexToRealGrid(
        _ localIx: Int, from center: GridCell
    ) -> Grid.AsteroidPoint {
        let virtualGridPosition = localIndexToVirtualGrid(localIx, from: center)
        return asteroidize(virtualGridPosition)
    }

    func offsetToLocalIndex(_ offset: KGPoint) -> Int {
        let whichRing = max(abs(offset.x), abs(offset.y))

        let result: Int
        if offset.y == whichRing {
            // We're at the top of the ring
            result = square(2 * whichRing + 1) - (2 * whichRing - offset.x)

        } else if offset.x == whichRing {
            // We're on the right of the ring; need to check top or bottom
            let d = (offset.y > 0) ? 1 : -1
            result = square(2 * whichRing + d) - offset.y

        } else if offset.y == -whichRing {
            // We're on the bottom of the ring
            result = square(2 * whichRing - 1) + (2 * whichRing - offset.x)

        } else if offset.x == -whichRing {
            // We're on the left of the ring
            result = square(2 * whichRing) + offset.y + 1
        } else {
            fatalError()
        }

        return result
    }
}

extension GridIndexer {
    func first(
        from centerCell: GridCell, cMaxCells: Int,
        where predicate: @escaping (Grid.AsteroidPoint) -> Bool
    ) -> Grid.AsteroidPoint? {
        var asteroid = Grid.AsteroidPoint(
            realCell: centerCell,
            relativeVirtualPosition: KGPoint.zero
        )

        let ix = (0..<cMaxCells).first { localIndex in
            asteroid = localIndexToRealGrid(localIndex, from: centerCell)

            return predicate(asteroid)
        }

        return ix == nil ? nil : asteroid
    }
}

private extension GridIndexer {
    // In other words, check whether the specified point is out of bounds of
    // the grid, and if so, return the point on the other side of the grid,
    // a wrap-around like the old Atari game called Asteroids
    func asteroidize(_ virtualGridPosition: KGPoint) -> Grid.AsteroidPoint {
        let ax = abs(virtualGridPosition.x), sx = (virtualGridPosition.x < 0) ? -1 : 1
        let ay = abs(virtualGridPosition.y), sy = (virtualGridPosition.y < 0) ? -1 : 1

        var newX = virtualGridPosition.x, newY = virtualGridPosition.y

        func warp(_ a: Int, _ gridDimension: Int, _ new: Int, _ sign: Int) -> Int? {
            (a > gridDimension / 2) ? sign * (a - gridDimension) : nil
        }

        if let nx = warp(ax, locator.gridDimensionsCells.width, newX, sx) { newX = nx }
        if let ny = warp(ay, locator.gridDimensionsCells.height, newY, sy) { newY = ny }

        let realGridPosition = KGPoint(x: newX, y: newY)
        let realCell = locator.cellAt(realGridPosition)

        return realGridPosition == virtualGridPosition ?
            Grid.AsteroidPoint(
                realCell: realCell,
                relativeVirtualPosition: realGridPosition
            ) :

            Grid.AsteroidPoint(
                realCell: realCell,
                relativeVirtualPosition: virtualGridPosition
            )
    }
}

private extension GridIndexer {
    enum LikeCSS { case rightBottom, rightTop, bottom, left, top }

    static func makeIndexedGridPoint(_ targetIndex: Int) -> KGPoint {
        if targetIndex == 0 { return KGPoint.zero }

        let baseX = getBaseX(targetIndex)
        var partialIndex = _2xMinusOneSquared(baseX)
        let sideExtent = getExtent(baseX)

        var x = baseX, y = 0
        var whichSide = LikeCSS.rightBottom

        while partialIndex < targetIndex {
            switch whichSide {
            case .rightBottom: fallthrough
            case .rightTop: (x, y, whichSide) =  stepDown(x, y, sideExtent, whichSide)

            case .bottom: (x, y, whichSide) =  stepLeft(x, y, sideExtent, whichSide)
            case .left:   (x, y, whichSide) =    stepUp(x, y, sideExtent, whichSide)
            case .top:    (x, y, whichSide) = stepRight(x, y, sideExtent, whichSide)
            }

            partialIndex += 1
        }

        return KGPoint(x: x, y: y)
    }
}

private extension GridIndexer {
    static func _2xMinusOneSquared(_ x: Int) -> Int { ((2 * x) - 1) * ((2 * x) - 1) }

    static func getBaseX(_ index: Int) -> Int {
        if index == 0 { return 0 }

        var result = 0
        for x in 0... {
            if _2xMinusOneSquared(x) > index { result = x - 1; break }
        }

        return result
    }

    static func getExtent(_ x: Int) -> Int { x }
    static func getSide(_ x: Int) -> Int { 2 * x + 1 }

    //swiftlint:disable large_tuple
    static func stepDown(_ x: Int, _ y : Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == -sideExtent {
            whichSide = .bottom
            return stepLeft(x, y, sideExtent, whichSide)
        }

        return (x + 0, y - 1, whichSide)
    }

    static func stepLeft(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == -sideExtent {
            whichSide = .left
            return stepUp(x, y, sideExtent, whichSide)
        }

        return (x - 1, y + 0, whichSide)
    }

    static func stepUp(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if y == sideExtent {
            whichSide = .top
            return stepRight(x, y, sideExtent, whichSide)
        }

        return (x + 0, y + 1, whichSide)
    }

    static func stepRight(_ x: Int, _ y: Int, _ sideExtent: Int, _ whichSide_: LikeCSS) -> (Int, Int, LikeCSS) {
        var whichSide = whichSide_

        if x == sideExtent && y == sideExtent {
            whichSide = .rightTop
            return stepDown(x, y, sideExtent, whichSide)
        }

        return (x + 1, y + 0, whichSide)
    }
    //swiftlint:enable large_tuple
}
