import UIKit
import CoreData
import Firebase

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var settingsTableView: UITableView!
	
	struct Setting {
		let key: String
		let value: String
		let action: Selector?
	}
	
	var settings = [[Setting]]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationItem.setRightBarButton(UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)), animated: true)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .version {
				self.showUpdateVC()
			} else if change == .balance || change == .card || change == .independence {
				self.loadSettings()
				self.settingsTableView.reloadData()
			}
		}
		loadSettings()
	}
	
	@objc func signOut() {
		let alertController = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let signOut = UIAlertAction(title: "Sign Out", style: .default) { action in
			do {
				try Auth.auth().signOut()
				ref.child("users/\(id!)/balance").removeAllObservers()
				ref.child("users/\(id!)/independence").removeAllObservers()
				ref.child("users/\(id!)/cards").removeAllObservers()
				ref.child("transactions/\(id!)").removeAllObservers()
				for card in cards {
					ref.child("transactions/\(card.id)").removeAllObservers()
				}
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
	
	func loadSettings() {
		settings = [[Setting(key: "Name", value: name!, action: nil), Setting(key: "Email", value: email!, action: nil), Setting(key: "Balance", value: String(balance.round2Places()), action: nil)], [Setting(key: "Password", value: showPassword(), action: #selector(resetPassword)), Setting(key: "Independence", value: independence == 0 ? "Pending" : String(independence!), action: nil)], [Setting(key: "Name", value: cards[0].name, action: nil), Setting(key: "Pin", value: cards[0].pin, action: nil)], [Setting(key: "Report a Bug", value: "Tell us more", action: #selector(bugReport))]]
	}
	
	func showPassword() -> String {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return "Error" }
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
		do {
			let login = try managedContext.fetch(fetchRequest)
			guard let password = login[0].value(forKey: "password") as? String else { return "Error" }
			return repeatElement("•", count: password.count).joined()
		} catch {
			return "Error"
		}
	}
	
	@objc func resetPassword() {
		let alertController = UIAlertController(title: "Reset Password", message: "Send a password reset email to \(email!)", preferredStyle: .alert)
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let send = UIAlertAction(title: "Send", style: .default) { action in
			Auth.auth().sendPasswordReset(withEmail: email!) { error in
				if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		}
		alertController.addAction(cancel)
		alertController.addAction(send)
		present(alertController, animated: true, completion: nil)
	}
	
	@objc func bugReport() {
		// show bug report VC
	}
	
	func numberOfSections(in tableView: UITableView) -> Int {
		return settings.count
	}
	
	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case 0:
			return "PUBLIC"
		case 1:
			return "PRIVATE"
		case 2:
			return "CARD"
		default:
			return nil
		}
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 3
		case 1:
			return 2
		case 2:
			return 2
		case 3:
			return 1
		default:
			return 0
		}
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		let element = settings[indexPath.section][indexPath.row]
		cell.textLabel?.text = element.key
		cell.detailTextLabel?.text = element.value
		cell.accessoryType = element.action == nil ? .none : .disclosureIndicator
		if indexPath.section == 3 && indexPath.row == 0 { cell.textLabel?.textColor = #colorLiteral(red: 0.8, green: 0.2, blue: 0.2, alpha: 1) }
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let action = settings[indexPath.section][indexPath.row].action else { return }
		performSelector(onMainThread: action, with: nil, waitUntilDone: false)
	}
}
