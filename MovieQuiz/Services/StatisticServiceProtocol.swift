import UIKit

protocol StatisticServiceProtocol {
    var correctAnswersCount: Int { get }
    var totalQuestionsCount: Int { get }
    var gamesCount: Int { get }
    var totalAccuracy: Double { get }
    var bestGame: GameResult { get }
    
    func store(correct count: Int, total amount: Int)
}
