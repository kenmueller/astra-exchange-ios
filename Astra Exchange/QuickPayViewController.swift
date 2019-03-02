import UIKit

class QuickPayViewController: UIViewController {
	@IBOutlet weak var quickPayView: UIView!
	@IBOutlet weak var quickPayViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var recipientLabel: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountBarView: UIView!
	@IBOutlet weak var maxLabel: UILabel!
	@IBOutlet weak var remainingBalanceLabel: UILabel!
	@IBOutlet weak var remainingBalanceTextField: UITextField!
	@IBOutlet weak var remainingBalanceBarView: UIView!
	
	var amount = 0.0
	var valid = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		recipientLabel.text = quickPayUser?.name
		maxLabel.text = "MAX: \(balance)"
		disable()
		quickPayView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.quickPayView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .balance {
				(self.parent as? UserViewController)?.actionsTableView.reloadData()
				self.amountChanged()
				UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
					self.maxLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
					self.maxLabel.alpha = 0.4
					self.maxLabel.text = "MAX: \(balance)"
				}) { finished in
					if finished {
						UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
							self.maxLabel.transform = .identity
							self.maxLabel.alpha = 1
						}, completion: nil)
					}
				}
			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@IBAction func send() {
		ref.child("transactions/\(id!)").childByAutoId().setValue(["time": Date().format("MMM d, yyyy @ h:mm a"), "from": id!, "to": quickPayUser!.id, "amount": amount, "balance": balance - amount, "message": ""]) { error, reference in
			if error == nil {
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
					self.quickPayView.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.height)
					self.view.backgroundColor = .clear
				}) { finished in
					if finished {
						quickPayUser = nil
						self.view.removeFromSuperview()
					}
				}
			} else if let error = error {
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("There was a problem sending money. Please try again.")
				}
			}
		}
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.quickPayView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				quickPayUser = nil
				self.view.removeFromSuperview()
			}
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			quickPayViewVerticalConstraint.constant = quickPayView.frame.height / 2 - height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		quickPayViewVerticalConstraint.constant = 0
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if valid { return }
		if textField == amountTextField {
			amountLabel.textColor = .red
			amountBarView.backgroundColor = .red
			remainingBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			remainingBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		} else {
			remainingBalanceLabel.textColor = .red
			remainingBalanceBarView.backgroundColor = .red
			amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			amountBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		}
	}
	
	@IBAction func amountChanged() {
		guard let text = amountTextField.text?.trim() else { return }
		amount = Double(text) ?? 0
		remainingBalanceTextField.text = String(balance - amount)
		if text.isEmpty {
			amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			amountBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			disable()
		} else if amount > 0 && amount <= balance {
			amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			amountBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			enable()
		} else {
			amountLabel.textColor = .red
			amountBarView.backgroundColor = .red
			valid = false
			disable()
		}
	}
	
	@IBAction func remainingBalanceChanged() {
		guard let text = remainingBalanceTextField.text?.trim() else { return }
		let remainingBalance = Double(text) ?? balance
		amount = balance - remainingBalance
		amountTextField.text = String(amount)
		if text.isEmpty {
			remainingBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			remainingBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			disable()
		} else if amount > 0 && amount <= balance {
			remainingBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			remainingBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			enable()
		} else {
			remainingBalanceLabel.textColor = .red
			remainingBalanceBarView.backgroundColor = .red
			valid = false
			disable()
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
}
