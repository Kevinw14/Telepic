//
//  CategoryRowCell.swift
//  Telepic
//
//  Created by Michael Bart on 9/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class CategoryRowCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "playButton")
        button.tintColor = .white
        button.setImage(image, for: .normal)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    var mediaItems = [MediaItem]() {
        didSet {
            updateMediaItems()
        }
    }
    
    var isLocalCategory = false
    
    var updatedItems = [MediaItem]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    weak var delegate: PresentMediaDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "thumbnailCell")
                
    }
    
    func updateMediaItems() {
        var updated = [MediaItem]()
        for mediaItem in mediaItems {
            FirebaseController.shared.fetchUser(uid: mediaItem.creatorID, completion: { (user) in
                var updatedItem = mediaItem
                updatedItem.creatorUsername = user["username"] as! String
                updatedItem.creatorAvatarURL = user["avatarURL"] as? String ?? "n/a"
                updated.append(updatedItem)
                self.updatedItems = updated.sorted { $0.forwards > $1.forwards }
            })
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

extension CategoryRowCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updatedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
        
        let item = updatedItems[indexPath.row]
        
        let urlString = item.type == "video" ?  item.thumbnailURL : item.downloadURL
        
        let url = URL(string: urlString)
        
        cell.thumbnailImageView.kf.setImage(with: url, placeholder: nil, options: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            if item.type == "video" {
                cell.playButton.isHidden = false
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell else { return }
        
        let mediaItem = self.updatedItems[indexPath.row]
        if let imageView = cell.thumbnailImageView {
            FirebaseController.shared.currentMediaItem = mediaItem
            FirebaseController.shared.photoToPresent = imageView
            
            delegate?.presentMediaViewVC()
            NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
        }
    }
}

extension CategoryRowCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = Constant.getItemWidth(boundWidth: collectionView.bounds.size.width)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
}
