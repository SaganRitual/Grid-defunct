class Deque<T> {
    private(set) var elements: [T?]
    private var firstPass = true
    private var nextPopOffset: Int = 0
    private var nextPushOffset: Int = 0
    private(set) var dequeWidth: Int
    private var wrappedPop = false

    var count: Int {
        if nextPushOffset == nextPopOffset { return wrappedPop ? dequeWidth : 0 }
        if nextPushOffset > nextPopOffset  { return nextPushOffset - nextPopOffset }
        else                               { return nextPushOffset - nextPopOffset + dequeWidth }
    }

    // swiftlint:disable empty_count
    var isEmpty: Bool { count == 0 }
    // swiftlint:enable empty_count

    var isFull: Bool { return elements.count == dequeWidth }

    init(cElements: Int) {
        self.dequeWidth = cElements

        elements = []
        elements.reserveCapacity(dequeWidth)
    }

    @discardableResult
    func popFront() -> T {
        assert(nextPopOffset != nextPushOffset || wrappedPop == true,
            "Deque underflow -- line \(#line) in \(#file)"
        )

        defer {
            elements[nextPopOffset] = nil
            nextPopOffset = (nextPopOffset + 1) % dequeWidth
            wrappedPop = false
        }

        return elements[nextPopOffset]!
    }

    func pushBack(_ element: T) {
        assert(nextPopOffset != nextPushOffset || wrappedPop == false,
            "Deque overflow -- line \(#line) in \(#file)"
        )

        defer {
            nextPushOffset = (nextPushOffset + 1) % dequeWidth

            // Rememeber that the push pointer has caught the pop pointer,
            // meaning that we've wrapped all the way around to it
            wrappedPop = (nextPushOffset == nextPopOffset)
            firstPass = false
        }

        put_(element)
    }

    private func put_(_ element: T) {
        if elements.count < dequeWidth {
            elements.append(element)
            return
        }

        elements[nextPushOffset] = element
    }
}
