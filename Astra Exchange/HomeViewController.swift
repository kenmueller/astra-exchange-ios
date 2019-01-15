import UIKit

class HomeViewController: UIViewController {
	@IBOutlet weak var signUpButton: UIButton!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		signUpButton.layer.borderWidth = 1
		signUpButton.layer.borderColor = UIColor.white.cgColor
    }
}
