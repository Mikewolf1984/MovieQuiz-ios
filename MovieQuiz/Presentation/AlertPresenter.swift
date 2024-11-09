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
            alertModel.completion?()
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            [weak self] in if let self =  self {
                alert.view.accessibilityIdentifier = "finalOrErrorAlert"
                self.delegate?.present(alert, animated: true)
            } else {
                return
            }
        }
    }
}
