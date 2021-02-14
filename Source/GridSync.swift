// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

protocol GridSyncCellProtocol: GridCellProtocol {
    var isLocked: Bool { get set }
}

class GridSync {
    let grid: Grid

    var deferrals = [GridPoint: Deque<() -> Void>]()

    let callbackQueue: DispatchQueue
    let maxDeferralDepth: Int

    let lockQueue = DispatchQueue(
        label: "gridsync", target: DispatchQueue.global()
    )

    init(
        _ grid: Grid, callbackQueue: DispatchQueue = DispatchQueue.main,
        maxDeferralDepth: Int = 100
     ) {
        self.grid = grid
        self.callbackQueue = callbackQueue
        self.maxDeferralDepth = maxDeferralDepth
    }

    func cellAt(_ gridPosition: GridPoint) -> GridSyncCellProtocol {
        (grid.cellAt(gridPosition) as? GridSyncCellProtocol)!
    }

    func cellAt(
        _ ix: Int, from center: GridSyncCellProtocol
    ) -> GridSyncCellProtocol {
        let ap = grid.asteroidPoint(ix, from: center)
        return (ap.realCell as? GridSyncCellProtocol)!
    }

    func lockArea(
        center: GridSyncCellProtocol, cRings: Int,
        _ onComplete: @escaping ([Bool]) -> Void
    ) {
        lockQueue.async {
            let cCells = Grid.cRingsToCells(cRings: cRings)
            let lockmap: [Bool] =
                (0..<cCells).map {
                    if $0 == 0 { return false }
                    let cell = self.cellAt($0, from: center)

                    defer { cell.isLocked = true }
                    return !cell.isLocked
                }

            self.callbackQueue.async { onComplete(lockmap) }
        }
    }

    func lockCell(
        cell: GridSyncCellProtocol, _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async { [unowned self] in
            if cell.isLocked { deferCompletion(cell, onComplete); return }

            cell.isLocked = true
            callbackQueue.async(execute: onComplete)
        }
    }

    func releaseLock(cell: GridSyncCellProtocol) {
        lockQueue.async { self.releaseLock_(cell: cell) }
    }

    private func releaseLock_(cell: GridSyncCellProtocol) {
        if let row = self.deferrals[cell.gridPosition], !row.isEmpty {
            callbackQueue.async(execute: row.popFront())
        } else {
            cell.isLocked = false
        }
    }

    // Notice no callback; releasing locks need not wait for anything
    func releaseLocks_(from center: GridSyncCellProtocol, lockmap: [Bool]) {
        for lockIndex in lockmap.indices where lockmap[lockIndex] == true {
            let cell = self.cellAt(lockIndex, from: center)
            self.releaseLock_(cell: cell)
        }
    }

    func releaseLocks(from center: GridSyncCellProtocol, lockmap: [Bool]) {
        lockQueue.async { self.releaseLocks_(from: center, lockmap: lockmap) }
    }

    func withGridLocked(
        execute work: @escaping () -> Void,
        _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async {
            work()
            self.callbackQueue.async(execute: onComplete)
        }
    }
}

private extension GridSync {
    func deferCompletion(
        _ cell: GridSyncCellProtocol, _ completion: @escaping () -> Void
    ) {
        if deferrals[cell.gridPosition] == nil {
            deferrals[cell.gridPosition] = Deque(cElements: maxDeferralDepth)
        }

        deferrals[cell.gridPosition]!.pushBack(completion)
    }
}
