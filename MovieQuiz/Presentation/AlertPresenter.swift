
import UIKit
class AlertPresenter: AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate?
    func showAlert(with alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            self.delegate?.alertPresenterDidPresent()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            [weak self] in guard let self = self else { return }
            self.delegate?.present(alert, animated: true)
        }
    }
}
