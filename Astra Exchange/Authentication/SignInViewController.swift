import UIKit
import Firebase
import AudioToolbox

class SignInViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var signInButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		disable()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .version {
				self.showUpdateVC()
			}
		}
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isNavigationBarHidden = false
	}
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	@objc func keyboardWillShow(notification: NSNotification) {
		if let height = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height {
			signInButtonBottomConstraint.constant = height
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: nil)
		}
	}
	
	@objc func keyboardWillHide(notification: NSNotification) {
		signInButtonBottomConstraint.constant = 145
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveLinear, animations: {
			self.view.layoutIfNeeded()
		}, completion: nil)
	}
	
	@IBAction func textFieldChanged() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!(emailText.isEmpty || passwordText.isEmpty) ? enable() : disable()
	}
	
	@IBAction func signIn() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		dismissKeyboard()
		Auth.auth().signIn(withEmail: emailText, password: passwordText) { user, error in
			if error == nil {
				id = user?.user.uid
				ref.child("users/\(id!)").observeSingleEvent(of: .value) { snapshot in
					name = retrieveDataValue(snapshot: snapshot, field: "name") as? String
					saveLogin(email: emailText, password: passwordText)
					independence = retrieveDataValue(snapshot: snapshot, field: "independence") as? Int
					loadData()
					self.hideActivityIndicator()
					self.performSegue(withIdentifier: "signIn", sender: self)
				}
			} else if let error = error {
				self.hideActivityIndicator()
				self.handleError(error, default: "Invalid email/password")
			}
		}
	}
	
	@IBAction func forgotPassword() {
		let alertController = UIAlertController(title: "Forgot Password", message: "Send a password reset email", preferredStyle: .alert)
		alertController.addTextField { textField in
			textField.placeholder = "Email"
			textField.keyboardType = .emailAddress
			textField.text = self.emailTextField.text?.trim()
		}
		let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
		let send = UIAlertAction(title: "Send", style: .default) { action in
			guard let text = alertController.textFields?[0].text?.trim() else { return }
			Auth.auth().sendPasswordReset(withEmail: text) { error in
				if let error = error {
					self.showAlert(error.localizedDescription)
				}
			}
		}
		alertController.addAction(cancel)
		alertController.addAction(send)
		present(alertController, animated: true, completion: nil)
	}
	
	func showActivityIndicator() {
		signInButton.isEnabled = false
		signInButton.setTitle(nil, for: .normal)
		signInActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		signInButton.isEnabled = true
		signInButton.setTitle("SIGN UP", for: .normal)
		signInActivityIndicator.stopAnimating()
	}
	
	func enable() {
		signInButton.isEnabled = true
		signInButton.setTitleColor(UIColor(red: 72 / 255, green: 204 / 255, blue: 127 / 255, alpha: 1), for: .normal)
		signInButton.backgroundColor = .white
	}
	
	func disable() {
		signInButton.isEnabled = false
		signInButton.setTitleColor(UIColor(red: 240 / 255, green: 240 / 255, blue: 240 / 255, alpha: 1), for: .normal)
		signInButton.backgroundColor = UIColor(red: 220 / 255, green: 220 / 255, blue: 220 / 255, alpha: 1)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}
