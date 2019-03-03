import UIKit

class LeaderboardViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	@IBOutlet weak var leaderboardCollectionView: UICollectionView!
	
	var sortedUsers = [User]()
	
	override func viewDidLoad() {
        super.viewDidLoad()
		let layout = UICollectionViewFlowLayout()
		layout.itemSize = CGSize(width: view.bounds.width - 40, height: 100)
		layout.minimumLineSpacing = 8
		layout.sectionInset = UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
		leaderboardCollectionView.collectionViewLayout = layout
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		updateChangeHandler { change in
			if change == .user {
				self.sortedUsers = self.sortUsersByBalance()
				self.leaderboardCollectionView.reloadData()
			}
		}
		sortedUsers = sortUsersByBalance()
	}
	
	func sortUsersByBalance() -> [User] {
		return users.sorted { return $0.balance > $1.balance }
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return sortedUsers.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! LeaderboardCollectionViewCell
		let element = sortedUsers[indexPath.row]
		cell.rankLabel.text = "#\(indexPath.row + 1)"
		cell.nameLabel.text = element.name
		cell.balanceLabel.text = String(element.balance.round2Places())
		if element.id == id {
			cell.backgroundColor = .lightGray
			cell.layer.borderWidth = 0.5
			cell.layer.borderColor = UIColor.darkGray.cgColor
			cell.rankLabel.textColor = .darkGray
			cell.nameLabel.textColor = .darkGray
			cell.balanceLabel.textColor = .darkGray
		}
		return cell
	}
}

class LeaderboardCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var rankLabel: UILabel!
	@IBOutlet weak var nameLabel: UILabel!
	@IBOutlet weak var balanceLabel: UILabel!
}