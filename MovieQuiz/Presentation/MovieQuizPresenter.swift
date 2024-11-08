import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    var correctAnswers: Int = 0
    
    private var currentQuestionIndex: Int = 0
    
    internal var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
    
    internal func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            let statistics = viewController?.statistics
            statistics?.store(correct: correctAnswers, total: questionsAmount)
            let string1 = "Ваш результат: \(correctAnswers)/10"
            let string2 = "Количество сыгранных квизов: \(statistics?.gamesCount ?? 0 )"
            let string3 = "Рекорд: \(statistics?.bestGame.correct ?? 0)/\(statistics?.bestGame.total ?? 0) (\((statistics?.bestGame.date.dateTimeString ?? Date().dateTimeString)))"
            let string4 = "Средняя точность: \(String(format: "%.2f", statistics?.totalAccuracy ?? 0)) %"
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "\(string1) \n\(string2) \n\(string3) \n\(string4)",
                buttonText: "Сыграть ещё раз"
            ) { self.viewController?.alertPresenterDidPresent()
            }
            viewController?.showResult(quiz: viewModel) }
        else {
            self.switchToNextQuestion()
            viewController?.questionFactory?.requestNextQuestion()
        }
    }
    
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let output = QuizStepViewModel.init(image: UIImage(data: model.image) ?? UIImage(),
                                            question: model.text,
                                            questionNumber: String(currentQuestionIndex+1)+"/"+String(questionsAmount))
        return output
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
}
