import UIKit

class CardsViewController: UIViewController {
	@IBOutlet weak var cardView: UIView!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var qrCodeImageView: UIImageView!
	@IBOutlet weak var waitingImageViewWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var waitingLabel: UILabel!
	
	var card: Card?
	var periodTimer: Timer!
	
	override func viewDidLoad() {
        super.viewDidLoad()
		waitingImageViewWidthConstraint.constant = 0
		cardView.layer.borderWidth = 0.5
		cardView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
		nameLabel.text = card?.name
		loadQRCode()
		waitForPayment()
		(parent as? UserViewController)?.navigationController?.setNavigationBarHidden(true, animated: true)
		cardView.transform = CGAffineTransform(translationX: view.bounds.width, y: 0)
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
			self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
			self.cardView.transform = .identity
		}, completion: nil)
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .transaction && transactions[0].from == self.card?.id {
				vibrate()
				self.waitingImageViewWidthConstraint.constant = 28
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseIn, animations: {
					self.view.layoutIfNeeded()
					self.periodTimer.invalidate()
					self.waitingLabel.textColor = #colorLiteral(red: 0.2823529412, green: 0.8, blue: 0.4980392157, alpha: 1)
					self.waitingLabel.text = "Payment sent"
				}) { finished in
					if finished {
						Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
							self.waitingImageViewWidthConstraint.constant = 0
							UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: {
								self.view.layoutIfNeeded()
								self.waitingLabel.textColor = .black
								self.waitForPayment()
							}, completion: nil)
						}
					}
				}
			} else if change == .balance {
				(self.parent as? UserViewController)?.actionsTableView.reloadData()
			}
		}
	}
	
	func waitForPayment() {
		var periods = 0
		periodTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
			self.waitingLabel.text = "Waiting for payment\(repeatElement(".", count: periods).joined())"
			periods = (periods + 1) % 4
		}
	}
	
	func loadQRCode() {
		guard let filter = CIFilter(name: "CIQRCodeGenerator"), let data = card?.id.data(using: .isoLatin1, allowLossyConversion: false) else { return }
		filter.setValue(data, forKey: "inputMessage")
		guard let transform = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 10, y: 10)), let invertFilter = CIFilter(name: "CIColorInvert"), let alphaFilter = CIFilter(name: "CIMaskToAlpha") else { return }
		invertFilter.setValue(transform, forKey: kCIInputImageKey)
		alphaFilter.setValue(invertFilter.outputImage, forKey: kCIInputImageKey)
		guard let outputImage = alphaFilter.outputImage else { return }
		qrCodeImageView.image = UIImage(ciImage: outputImage, scale: 2, orientation: .up).withRenderingMode(.alwaysTemplate)
	}
	
	@IBAction func hideAnimation() {
		UIView.animate(withDuration: 0.2, animations: {
			self.cardView.transform = CGAffineTransform(translationX: self.view.bounds.width, y: 0)
			self.view.backgroundColor = .clear
		}) { finished in
			if finished {
				(self.parent as? UserViewController)?.navigationController?.setNavigationBarHidden(false, animated: true)
				self.view.removeFromSuperview()
			}
		}
	}
}
