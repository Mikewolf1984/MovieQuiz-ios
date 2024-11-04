import UIKit

final class StatisticService {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correctAnswers = "correctAnswers"
        case totalQuestions = "totalQuestions"
        case gamesCount = "gamesCount"
        case correctBest = "correctBest"
        case totalBest = "totalBest"
        case dateBest = "dateBest"
    }
}

extension StatisticService: StatisticServiceProtocol {
    
    internal var totalQuestionsCount: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    internal var correctAnswersCount: Int {
        get {
            storage.integer(forKey: Keys.correctAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswers.rawValue)
        }
    }
    
    internal var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    internal var bestGame: GameResult {
        get {
            
            let totalBest = storage.integer(forKey: Keys.totalBest.rawValue)
            let correctBest = storage.integer(forKey: Keys.correctBest.rawValue)
            if let dateBest = storage.object(forKey: Keys.dateBest.rawValue) as? Date
            { return GameResult (correct: correctBest, total: totalBest, date: dateBest) }
            else { return GameResult (correct: correctBest, total: totalBest, date: Date())
            }
        }
        set {
            storage.set(newValue.total, forKey: Keys.totalBest.rawValue)
            storage.set(newValue.correct, forKey: Keys.correctBest.rawValue)
            storage.set(newValue.date, forKey: Keys.dateBest.rawValue)
        }
    }
    
    internal var totalAccuracy: Double {
        if gamesCount != 0 {
            return (Double(correctAnswersCount) / Double((totalQuestionsCount)))*100
        } else {
            return 0
        }
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        correctAnswersCount += count
        totalQuestionsCount += amount
        let oldBest = bestGame
        let newResult = GameResult (correct: count, total: amount, date: Date())
        bestGame = newResult.isBestGame(bestGame: oldBest) ? newResult : oldBest
    }
}

