import UIKit
import AudioToolbox

class UnpaidInvoicesViewController: UIViewController {
	@IBOutlet weak var invoiceView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var leftButton: UIButton!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var rightButton: UIButton!
	@IBOutlet weak var timeText: UILabel!
	@IBOutlet weak var fromText: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var remainingBalanceText: UILabel!
	@IBOutlet weak var messageText: UILabel!
	@IBOutlet weak var declineButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var statusImageView: UIImageView!
	@IBOutlet weak var statusLabel: UILabel!
	
	var unpaidInvoices = [Invoice]()
	var invoice = 0
	var willAccept = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		loadUnpaidInvoices()
		loadInvoice()
		invoiceView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.invoiceView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .invoice {
				if let sendMoneyVC = self.parent as? SendMoneyViewController {
					sendMoneyVC.sendMoneyTableView.reloadData()
				}
				self.loadUnpaidInvoices()
				self.loadInvoice()
			} else if change == .invoiceStatus {
				if let sendMoneyVC = self.parent as? SendMoneyViewController {
					sendMoneyVC.sendMoneyTableView.reloadData()
				}
				self.loadInvoice()
			}
		}
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.invoiceView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
	
	@IBAction func left() {
		UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.invoiceView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
		}) { finished in
			if finished {
				self.invoice -= 1
				self.loadInvoice()
				self.invoiceView.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
				UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
					self.invoiceView.transform = .identity
				}, completion: nil)
			}
		}
	}
	
	@IBAction func right() {
		if rightButton.currentImage == #imageLiteral(resourceName: "X") {
			hideAnimation()
		} else {
			UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
				self.invoiceView.transform = CGAffineTransform(translationX: -self.view.bounds.width, y: 0)
			}) { finished in
				if finished {
					self.invoice += 1
					self.loadInvoice()
					self.invoiceView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
					UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
						self.invoiceView.transform = .identity
					}, completion: nil)
				}
			}
		}
	}
	
	func loadUnpaidInvoices() {
		unpaidInvoices = invoices.filter { $0.to == id && $0.status == "pending" }
	}
	
	func loadInvoice() {
		leftButton.isHidden = invoice == 0
		if unpaidInvoices.count == 1 {
			rightButton.setImage(#imageLiteral(resourceName: "X"), for: .normal)
			rightButton.isHidden = false
		} else {
			rightButton.setImage(#imageLiteral(resourceName: "Right Arrow Head"), for: .normal)
			rightButton.isHidden = invoice == unpaidInvoices.count - 1
		}
		let element = unpaidInvoices[invoice]
		titleLabel.text = (element.status == "pending" ? "Unpaid" : "Paid") + " Invoice"
		timeText.text = element.time
		guard let userIndex = User.id(element.from) else { return }
		fromText.text = users[userIndex].name
		amountText.text = String(element.amount)
		remainingBalanceText.text = String(balance - element.amount)
		messageText.text = element.message
		if element.status == "pending" {
			if element.amount > balance {
				statusImageView.image = #imageLiteral(resourceName: "Red Warning")
				statusLabel.text = "Unable to pay"
				statusLabel.textColor = UIColor(red: 204 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
				statusImageView.isHidden = false
				statusLabel.isHidden = false
				declineButton.isHidden = true
				acceptButton.isHidden = true
			} else {
				statusImageView.isHidden = true
				statusLabel.isHidden = true
				declineButton.isHidden = false
				declineButton.transform = .identity
				acceptButton.isHidden = false
				acceptButton.transform = .identity
			}
			backButton.isHidden = true
			confirmButton.isHidden = true
		} else {
			loadStatus()
		}
	}
	
	@IBAction func decline() {
		willAccept = false
		showConfirm(declineButton)
	}
	
	@IBAction func accept() {
		willAccept = true
		showConfirm(acceptButton)
	}
	
	@IBAction func back() {
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
			self.backButton.transform = CGAffineTransform(translationX: 0, y: 60)
			self.backButton.alpha = 0
			self.confirmButton.transform = CGAffineTransform(translationX: 0, y: 60)
			self.confirmButton.alpha = 0
		}) { finished in
			if finished {
				UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
					self.declineButton.transform = .identity
					self.declineButton.alpha = 1
					self.acceptButton.transform = .identity
					self.acceptButton.alpha = 1
				}, completion: nil)
			}
		}
	}
	
	@IBAction func confirm() {
		let status = willAccept ? "accepted" : "declined"
		let invoiceId = unpaidInvoices[invoice].id
		ref.child("invoices/\(id!)/\(invoiceId)/status").setValue(status)
		ref.child("invoices/\(unpaidInvoices[invoice].from)/\(invoiceId)/status").setValue(status)
		if willAccept {
			ref.child("users/\(id!)/balance").setValue(String(balance - unpaidInvoices[invoice].amount)) { error, reference in
				if error == nil {
					let fromId = self.unpaidInvoices[self.invoice].from
					guard let userIndex = User.id(fromId) else { return }
					let fromBalance = String(users[userIndex].balance + self.unpaidInvoices[self.invoice].amount)
					ref.child("users/\(fromId)/balance").setValue(fromBalance)
					guard let autoId = ref.childByAutoId().key else { return }
					let time = Date().format("MMM d, yyyy @ h:mm a")
					ref.child("transactions/\(id!)/\(autoId)").setValue(["time": time, "from": id!, "to": fromId, "amount": String(self.unpaidInvoices[self.invoice].amount), "balance": String(balance), "message": self.unpaidInvoices[self.invoice].message])
					ref.child("transactions/\(fromId)/\(autoId)").setValue(["time": time, "from": id!, "to": fromId, "amount": String(self.unpaidInvoices[self.invoice].amount), "balance": fromBalance, "message": self.unpaidInvoices[self.invoice].message])
				} else if let error = error {
					AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
					switch error.localizedDescription {
					case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
						self.showAlert("No internet")
					default:
						self.showAlert("There was a problem accepting the invoice. Please try again.")
					}
				}
				self.loadInvoice()
				self.showConfirmAnimation()
			}
		} else {
			showConfirmAnimation()
		}
	}
	
	func showConfirm(_ button: UIButton) {
		let color = button.backgroundColor
		backButton.backgroundColor = color
		confirmButton.backgroundColor = color
		UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
			self.declineButton.transform = CGAffineTransform(translationX: 0, y: 60)
			self.declineButton.alpha = 0
			self.acceptButton.transform = CGAffineTransform(translationX: 0, y: 60)
			self.acceptButton.alpha = 0
		}) { finished in
			if finished {
				self.backButton.transform = CGAffineTransform(translationX: 0, y: 60)
				self.backButton.isHidden = false
				self.confirmButton.transform = CGAffineTransform(translationX: 0, y: 60)
				self.confirmButton.isHidden = false
				UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
					self.backButton.transform = .identity
					self.backButton.alpha = 1
					self.confirmButton.transform = .identity
					self.confirmButton.alpha = 1
				}, completion: nil)
			}
		}
	}
	
	func loadStatus() {
		switch unpaidInvoices[invoice].status {
		case "accepted":
			statusImageView.image = #imageLiteral(resourceName: "Check")
			statusLabel.text = "Accepted"
			statusLabel.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		case "declined":
			statusImageView.image = #imageLiteral(resourceName: "Red X")
			statusLabel.text = "Declined"
			statusLabel.textColor = UIColor(red: 204 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
		default:
			statusImageView.image = #imageLiteral(resourceName: "Exclamation")
			statusLabel.text = "Pending"
			statusLabel.textColor = UIColor(red: 190 / 255, green: 190 / 255, blue: 190 / 255, alpha: 1)
		}
		statusImageView.isHidden = false
		statusLabel.isHidden = false
	}
	
	func showConfirmAnimation() {
		loadUnpaidInvoices()
		guard let sendMoneyVC = self.parent as? SendMoneyViewController else { return }
		sendMoneyVC.sendMoneyTableView.reloadData()
		if (unpaidInvoices.filter { $0.status == "pending" }).isEmpty {
			UIView.animate(withDuration: 0.2, animations: {
				self.invoiceView.transform = CGAffineTransform(translationX: 0, y: -self.view.bounds.height)
				self.view.backgroundColor = .clear
			}) { finished in
				if finished {
					self.view.removeFromSuperview()
				}
			}
		}
	}
}
