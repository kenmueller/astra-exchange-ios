import UIKit

class TransactionViewController: UIViewController {
	@IBOutlet weak var transactionView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var timeText: UILabel!
	@IBOutlet weak var fromToLabel: UILabel!
	@IBOutlet weak var fromToText: UILabel!
	@IBOutlet weak var amountText: UILabel!
	@IBOutlet weak var remainingBalanceNewBalanceLabel: UILabel!
	@IBOutlet weak var remainingBalanceNewBalanceText: UILabel!
	
	var transaction = 0
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		let element = transactions[transaction]
		let isOutgoing = element.from == id
		titleLabel.text = (isOutgoing ? "Outgoing" : "Incoming") + " Transaction"
		timeText.text = element.time
		fromToLabel.text = isOutgoing ? "TO" : "FROM"
		fromToText.text = isOutgoing ? users[User.id(element.to)!].name : users[User.id(element.from)!].name
		amountText.text = String(element.amount)
		remainingBalanceNewBalanceLabel.text = (isOutgoing ? "REMAINING" : "NEW") + " BALANCE"
		remainingBalanceNewBalanceText.text = String(element.balance)
		transactionView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.transactionView.transform = CGAffineTransform.identity
		}, completion: nil)
    }
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.transactionView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
}