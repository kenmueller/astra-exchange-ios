import UIKit

class TransactionViewController: UIViewController {
	@IBOutlet weak var typeLabel: UILabel!
	@IBOutlet weak var transactionView: UIView!
	@IBOutlet weak var titleBar: UIView!
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
		typeLabel.text = isOutgoing ? "OUTGOING" : "INCOMING"
		timeText.text = element.time
		fromToLabel.text = isOutgoing ? "TO" : "FROM"
		fromToText.text = isOutgoing ? users[User.id(transactions[transaction].to)!].name : users[User.id(transactions[transaction].from)!].name
		amountText.text = transaction[transaction]
		typeLabel.alpha = 0
		transactionView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.typeLabel.alpha = 1
			self.transactionView.transform = CGAffineTransform.identity
		}, completion: nil)
    }
}
