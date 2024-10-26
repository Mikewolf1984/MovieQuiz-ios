import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    func isBestGame (bestGame: GameResult) -> Bool {
        return correct > bestGame.correct
    }
}
