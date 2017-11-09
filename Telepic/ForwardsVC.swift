//
//  ForwardsVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/25/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import Kingfisher
import FirebaseAuth

class ForwardsVC: TabChildVC {

    @IBOutlet weak var collectionView: UICollectionView!
    
    let itemsPerRow: CGFloat = 3
    var user: [String:Any]?
    var forwards = [Upload]()
    var image: UIImage?
    
    weak var mediaViewDelegate: MediaViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(getForwards), name: Notifications.didForwardMedia, object: nil)
        
        self.collectionView.register(UINib(nibName: "ThumbnailCell", bundle: nil), forCellWithReuseIdentifier: "thumbnailCell")
        
        getForwards()
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "toMediaViewVC" {
//            guard let mediaViewVC = segue.destination as? MediaViewVC, let image = self.image else { return }
//
//            mediaViewVC.photo = image
//        }
//    }

    @objc func getForwards() {
        if let uid = Auth.auth().currentUser?.uid {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (userDict) in
                self.user = userDict
                
                if let forwardsDict = userDict["forwards"] as? [String:[String:Any]] {
                    var forwards = [Upload]()
                    for (key, value) in forwardsDict {
                        let forward = Upload(uid: key, dict: value)
                        forwards.append(forward)
                    }
                    self.forwards = forwards.sorted { $0.timestamp > $1.timestamp }
                    self.collectionView.reloadData()
                }
            })
        }
    }
}

extension ForwardsVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forwards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as? ThumbnailCell else { return UICollectionViewCell() }
        
        let forward = forwards[indexPath.row]
        let urlString = forward.type == "video" ?  forward.thumbnailURL : forward.downloadURL
        let url = URL(string: urlString)
        
        cell.thumbnailImageView.kf.setImage(with: url)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ThumbnailCell else { return }
        
        if let image = cell.thumbnailImageView.image {
            FirebaseController.shared.fetchMediaItem(forItemID: forwards[indexPath.row].uid, completion: { (item) in
                FirebaseController.shared.currentMediaItem = item
                FirebaseController.shared.photoToPresent = cell.thumbnailImageView
                NotificationCenter.default.post(Notification(name: Notifications.didLoadMediaItem))
            })
        }
    }
}

extension ForwardsVC: UICollectionViewDelegateFlowLayout {
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
