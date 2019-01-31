import UIKit
import AudioToolbox

class InvoiceViewController: UIViewController {
	@IBOutlet weak var invoiceView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var timeText: UILabel!
	@IBOutlet weak var fromToLabel: UILabel!
	@IBOutlet weak var fromToText: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var remainingBalanceNewBalanceLabel: UILabel!
	@IBOutlet weak var remainingBalanceNewBalanceText: UILabel!
	@IBOutlet weak var messageText: UILabel!
	@IBOutlet weak var declineButton: UIButton!
	@IBOutlet weak var acceptButton: UIButton!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var confirmButton: UIButton!
	@IBOutlet weak var statusImageView: UIImageView!
	@IBOutlet weak var statusLabel: UILabel!
	
	var invoice = 0
	var initialStatus = ""
	var willAccept = false
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		let element = invoices[invoice]
		let isOutgoing = element.from == id
		titleLabel.text = (isOutgoing ? "Outgoing" : "Incoming") + " Invoice"
		timeText.text = element.time
		fromToLabel.text = isOutgoing ? "TO" : "FROM"
		guard let toIndex = User.id(element.to), let fromIndex = User.id(element.from) else { return }
		fromToText.text = isOutgoing ? users[toIndex].name : users[fromIndex].name
		amountText.text = String(element.amount)
		remainingBalanceNewBalanceLabel.text = (isOutgoing ? "REMAINING" : "NEW") + " BALANCE"
		remainingBalanceNewBalanceText.text = String(isOutgoing ? balance + element.amount : balance - element.amount)
		messageText.text = element.message
		if isOutgoing {
			loadStatus()
		} else {
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
					declineButton.isHidden = false
					acceptButton.isHidden = false
				}
			} else {
				loadStatus()
			}
		}
		invoiceView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.invoiceView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .invoiceStatus {
				if invoices[self.invoice].status != self.initialStatus {
					UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
						self.declineButton.transform = CGAffineTransform(translationX: 0, y: 60)
						self.acceptButton.transform = CGAffineTransform(translationX: 0, y: 60)
						self.backButton.transform = CGAffineTransform(translationX: 0, y: 60)
						self.confirmButton.transform = CGAffineTransform(translationX: 0, y: 60)
					}) { finished in
						if finished {
							if let invoicesVC = self.parent as? InvoicesViewController {
								self.loadStatus()
								invoicesVC.invoicesTableView.reloadData()
							}
						}
					}
				}
			} else if change == .invoice {
				if let invoicesVC = self.parent as? InvoicesViewController {
					invoicesVC.invoicesTableView.reloadData()
				}
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
		let currentInvoice = invoices[invoice]
		ref.child("invoices/\(id!)/\(currentInvoice.id)/status").setValue(status)
		ref.child("invoices/\(currentInvoice.from)/\(currentInvoice.id)/status").setValue(status)
		if willAccept {
			ref.child("transactions/\(id!)").childByAutoId().setValue(["time": Date().format("MMM d, yyyy @ h:mm a"), "from": id!, "to": currentInvoice.from, "amount": currentInvoice.amount, "balance": balance - currentInvoice.amount, "message": currentInvoice.message]) { error, reference in
				if let error = error {
					switch error.localizedDescription {
					case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
						self.showAlert("No internet")
					default:
						self.showAlert("There was a problem accepting the invoice. Please try again.")
					}
				}
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
		switch invoices[invoice].status {
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
