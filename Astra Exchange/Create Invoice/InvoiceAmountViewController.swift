import UIKit

class InvoiceAmountViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var amountView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var addButton: UIButton!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var amountTextField: UITextField!
	@IBOutlet weak var amountBarView: UIView!
	@IBOutlet weak var newBalanceLabel: UILabel!
	@IBOutlet weak var newBalanceTextField: UITextField!
	@IBOutlet weak var newBalanceBarView: UIView!
	
	var amount = 0.0
	var valid = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		disable()
		hideKeyboard()
		amountView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.amountView.transform = CGAffineTransform.identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler(nil)
	}
	
	@IBAction func add() {
		if let createInvoiceVC = parent as? CreateInvoiceViewController {
			createInvoiceVC.amount = amount
			createInvoiceVC.actions[1].label = String(amount)
			createInvoiceVC.createInvoiceTableView.reloadData()
			createInvoiceVC.updateSendButton()
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
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if valid { return }
		if textField == amountTextField {
			amountLabel.textColor = .red
			amountBarView.backgroundColor = .red
			newBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			newBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		} else {
			newBalanceLabel.textColor = .red
			newBalanceBarView.backgroundColor = .red
			amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			amountBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		}
	}
	
	@IBAction func amountChanged() {
		guard let text = amountTextField.text?.trim() else { return }
		amount = Double(text) ?? 0
		newBalanceTextField.text = String(balance + amount)
		if text.isEmpty {
			amountLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			amountBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			disable()
		} else if amount > 0 {
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
	
	@IBAction func newBalanceChanged() {
		guard let text = newBalanceTextField.text?.trim() else { return }
		let newBalance = Double(text) ?? balance
		amount = newBalance - balance
		amountTextField.text = String(amount)
		if text.isEmpty {
			newBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			newBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			disable()
		} else if amount > 0 {
			newBalanceLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			newBalanceBarView.backgroundColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
			valid = true
			enable()
		} else {
			newBalanceLabel.textColor = .red
			newBalanceBarView.backgroundColor = .red
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
