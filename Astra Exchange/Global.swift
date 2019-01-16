import Foundation
import CoreData
import Firebase

var ref: DatabaseReference! = Database.database().reference()
var changeHandler: (() -> Void)?
var startup = true
var id: String?
var name: String?
var email: String?
var balance = 0.0
var users = [User]()
var transactions = [Transaction]()
var invoices = [Invoice]()

struct User {
	let id: String
	let name: String
	let email: String
	
	static func id(_ t: String) -> Int? {
		for i in 0..<users.count {
			if users[i].id == t {
				return i
			}
		}
		return nil
	}
	
	static func name(_ t: String) -> Int? {
		for i in 0..<users.count {
			if users[i].name == t {
				return i
			}
		}
		return nil
	}
	
	static func email(_ t: String) -> Int? {
		for i in 0..<users.count {
			if users[i].email == t {
				return i
			}
		}
		return nil
	}
}

struct Transaction {
	let id: String
	let time: String
	let from: String
	let to: String
	let amount: Double
	let remainingBalance: Double
}

struct Invoice {
	let id: String
	let from: String
	let to: String
	let amount: Double
	let message: String
}

func loadData() {
	ref.child("users/\(id!)/balance").observe(.value) { snapshot in
		balance = Double(snapshot.value as! String)!
		callChangeHandler()
	}
}

func retrieveDataValue(snapshot: DataSnapshot, field: String) -> Any? {
	return (snapshot.value as? [String: AnyObject])?[field]
}

func callChangeHandler() {
	if let changeHandlerUnwrapped = changeHandler {
		changeHandlerUnwrapped()
	}
}

func updateChangeHandler(_ cH: (() -> Void)?) {
	changeHandler = cH
	callChangeHandler()
}

func deleteLogin() {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Login")
	do {
		let login = try managedContext.fetch(fetchRequest)
		if login.count == 1 {
			managedContext.delete(login[0])
			id = nil
			name = nil
			email = nil
		}
	} catch {}
}

func saveLogin(email e: String, password p: String) {
	guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
	let managedContext = appDelegate.persistentContainer.viewContext
	guard let entity = NSEntityDescription.entity(forEntityName: "Login", in: managedContext) else { return }
	let login = NSManagedObject(entity: entity, insertInto: managedContext)
	login.setValue(e, forKeyPath: "email")
	login.setValue(p, forKeyPath: "password")
	do {
		try managedContext.save()
		email = e
	} catch {}
}

extension UIViewController {
	func hideKeyboard() {
		let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc func dismissKeyboard() {
		view.endEditing(true)
	}
	
	func showAlert(_ title: String, _ message: String) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let action = UIAlertAction(title: "OK", style: .default, handler: nil)
		alertController.addAction(action)
		present(alertController, animated: true, completion: nil)
	}
	
	func showAlert(_ message: String) {
		showAlert("Error", message)
	}
}

extension String {
	func trim() -> String {
		return trimmingCharacters(in: .whitespaces)
	}
	
	func checkEmail() -> Bool {
		return NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
	}
}

extension UIView {
	func roundCorners(corners: UIRectCorner, radius: CGFloat) {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		let mask = CAShapeLayer()
		mask.path = path.cgPath
		layer.mask = mask
	}
}
