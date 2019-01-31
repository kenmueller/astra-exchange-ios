import UIKit
import Firebase
import AudioToolbox

class ConfirmViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var confirmView: UIView!
	@IBOutlet weak var confirmViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var recipientText: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var remainingBalanceLabel: UILabel!
	@IBOutlet weak var remainingBalanceText: UILabel!
	@IBOutlet weak var messageTextField: UITextField!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		loadingView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
		if let sendMoneyVC = parent as? SendMoneyViewController {
			recipientText.text = users[sendMoneyVC.recipient!].name
			amountText.text = String(sendMoneyVC.amount)
			remainingBalanceText.text = String(balance - sendMoneyVC.amount)
		}
		confirmView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.confirmView.transform = .identity
		}, completion: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .balance {
				if let sendMoneyVC = self.parent as? SendMoneyViewController {
					self.amountText.text = String(sendMoneyVC.amount)
					self.remainingBalanceText.text = String(balance - sendMoneyVC.amount)
					if balance < sendMoneyVC.amount {
						self.amountLabel.textColor = .red
						self.remainingBalanceLabel.textColor = .red
						self.disable()
					} else {
						self.amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
						self.remainingBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
						self.enable()
					}
				}
			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			confirmViewVerticalConstraint.constant = confirmView.frame.height / 2 - height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		confirmViewVerticalConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	@IBAction func send() {
		if let sendMoneyVC = parent as? SendMoneyViewController, let message = messageTextField.text?.trim() {
			loadingView.isHidden = false
			activityIndicator.startAnimating()
			ref.child("transactions/\(id!)").childByAutoId().setValue(["time": Date().format("MMM d, yyyy @ h:mm a"), "from": id!, "to": users[sendMoneyVC.recipient!].id, "amount": sendMoneyVC.amount, "balance": balance - sendMoneyVC.amount, "message": message]) { error, reference in
				if error == nil {
					self.activityIndicator.stopAnimating()
					self.loadingView.isHidden = true
					UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
						self.confirmView.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.height)
						self.view.backgroundColor = .clear
					}) { finished in
						if finished {
							self.view.removeFromSuperview()
							sendMoneyVC.navigationController?.popViewController(animated: true)
						}
					}
				} else if let error = error {
					self.activityIndicator.stopAnimating()
					self.loadingView.isHidden = true
					switch error.localizedDescription {
					case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
						self.showAlert("No internet")
					default:
						self.showAlert("There was a problem sending money. Please try again.")
					}
				}
			}
		}
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.confirmView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				if let sendMoneyVC = self.parent as? SendMoneyViewController {
					sendMoneyVC.updateSendButton()
					self.view.removeFromSuperview()
				}
			}
		}
	}
	
	func enable() {
		sendButton.isEnabled = true
		sendButton.setTitleColor(.white, for: .normal)
	}
	
	func disable() {
		sendButton.isEnabled = false
		sendButton.setTitleColor(UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1), for: .normal)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}
