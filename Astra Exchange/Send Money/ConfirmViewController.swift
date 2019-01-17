import UIKit
import Firebase
import AudioToolbox

class ConfirmViewController: UIViewController {
	@IBOutlet weak var confirmView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var sendButton: UIButton!
	@IBOutlet weak var recipientText: UILabel!
	@IBOutlet weak var amountLabel: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var remainingBalanceLabel: UILabel!
	@IBOutlet weak var remainingBalanceText: UILabel!
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
			self.confirmView.transform = CGAffineTransform.identity
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
	}
	
	@IBAction func send() {
		if let sendMoneyVC = parent as? SendMoneyViewController {
			loadingView.isHidden = false
			activityIndicator.startAnimating()
			let recipientId = users[sendMoneyVC.recipient!].id
			ref.child("users/\(recipientId)/balance").observeSingleEvent(of: .value) { snapshot in
				ref.child("users/\(id!)/balance").setValue(String(balance - sendMoneyVC.amount)) { error, reference in
					if error == nil {
						let recipientBalance = String(Double(snapshot.value as! String)! + sendMoneyVC.amount)
						ref.child("users/\(recipientId)/balance").setValue(recipientBalance)
						let autoId = ref.childByAutoId().key!
						let time = Date().format("MMM d, yyyy @ h:mm a")
						ref.child("transactions/\(id!)/\(autoId)").setValue(["time": time, "from": id!, "to": recipientId, "amount": String(sendMoneyVC.amount), "balance": String(balance)])
						ref.child("transactions/\(recipientId)/\(autoId)").setValue(["time": time, "from": id!, "to": recipientId, "amount": String(sendMoneyVC.amount), "balance": recipientBalance])
						self.activityIndicator.stopAnimating()
						self.loadingView.isHidden = true
					} else if let error = error {
						self.activityIndicator.stopAnimating()
						self.loadingView.isHidden = true
						AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
						switch error.localizedDescription {
						case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
							self.showAlert("No internet")
						default:
							self.showAlert("There was a problem sending money. Please try again.")
						}
					}
				}
				UIView.animate(withDuration: 0.2, animations: {
					self.confirmView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
					self.view.backgroundColor = .clear
				}) { finished in
					if finished {
						self.view.removeFromSuperview()
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
}
