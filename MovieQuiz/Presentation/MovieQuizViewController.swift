import UIKit

final class MovieQuizViewController: UIViewController {
    
    struct QuizStepViewModel {
        let image: UIImage
        let question: String
        let questionNumber: String
    }
    
    struct QuizResultsViewModel {
        let title: String
        let text: String
        let buttonText: String
    }
    
    struct QuizQuestion {
        let image: String
        let text: String
        let correctAnswer: Bool
    }
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    
    private let questions: [QuizQuestion] =
    [QuizQuestion(image: "The Godfather",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "The Dark Knight",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "Kill Bill",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "The Avengers",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "Deadpool",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "The Green Knight",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: true),
     QuizQuestion(image: "Old",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: false),
     QuizQuestion(image: "The Ice Age Adventures of Buck Wild",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: false),
     QuizQuestion(image: "Vivarium",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: false),
     QuizQuestion(image: "Tesla",
                  text: "Рейтинг этого фильма больше чем 6?",
                  correctAnswer: false)]
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var buttonsStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[currentQuestionIndex]))
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        if !questions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        if questions[currentQuestionIndex].correctAnswer {
            correctAnswers += 1
            showAnswerResult(isCorrect: true)
        } else {
            showAnswerResult(isCorrect: false)
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз")
            showResult(quiz: viewModel) }
        else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
        }
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 10
        imageView.layer.cornerRadius = 6
        imageView.layer.borderColor = isCorrect ?  UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        buttonsStackView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
 
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let output = QuizStepViewModel.init(image: UIImage(named: model.image) ?? UIImage(),
                                            question: model.text,
                                            questionNumber: String(currentQuestionIndex+1)+"/"+String(questions.count))
        return output
    }
    
    private func show(quiz step: QuizStepViewModel) {
        buttonsStackView.isUserInteractionEnabled = true
        imageView.layer.borderWidth = 0
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showResult(quiz result: QuizResultsViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
}


