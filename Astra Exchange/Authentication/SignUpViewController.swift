import UIKit
import Firebase
import AudioToolbox

class SignUpViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameErrorLabel: UILabel!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailErrorLabel: UILabel!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordErrorLabel: UILabel!
	@IBOutlet weak var signUpButton: UIButton!
	@IBOutlet weak var signUpActivityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboard()
		disable()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .user {
				self.nameTextFieldChanged()
				self.emailTextFieldChanged()
			}
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.isNavigationBarHidden = false
	}
	
	@IBAction func back() {
		navigationController?.popViewController(animated: true)
	}
	
	@IBAction func nameTextFieldChanged() {
		guard let nameText = nameTextField.text?.trim() else { return }
		nameErrorLabel.isHidden = User.name(nameText) == nil
		updateSignUpButton()
	}
	
	@IBAction func emailTextFieldChanged() {
		guard let emailText = emailTextField.text?.trim() else { return }
		if !(emailText.checkEmail() || emailText.isEmpty) {
			emailErrorLabel.isHidden = false
			emailErrorLabel.text = "Invalid email"
		} else if User.email(emailText) != nil {
			emailErrorLabel.isHidden = false
			emailErrorLabel.text = "Email taken"
		} else {
			emailErrorLabel.isHidden = true
		}
		updateSignUpButton()
	}
	
	@IBAction func passwordTextFieldChanged() {
		guard let passwordText = passwordTextField.text?.trim() else { return }
		passwordErrorLabel.isHidden = passwordText.isEmpty || passwordText.count >= 6
		updateSignUpButton()
	}
	
	@IBAction func signUp() {
		guard let nameText = nameTextField.text?.trim(), let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		showActivityIndicator()
		Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
			if error == nil {
				let userId = authResult!.user.uid
				ref.child("users/\(userId)").setValue(["name": nameText, "email": emailText, "balance": "0.0"])
				id = userId
				name = nameText
				saveLogin(email: emailText, password: passwordText)
				loadData()
				self.hideActivityIndicator()
				self.performSegue(withIdentifier: "signUp", sender: self)
			} else if let error = error {
				self.hideActivityIndicator()
				AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
				switch error.localizedDescription {
				case "Network error (such as timeout, interrupted connection or unreachable host) has occurred.":
					self.showAlert("No internet")
				default:
					self.showAlert("There was a problem creating a new account")
				}
			}
		}
	}
	
	func showActivityIndicator() {
		signUpButton.isEnabled = false
		signUpButton.setTitle(nil, for: .normal)
		signUpActivityIndicator.startAnimating()
	}
	
	func hideActivityIndicator() {
		signUpButton.isEnabled = true
		signUpButton.setTitle("SIGN UP", for: .normal)
		signUpActivityIndicator.stopAnimating()
	}
	
	func enable() {
		signUpButton.isEnabled = true
		signUpButton.backgroundColor = .white
	}
	
	func disable() {
		signUpButton.isEnabled = false
		signUpButton.backgroundColor = UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1)
	}
	
	func updateSignUpButton() {
		guard let nameText = nameTextField.text?.trim(), let emailText = emailTextField.text?.trim(), let passwordText = passwordTextField.text?.trim() else { return }
		!nameText.isEmpty && emailText.checkEmail() && passwordText.count >= 6 ? enable() : disable()
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}
