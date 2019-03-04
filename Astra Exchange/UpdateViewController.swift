import UIKit

class UpdateViewController: UIViewController {
	@IBOutlet weak var updateView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var versionLabel: UILabel!
	@IBOutlet weak var changesTextView: UITextView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		ref.child("version").observeSingleEvent(of: .value) { snapshot in
			self.versionLabel.text = retrieveDataValue(snapshot: snapshot, field: "number") as? String
			self.changesTextView.text = retrieveDataValue(snapshot: snapshot, field: "changes") as? String
		}
		updateView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.updateView.transform = .identity
		}, completion: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .version {
				self.viewDidLoad()
			}
		}
	}
	
	@IBAction func update() {
		if let url = URL(string: "https://astra.exchange") {
			UIApplication.shared.open(url)
		} else {
			showAlert("There was a problem visiting astra.exchange. Please try again.")
		}
	}
}
