import UIKit

class RecipientViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
	@IBOutlet weak var recipientView: UIView!
	@IBOutlet weak var titleBar: UIView!
	@IBOutlet weak var selectButton: UIButton!
	@IBOutlet weak var usersPickerView: UIPickerView!
	
	var recipients: [User?] = {
		var usersCopy: [User?] = users
		usersCopy.insert(nil, at: 0)
		return usersCopy.filter { $0?.id != id }
	}()
	var selectedUserId: String?
	
	override func viewDidLoad() {
        super.viewDidLoad()
		titleBar.roundCorners(corners: [.topLeft, .topRight], radius: 10)
		disable()
		recipientView.transform = CGAffineTransform(scaleX: 0, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.recipientView.transform = .identity
		}, completion: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .user {
				var usersCopy: [User?] = users
				usersCopy.insert(nil, at: 0)
				self.recipients = usersCopy.filter { $0?.id != id }
				self.usersPickerView.reloadAllComponents()
			}
		}
	}
	
	@IBAction func select() {
		if let sendMoneyVC = parent as? SendMoneyViewController {
			let recipient = User.id(selectedUserId!)
			sendMoneyVC.recipient = recipient
			sendMoneyVC.actions[sendMoneyVC.actions.count - 2].label = users[recipient!].name
			sendMoneyVC.sendMoneyTableView.reloadData()
			sendMoneyVC.updateSendButton()
		}
		hideAnimation()
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.recipientView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				self.view.removeFromSuperview()
			}
		}
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return recipients.count
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		if let recipientName = recipients[row]?.name {
			return recipientName
		} else {
			return "Select User"
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		selectedUserId = recipients[row]?.id
		if selectedUserId == nil {
			disable()
		} else {
			enable()
		}
	}
	
	func enable() {
		selectButton.isEnabled = true
		selectButton.setTitleColor(.white, for: .normal)
	}
	
	func disable() {
		selectButton.isEnabled = false
		selectButton.setTitleColor(UIColor(red: 229 / 255, green: 229 / 255, blue: 229 / 255, alpha: 1), for: .normal)
	}
}
