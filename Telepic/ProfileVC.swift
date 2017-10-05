//
//  ProfileVC.swift
//  Telepic
//
//  Created by Michael Bart on 9/22/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var numberOfFriendsLabel: UILabel!
    @IBOutlet weak var milesTraveledLabel: UILabel!
    @IBOutlet weak var forwardsLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var thumbnails = [InboxItem]()
    let item1 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item2 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item3 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item4 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item5 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item6 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item7 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item8 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item9 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item10 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item11 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item12 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item13 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item14 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item15 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    let item16 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "michaelbart", senderAvatar: #imageLiteral(resourceName: "avatar"), creator: "stephaniejoyce", creatorAvatar: #imageLiteral(resourceName: "avatar2"), daysRemaining: 2, commentsRef: "22j9jfs", mapRef: "j24j209jf")
    let item17 = InboxItem(photo: #imageLiteral(resourceName: "photo2"), sender: "stephaniejoyce", senderAvatar: #imageLiteral(resourceName: "avatar2"), creator: "michaelbart", creatorAvatar: #imageLiteral(resourceName: "avatar"), daysRemaining: 3, commentsRef: "j3oij2f", mapRef: "jfo23j209f")
    let item18 = InboxItem(photo: #imageLiteral(resourceName: "photo1"), sender: "stevejobs", senderAvatar: #imageLiteral(resourceName: "avatar3"), creator: "donaldtrump", creatorAvatar: #imageLiteral(resourceName: "avatar4"), daysRemaining: 4, commentsRef: "jfiajfelei", mapRef: "jofij293")
    
    let itemsPerRow: CGFloat = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()

        thumbnails = [item1,item2,item3,item4,item5,item6,item7,item8,item9,item10,item11,item12,item13,item14,item15,item16,item17,item18]
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "thumbnailCell")
        
        collectionView.reloadData()
        
        avatarImageView.image = #imageLiteral(resourceName: "avatar")
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
    
    @IBAction func settingsButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func groupButtonTapped(_ sender: Any) {
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}

extension ProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thumbnails.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
        
        cell.thumbnailImageView.image = thumbnails[indexPath.row].photo
        
        return cell
    }
}

extension ProfileVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace: CGFloat = 2.0
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
