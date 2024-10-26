
import UIKit
class AlertPresenter: AlertPresenterProtocol {
    var delegate: AlertPresenterDelegate?
    
    func showAlert(with alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) {
            [weak self] _ in if let _self = self {
                _self.delegate?.alertPresenterDidPresent()
            } else {
                return
            }
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            [weak self] in if let _self =  self {
                _self.delegate?.present(alert, animated: true)
            } else {
                return
            }
        }
    }
}
