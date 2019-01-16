import UIKit

class SendMoneyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var sendMoneyTableView: UITableView!
	
	struct Action {
		let group: String
		var label: String
		let action: Selector
	}
	
	var actions = [
		Action(group: "RECIPIENT", label: "Select User", action: #selector(showUsers)),
		Action(group: "AMOUNT", label: "0.0", action: #selector(showAmount))
	]
	var recipient: Int?
	var amount = 0.0
	
    override func viewDidLoad() {
        super.viewDidLoad()
    }
	
//	@IBAction func payInvoices() {
//		performSegue(withIdentifier: "payInvoices", sender: self)
//	}
	
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
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSelector(onMainThread: actions[indexPath.section].action, with: nil, waitUntilDone: false)
	}
}
