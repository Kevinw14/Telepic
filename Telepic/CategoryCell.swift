//
//  ForwardCell.swift
//  Telepic
//
//  Created by Kevin Wood on 11/12/18.
//  Copyright © 2018 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher

class ForwardCell: UITableViewCell {
    
    private let reuseID = "ThumbnailCell"
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
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: reuseID)
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        let customCollectionViewLayout = CustomCollectionViewLayout()
        customCollectionViewLayout.delegate = self
        customCollectionViewLayout.scrollDirection = .horizontal
        self.collectionView.collectionViewLayout = customCollectionViewLayout
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

extension ForwardCell: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return updatedItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseID, for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
        
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
}

extension ForwardCell: CustomCollectionViewLayoutDelegate {
    
}
