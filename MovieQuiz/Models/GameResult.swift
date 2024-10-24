import UIKit

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    func isBestGame (newGame: GameResult) -> Bool {
        return correct < newGame.correct
    }
}
