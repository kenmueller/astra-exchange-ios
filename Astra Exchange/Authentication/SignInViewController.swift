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
		updateChangeHandler(nil)
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
				ref.child("users/\(id!)/name").observeSingleEvent(of: .value) { snapshot in
					name = snapshot.value as? String
					saveLogin(email: emailText, password: passwordText)
					loadData()
					self.hideActivityIndicator()
					self.performSegue(withIdentifier: "signIn", sender: self)
				}
			} else if let error = error {
				self.hideActivityIndicator()
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("Invalid email/password")
				}
			}
		}
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
