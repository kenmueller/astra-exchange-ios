import UIKit
import Firebase
import AudioToolbox

class SignInViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signInButton: UIButton!
	@IBOutlet weak var signInActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboard()
		disable()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isNavigationBarHidden = false
	}
	
	@IBAction func textFieldChanged() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!(emailText.isEmpty || passwordText.isEmpty) ? enable() : disable()
	}
	
	@IBAction func signIn() {
		guard let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		Auth.auth().signIn(withEmail: emailText, password: passwordText) { user, error in
			if error == nil {
				id = user?.user.uid
				ref.child("users/\(id!)/name").observeSingleEvent(of: .value) { snapshot in
					name = snapshot.value as? String
				}
				email = emailText
				saveLogin(email: emailText, password: passwordText)
				loadData()
				self.hideActivityIndicator()
				self.view.removeFromSuperview()
			} else if let error = error {
				self.hideActivityIndicator()
				AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
				switch error.localizedDescription {
				case "FIRAuthErrorCodeNetworkError":
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
		signInButton.backgroundColor = .white
	}
	
	func disable() {
		signInButton.isEnabled = false
		signInButton.backgroundColor = UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1)
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}
