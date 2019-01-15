import UIKit
import CoreData
import Firebase

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var balanceLabel: UILabel!
	@IBOutlet weak var actionsTableView: UITableView!
	
	struct Action {
		let name: String
		let action: Selector
	}
	
	let actions = [
		Action(name: "Send Money", action: #selector(sendMoney)),
		Action(name: "Create Invoice", action: #selector(createInvoice)),
		Action(name: "Transaction History", action: #selector(transactionHistory))
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			ref.child("users").observe(.childAdded) { snapshot in
				users.append(User(id: snapshot.key, name: retrieveDataValue(snapshot: snapshot, field: "name") as! String, email: retrieveDataValue(snapshot: snapshot, field: "email") as! String))
			}
			if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
				let managedContext = appDelegate.persistentContainer.viewContext
				let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
				do {
					let login = try managedContext.fetch(fetchRequest)
					if login.count == 1 {
						let localEmail = login[0].value(forKey: "email") as? String
						Auth.auth().signIn(withEmail: localEmail!, password: login[0].value(forKey: "password") as! String) { user, error in
							if error == nil {
								id = user?.user.uid
								ref.child("users/\(id!)/name").observeSingleEvent(of: .value) { snapshot in
									name = snapshot.value as? String
								}
								email = localEmail
								loadData()
							}
						}
					} else if let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "home") as? HomeViewController {
						addChild(homeVC)
						homeVC.view.frame = view.frame
						view.addSubview(homeVC.view)
						homeVC.didMove(toParent: self)
					}
				} catch {}
			}
			startup = false
		}
		navigationController?.title = name
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler {
			self.balanceLabel.text = String(balance)
			self.actionsTableView.reloadData()
		}
	}
	
	@objc func sendMoney() {
		performSegue(withIdentifier: "sendMoney", sender: self)
	}
	
	@objc func createInvoice() {
		performSegue(withIdentifier: "createInvoice", sender: self)
	}
	
	@objc func transactionHistory() {
		performSegue(withIdentifier: "transactionHistory", sender: self)
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = actions[indexPath.row].name
		if indexPath.row == 0 {
			let unpaidInvoices = invoices.filter { $0.to == id! }
			if unpaidInvoices.count == 1 {
				cell.detailTextLabel?.text = "⚠️ 1 unpaid invoice"
			} else if unpaidInvoices.count > 1 {
				cell.detailTextLabel?.text = "⚠️ \(unpaidInvoices.count) unpaid invoices"
			}
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		performSelector(inBackground: actions[indexPath.row].action, with: nil)
	}
}
