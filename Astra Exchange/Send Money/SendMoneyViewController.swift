import UIKit

class SendMoneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var sendMoneyTableView: UITableView!
	@IBOutlet weak var sendButton: UIButton!
	
	struct Action {
		let group: String?
		var label: String
		let action: Selector
	}
	
	var actions = [Action]()
	var recipient: Int?
	var amount = 0.0
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .invoice || change == .invoiceStatus {
				self.loadActions()
				self.sendMoneyTableView.reloadData()
			} else if change == .balance {
				self.updateSendButton()
			}
		}
		loadActions()
		sendMoneyTableView.reloadData()
	}
	
	@objc func payInvoices() {
		if let unpaidInvoicesVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "unpaidInvoices") as? UnpaidInvoicesViewController {
			addChild(unpaidInvoicesVC)
			unpaidInvoicesVC.view.frame = view.frame
			view.addSubview(unpaidInvoicesVC.view)
			unpaidInvoicesVC.didMove(toParent: self)
		}
	}
	
	@objc func showUsers() {
		if let recipientVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "recipient") as? RecipientViewController {
			addChild(recipientVC)
			recipientVC.view.frame = view.frame
			view.addSubview(recipientVC.view)
			recipientVC.didMove(toParent: self)
		}
	}
	
	@objc func showAmount() {
		if let amountVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "amount") as? AmountViewController {
			addChild(amountVC)
			amountVC.view.frame = view.frame
			view.addSubview(amountVC.view)
			amountVC.didMove(toParent: self)
		}
	}
	
	@IBAction func send() {
		UIView.animate(withDuration: 0.15, animations: {
			self.sendButton.transform = CGAffineTransform(translationX: 0, y: 150)
		}) { finished in
			if finished {
				self.sendButton.isHidden = true
				if let confirmVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "confirm") as? ConfirmViewController {
					self.addChild(confirmVC)
					confirmVC.view.frame = self.view.frame
					self.view.addSubview(confirmVC.view)
					confirmVC.didMove(toParent: self)
				}
			}
		}
	}
	
	func updateSendButton() {
		if sendButton.isHidden {
			if !(recipient == nil || amount == 0) && amount <= balance {
				sendButton.transform = CGAffineTransform(translationX: 0, y: 150)
				sendButton.isHidden = false
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
					self.sendButton.transform = .identity
				}, completion: nil)
			}
		} else if recipient == nil || amount == 0 {
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveLinear, animations: {
				self.sendButton.transform = CGAffineTransform(translationX: 0, y: 150)
			}) { finished in
				if finished {
					self.sendButton.isHidden = true
				}
			}
		}
	}
	
	func loadActions() {
		actions = [Action(group: "RECIPIENT", label: "Select User", action: #selector(showUsers)), Action(group: "AMOUNT", label: "0.0", action: #selector(showAmount))]
		let unpaidInvoices = invoices.filter { $0.to == id && $0.status == "pending" }
		if !unpaidInvoices.isEmpty {
			if unpaidInvoices.count == 1 {
				actions.insert(Action(group: nil, label: "⚠️ 1 unpaid invoice", action: #selector(payInvoices)), at: 0)
			} else {
				actions.insert(Action(group: nil, label: "⚠️ \(unpaidInvoices.count) unpaid invoices", action: #selector(payInvoices)), at: 0)
			}
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return actions[section].group
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = actions[indexPath.section].label
		cell.detailTextLabel?.text = nil
		if actions.count == 3 && indexPath.section == 0 {
			cell.textLabel?.textColor = .red
			cell.detailTextLabel?.text = "Pay now"
			cell.detailTextLabel?.textColor = .red
			cell.backgroundColor = UIColor(red: 249 / 255, green: 222 / 255, blue: 75 / 255, alpha: 1)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSelector(onMainThread: actions[indexPath.section].action, with: nil, waitUntilDone: false)
	}
}
