import UIKit
import AudioToolbox

class InvoiceConfirmViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var confirmView: UIView!
	@IBOutlet weak var confirmViewVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var recipientText: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var newBalanceText: UILabel!
	@IBOutlet weak var messageTextField: UITextField!
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		loadingView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 10)
		if let createInvoiceVC = parent as? CreateInvoiceViewController {
			recipientText.text = users[createInvoiceVC.recipient!].name
			amountText.text = String(createInvoiceVC.amount)
			newBalanceText.text = String(balance + createInvoiceVC.amount)
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
				if let createInvoiceVC = self.parent as? CreateInvoiceViewController {
					self.newBalanceText.text = String(balance + createInvoiceVC.amount)
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
		guard let createInvoiceVC = parent as? CreateInvoiceViewController, let message = messageTextField.text?.trim() else { return }
		loadingView.isHidden = false
		activityIndicator.startAnimating()
		let recipientId = users[createInvoiceVC.recipient!].id
		let autoId = ref.childByAutoId().key!
		let newInvoice: [String: Any] = ["time": Date().format("MMM d, yyyy @ h:mm a"), "status": "pending", "from": id!, "to": recipientId, "amount": createInvoiceVC.amount, "message": message]
		ref.child("invoices/\(id!)/\(autoId)").setValue(newInvoice) { error, reference in
			if error == nil {
				ref.child("invoices/\(recipientId)/\(autoId)").setValue(newInvoice)
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
					self.confirmView.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.height)
					self.view.backgroundColor = .clear
				}) { finished in
					if finished {
						self.view.removeFromSuperview()
						createInvoiceVC.navigationController?.popViewController(animated: true)
					}
				}
			} else if let error = error {
				self.activityIndicator.stopAnimating()
				self.loadingView.isHidden = true
				self.handleError(error, default: "There was a problem creating an invoice. Please try again.")
			}
		}
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.confirmView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				if let createInvoiceVC = self.parent as? CreateInvoiceViewController {
					createInvoiceVC.updateSendButton()
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
