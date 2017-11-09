//
//  GroupCell.swift
//  Telepic
//
//  Created by Michael Bart on 11/2/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class GroupCell: UITableViewCell {

    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var group: Group?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.isUserInteractionEnabled = false

        //collectionView.delegate = self
        collectionView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpViews() {
        guard let groupName = group?.groupName else { return }
        self.groupNameLabel.text = groupName
    }

}

extension GroupCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let groupMembers = group?.members.count else { return 0 }
        return groupMembers
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "avatarCell", for: indexPath) as? AvatarCell,
            let member = group?.members[indexPath.row] else { return UICollectionViewCell() }
        
        if let url = URL(string: member.avatarURL) {
            cell.avatarImageView.kf.setImage(with: url)
            cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.width / 2
            cell.avatarImageView.clipsToBounds = true
        }
        
        return cell
    }
}
