import UIKit

class HomeViewController: UIViewController {
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		signUpButton.layer.borderWidth = 1
		signUpButton.layer.borderColor = UIColor.white.cgColor
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .version {
				self.showUpdateVC()
			}
		}
		navigationController?.isNavigationBarHidden = true
		if startup { observeVersion() }
		startup = false
	}
}
