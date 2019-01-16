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
		[Action(name: "Send Money", action: #selector(sendMoney)), Action(name: "Create Invoice", action: #selector(createInvoice))],
		[Action(name: "Transaction History", action: #selector(transactionHistory))]
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
									self.navigationItem.title = name
								}
								email = localEmail
								loadData()
							} else if let error = error {
								switch error.localizedDescription {
								case "FIRAuthErrorCodeNetworkError":
									self.showAlert("No internet")
								default:
									self.showHomeVC()
								}
							}
						}
					} else {
						showHomeVC()
					}
				} catch {}
			}
			startup = false
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler {
			self.balanceLabel.text = String(balance)
			self.actionsTableView.reloadData()
		}
	}
	
	func showHomeVC() {
		performSegue(withIdentifier: "home", sender: self)
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
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return actions.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "ACTIONS"
		case 1:
			return "LOOKUP"
		default:
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return actions[section].count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		cell.textLabel?.text = actions[indexPath.section][indexPath.row].name
		cell.detailTextLabel?.text = nil
		if indexPath.section == 0, indexPath.row == 0 {
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
		performSelector(onMainThread: actions[indexPath.section][indexPath.row].action, with: nil, waitUntilDone: false)
	}
}
