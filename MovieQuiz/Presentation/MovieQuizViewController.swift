import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var statistics: StatisticServiceProtocol?
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var buttonsStackView: UIStackView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statistics = StatisticService()
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if !currentQuestion.correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        if currentQuestion.correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    func alertPresenterDidPresent() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    private func showLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
        }
    }
    
    private func hideLoadingIndicator() {
        DispatchQueue.main.async {
            self.activityIndicator.isHidden = true
        }
    }
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self]  in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.questionFactory?.loadData()
        }
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        alertPresenter.showAlert(with: model)
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 {
            statistics?.store(correct: correctAnswers, total: questionsAmount)
            let string1 = "Ваш результат: \(correctAnswers)/10"
            let string2 = "Количество сыгранных квизов: \(statistics?.gamesCount ?? 0 )"
            let string3 = "Рекорд: \(statistics?.bestGame.correct ?? 0)/\(statistics?.bestGame.total ?? 0) (\((statistics?.bestGame.date.dateTimeString ?? Date().dateTimeString)))"
            let string4 = "Средняя точность: \(String(format: "%.2f", statistics?.totalAccuracy ?? 0)) %"
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: "\(string1) \n\(string2) \n\(string3) \n\(string4)",
                buttonText: "Сыграть ещё раз"
            ) { self.alertPresenterDidPresent()
            }
            showResult(quiz: viewModel) }
        else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?  UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonsStackView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.showNextQuestionOrResults()
        }
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let output = QuizStepViewModel.init(image: UIImage(data: model.image) ?? UIImage(),
                                            question: model.text,
                                            questionNumber: String(currentQuestionIndex+1)+"/"+String(questionsAmount))
        return output
    }
    
    private func show(quiz step: QuizStepViewModel) {
        self.hideLoadingIndicator()
        buttonsStackView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 0
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showResult(quiz result: AlertModel) {
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        alertPresenter.showAlert(with: result)
    }
}


