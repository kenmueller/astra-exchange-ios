import UIKit

class HomeViewController: UIViewController {
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		navigationController?.isNavigationBarHidden = true
		signUpButton.layer.borderWidth = 1
		signUpButton.layer.borderColor = UIColor.white.cgColor
    }
}
