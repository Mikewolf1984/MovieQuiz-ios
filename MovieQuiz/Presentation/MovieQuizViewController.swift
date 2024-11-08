import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    private let presenter =  MovieQuizPresenter ()
    
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var alertPresenter: AlertPresenterProtocol? = AlertPresenter()
    
    private var correctAnswers = 0
    private var statistics: StatisticServiceProtocol?
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var buttonsStackView: UIStackView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        statistics = StatisticService()
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
    
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    func alertPresenterDidPresent() {
        presenter.resetQuestionIndex()
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
        let viewModel = presenter.convert(model: question)
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
        if presenter.isLastQuestion() {
            statistics?.store(correct: correctAnswers, total: presenter.questionsAmount)
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
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    internal func showAnswerResult(isCorrect: Bool) {
        
        isCorrect ? correctAnswers += 1 : nil
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ?  UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonsStackView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {[weak self] in
            guard let self = self else { return }
            self.showLoadingIndicator()
            self.showNextQuestionOrResults()
        }
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


