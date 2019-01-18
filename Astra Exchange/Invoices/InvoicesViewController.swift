import UIKit

class InvoicesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var invoicesTableView: UITableView!
	@IBOutlet weak var noInvoicesLabel: UILabel!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		noInvoicesLabel.isHidden = !invoices.isEmpty
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .invoice {
				self.invoicesTableView.reloadData()
			}
		}
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return invoices.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return invoices[section].from == id ? "OUTGOING" : "INCOMING"
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = invoices[indexPath.section]
		cell.textLabel?.font = UIFont(name: "Nunito-ExtraBold", size: 18)
		cell.detailTextLabel?.font = UIFont(name: "Nunito-ExtraBold", size: 18)
		switch element.status {
		case "accepted":
			cell.imageView?.image = #imageLiteral(resourceName: "Check")
			cell.textLabel?.text = "Accepted"
			cell.textLabel?.textColor = UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1)
		case "declined":
			cell.imageView?.image = #imageLiteral(resourceName: "Red X")
			cell.textLabel?.text = "Declined"
			cell.textLabel?.textColor = UIColor(red: 204 / 255, green: 51 / 255, blue: 51 / 255, alpha: 1)
		default:
			cell.imageView?.image = #imageLiteral(resourceName: "Exclamation")
			cell.textLabel?.text = "Pending"
			cell.textLabel?.textColor = UIColor(red: 190 / 255, green: 190 / 255, blue: 190 / 255, alpha: 1)
		}
		cell.detailTextLabel?.text = element.from == id ? "+\(element.amount)" : "-\(element.amount)"
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let invoiceVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "invoice") as? InvoiceViewController {
			invoiceVC.invoice = indexPath.section
			invoiceVC.initialStatus = invoices[indexPath.section].status
			addChild(invoiceVC)
			invoiceVC.view.frame = view.frame
			view.addSubview(invoiceVC.view)
			invoiceVC.didMove(toParent: self)
		}
	}
}
