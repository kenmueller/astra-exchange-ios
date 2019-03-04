import UIKit

class AmountViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var amountView: UIView!
	@IBOutlet weak var amountViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var addButton: UIButton!
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
		maxLabel.text = "MAX: \(balance)"
		disable()
		amountView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.amountView.transform = .identity
		}, completion: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .version {
				self.showUpdateVC()
			} else if change == .balance {
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
	
	@IBAction func add() {
		if let sendMoneyVC = parent as? SendMoneyViewController {
			sendMoneyVC.amount = amount
			sendMoneyVC.actions[sendMoneyVC.actions.count - 1].label = String(amount)
			sendMoneyVC.sendMoneyTableView.reloadData()
			sendMoneyVC.updateSendButton()
		}
		hideAnimation()
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.amountView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			amountViewVerticalConstraint.constant = amountView.frame.height / 2 - height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		amountViewVerticalConstraint.constant = 0
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
		addButton.isEnabled = true
		addButton.setTitleColor(.white, for: .normal)
	}
	
	func disable() {
		addButton.isEnabled = false
		addButton.setTitleColor(UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1), for: .normal)
	}
}
