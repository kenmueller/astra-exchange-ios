import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var nameTextField: UITextField!
	@IBOutlet weak var nameErrorLabel: UILabel!
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var emailErrorLabel: UILabel!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var passwordErrorLabel: UILabel!
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		hideKeyboard()
		disable()
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
		Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
			if error == nil {
				let userId = authResult!.user.uid
				ref.child("users/\(userId)").setValue(["name": nameText, "email": emailText, "balance": "0"])
				id = userId
				name = nameText
				saveLogin(email: emailText, password: passwordText)
				loadData()
				self.view.removeFromSuperview()
			} else {
				self.showAlert("There was a problem creating a new account")
			}
		}
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
		if !nameText.isEmpty && emailText.checkEmail() && passwordText.count >= 6 {
			enable()
		} else {
			disable()
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		dismissKeyboard()
		return false
	}
}
