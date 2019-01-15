import UIKit

class SendMoneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var invoiceView: UIView!
	@IBOutlet weak var invoiceLabel: UILabel!
	@IBOutlet weak var sendMoneyTableViewTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var sendMoneyTableView: UITableView!
	
	struct Action {
		let group: String
		var label: String
		let action: Selector
	}
	
	let actions = [
		Action(group: "TO", label: "Select User", action: #selector(showUsers)),
		Action(group: "AMOUNT", label: "0.0", action: #selector(showAmount))
	]
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
	@IBAction func payInvoices() {
		performSegue(withIdentifier: "payInvoices", sender: self)
	}
	
	@objc func showUsers() {
		
	}
	
	@objc func showAmount() {
		
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = actions[indexPath.row].label
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSelector(inBackground: actions[indexPath.row].action, with: nil)
	}
}
