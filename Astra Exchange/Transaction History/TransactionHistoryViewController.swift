import UIKit

class TransactionHistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var transactionsTableView: UITableView!
	@IBOutlet weak var noTransactionsLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		noTransactionsLabel.isHidden = !transactions.isEmpty
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .transaction {
				self.transactionsTableView.reloadData()
			}
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return transactions.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return transactions[section].from == id ? "OUTGOING" : "INCOMING"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = transactions[indexPath.section]
		cell.textLabel?.text = element.time
		cell.detailTextLabel?.text = element.from == id ? "-\(element.amount)" : "+\(element.amount)"
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let transactionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "transaction") as? TransactionViewController {
			transactionVC.transaction = indexPath.section
			addChild(transactionVC)
			transactionVC.view.frame = view.frame
			view.addSubview(transactionVC.view)
			transactionVC.didMove(toParent: self)
		}
	}
}
