//
//  ForwardCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/12/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import GreedoLayout

//protocol ForwardCellDelegate: class {
//    func segueToMediaView(cell: ForwardCell, indexPath: IndexPath)
//}

class ForwardCell: UITableViewCell {
    
    private let reuseID = "ThumbnailCell"
    @IBOutlet weak var collectionView: UICollectionView!
    
    var cellImage: UIImage?
    var fromMediaView = false
    
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
        self.layer.cornerRadius = 15
        self.collectionView.register(UINib(nibName: "ThumbCell", bundle: nil), forCellWithReuseIdentifier: reuseID)
        collectionView.backgroundColor = .white
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        let layout = GreedoCollectionViewLayout(collectionView: collectionView)!
        layout.dataSource = self
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.playButton.isHidden = true
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

extension ForwardCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updatedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as? ThumbCell else { return UICollectionViewCell() }
        
        let item = updatedItems[indexPath.row]
        
        let urlString = item.type == "video" ?  item.thumbnailURL : item.downloadURL
        
        let url = URL(string: urlString)
        
        cell.thumbnailImageView.layer.cornerRadius = 10
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.item % 5 == 0 || indexPath.item % 5 == 1 {
            let height = (collectionView.contentSize.height / 2.07)
            let width = height / 1.5
            
            return CGSize(width: width, height: height)
        } else {
            let height = (collectionView.contentSize.height / 3.19)
            let width = height + 20
            
            return CGSize(width: width, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThumbCell else { return }
        let updatedItem = updatedItems[indexPath.row]
        
        if let image = cell.thumbnailImageView {
            FirebaseController.shared.photoToPresent = image
            FirebaseController.shared.fetchMediaItem(forItemID: updatedItem.itemID, completion: { (item) in
                FirebaseController.shared.currentMediaItem = item
                
                NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
            })
            self.delegate?.presentMediaViewVC()
            self.fromMediaView = true
        }
    }
}


extension ForwardCell: GreedoCollectionViewLayoutDataSource {
    func greedoCollectionViewLayout(_ layout: GreedoCollectionViewLayout!, originalImageSizeAt indexPath: IndexPath!) -> CGSize {
        if indexPath.item % 5 == 0 || indexPath.item % 5 == 1 {
            let height = (collectionView.contentSize.height / 2.07)
            let width = height / 1.5
            
            return CGSize(width: width, height: height)
        } else {
            let height = (collectionView.contentSize.height / 3.19)
            let width = height + 20
            
            return CGSize(width: width, height: height)
        }
    }
}
