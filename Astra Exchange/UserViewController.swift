import UIKit
import CoreData
import Firebase

class UserViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var loadingView: UIView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var offlineView: UIView!
	@IBOutlet weak var actionsTableView: UITableView!
	
	struct Action {
		let name: String
		let action: Selector
	}
	
	let actions = [
		[Action(name: "Send Money", action: #selector(sendMoney)), Action(name: "Create Invoice", action: #selector(createInvoice))],
		[Action(name: "Transaction History", action: #selector(transactionHistory)), Action(name: "Invoices", action: #selector(showInvoices))]
	]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if startup {
			loadingView.isHidden = false
			activityIndicator.startAnimating()
			ref.child("users").observe(.childAdded) { snapshot in
				users.append(User(id: snapshot.key, name: retrieveDataValue(snapshot: snapshot, field: "name") as! String, email: retrieveDataValue(snapshot: snapshot, field: "email") as! String, balance: Double(retrieveDataValue(snapshot: snapshot, field: "balance") as! String)!))
				callChangeHandler(.user)
				ref.child("users/\(snapshot.key)/balance").observe(.value) { balanceSnapshot in
					users[User.id(snapshot.key)!].balance = Double(balanceSnapshot.value as! String)!
					callChangeHandler(.user)
				}
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
									email = localEmail
									loadData()
									self.activityIndicator.stopAnimating()
									self.loadingView.isHidden = true
								}
							} else if let error = error {
								switch error.localizedDescription {
								case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
									self.activityIndicator.stopAnimating()
									self.offlineView.isHidden = false
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
		}
		let signOutBarButtonItem = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut))
		navigationItem.setLeftBarButton(signOutBarButtonItem, animated: true)
		navigationController?.navigationBar.tintColor = .white
		navigationItem.title = name
		navigationItem.setHidesBackButton(true, animated: true)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		actionsTableView.reloadData()
	}
	
	func showHomeVC() {
		performSegue(withIdentifier: "home", sender: self)
	}
	
	@objc func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .default) { action in
			do {
				try Auth.auth().signOut()
				ref.child("users/\(id!)/balance").removeAllObservers()
				ref.child("transactions/\(id!)").removeAllObservers()
				ref.child("invoices/\(id!)").removeAllObservers()
				for invoice in invoices {
					ref.child("invoices/\(id!)/\(invoice.id)/status").removeAllObservers()
				}
				transactions.removeAll()
				invoices.removeAll()
				deleteLogin()
				self.performSegue(withIdentifier: "signOut", sender: self)
			} catch let error {
				self.showAlert(error.localizedDescription)
			}
		}
		alertController.addAction(cancel)
		alertController.addAction(signOut)
		present(alertController, animated: true, completion: nil)
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
	
	@objc func showInvoices() {
		performSegue(withIdentifier: "invoices", sender: self)
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return actions.count + 1
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "BALANCE"
		case 1:
			return "ACTIONS"
		case 2:
			return "LOOKUP"
		default:
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : actions[section - 1].count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "balance", for: indexPath) as! BalanceTableViewCell
			let updateFunction = {
				UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
					cell.balanceLabel.transform = CGAffineTransform(scaleX: 2, y: 2)
					cell.balanceLabel.alpha = 0.4
					cell.balanceLabel.text = String(balance)
				}) { finished in
					if finished {
						UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
							cell.balanceLabel.transform = CGAffineTransform.identity
							cell.balanceLabel.alpha = 1
						}, completion: nil)
					}
				}
			}
			if startup {
				updateChangeHandler { change in
					if change == .balance {
						updateChangeHandler { change in
							if change == .balance {
								updateFunction()
							}
						}
						cell.balanceLabel.text = String(balance)
					}
				}
				startup = false
			} else {
				updateChangeHandler { change in
					if change == .balance {
						updateFunction()
					}
				}
			}
			return cell
		} else {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			cell.textLabel?.font = UIFont(name: "Nunito-SemiBold", size: 18)
			cell.detailTextLabel?.font = UIFont(name: "Nunito-SemiBold", size: 18)
			cell.detailTextLabel?.textColor = .red
			cell.textLabel?.text = actions[indexPath.section - 1][indexPath.row].name
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
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 { return }
		performSelector(onMainThread: actions[indexPath.section - 1][indexPath.row].action, with: nil, waitUntilDone: false)
	}
}

class BalanceTableViewCell: UITableViewCell {
	@IBOutlet weak var balanceLabel: UILabel!
}
