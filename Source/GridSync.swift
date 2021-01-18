// We are a way for the cosmos to know itself. -- C. Sagan

import Foundation

protocol GridSyncCellProtocol: GridCellProtocol {
    var isLocked: Bool { get set }
}

class GridSync {
    let grid: Grid

    let lockQueue = DispatchQueue(
        label: "gridsync", target: DispatchQueue.global()
    )

    var deferrals = [GridPoint: Deque<() -> Void>]()

    init(_ grid: Grid) { self.grid = grid }

    func cellAt(_ gridPosition: GridPoint) -> GridSyncCellProtocol {
        (grid.cellAt(gridPosition) as? GridSyncCellProtocol)!
    }

    func cellAt(
        _ ix: Int, from center: GridSyncCellProtocol
    ) -> GridSyncCellProtocol {
        (grid.cellAt(ix, from: center) as? GridSyncCellProtocol)!
    }

    func lockArea(
        center: GridSyncCellProtocol, cRings: Int,
        _ onComplete: @escaping ([Bool]) -> Void
    ) {
        lockQueue.async {
            let lockmap: [Bool] =
                (0..<Grid.cRingsToCells(cRings: cRings)).map {
                    let cell = self.cellAt($0 + 1, from: center)
                    defer { cell.isLocked = true }
                    return !cell.isLocked
                }

            DispatchQueue.main.async { onComplete(lockmap) }
        }
    }

    func lockCell(
        cell: GridSyncCellProtocol, _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async {
            if cell.isLocked { self.deferCompletion(cell, onComplete); return }

            cell.isLocked = true
            DispatchQueue.main.async(execute: onComplete)
        }
    }

    func releaseLock(cell: GridSyncCellProtocol) {
        lockQueue.async { self.releaseLock_(cell: cell) }
    }

    private func releaseLock_(cell: GridSyncCellProtocol) {
        if let row = self.deferrals[cell.gridPosition], !row.isEmpty {
            DispatchQueue.main.async(execute: row.popFront())
        } else {
            cell.isLocked = false
        }
    }

    func releaseLocks(from center: GridSyncCellProtocol, lockmap: [Bool]) {
        lockQueue.async {
            lockmap.indices.forEach { lockIndex in
                if !lockmap[lockIndex] { return }
                let cell = self.cellAt(lockIndex + 1, from: center)
                self.releaseLock_(cell: cell)
            }
        }
    }

    func withGridLocked(
        execute work: @escaping () -> Void,
        _ onComplete: @escaping () -> Void
    ) {
        lockQueue.async {
            work()
            DispatchQueue.main.async(execute: onComplete)
        }
    }
}

private extension GridSync {
    func deferCompletion(
        _ cell: GridSyncCellProtocol, _ completion: @escaping () -> Void
    ) {
        if deferrals[cell.gridPosition] == nil {
            deferrals[cell.gridPosition] = Deque(cElements: 100)
        }

        deferrals[cell.gridPosition]!.pushBack(completion)
    }
}
