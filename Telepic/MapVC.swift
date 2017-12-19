//
//  MapVC.swift
//  Telepic
//
//  Created by Michael Bart on 10/5/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var mediaItem: MediaItem? {
        didSet {
            if isViewLoaded {
                setUp()
            }
        }
    }
    var annotations = [UserAnnotation]() {
        didSet {
            mapView.addAnnotations(annotations)
        }
    }
    
    @IBOutlet weak var forwardsLabel: UILabel!
    @IBOutlet weak var creatorUsernameLabel: UILabel!
    @IBOutlet weak var milesTraveledLabel: UILabel!
    @IBOutlet weak var numberOfCommentsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(UserAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        
        //        let sortedAnnotations = annotations.sorted { $0.timestamp < $1.timestamp }
        //        var numberedAnnotations = [MKAnnotation]()
        //        for (index, value) in sortedAnnotations.enumerated() {
        //            value.position = "\(index + 1)"
        //            numberedAnnotations.append(value)
        //        }
        //        mapView.addAnnotations(numberedAnnotations)
        setUp()
    }
    
    func setUp() {
        setUpViews()
        createAnnotations()
        calculateMilesTraveled()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isHidden = true
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func creatorTapped(_ sender: Any) {
        guard let mediaItem = mediaItem else { return }
        segueToProfileVC(uid: mediaItem.creatorID, username: mediaItem.creatorUsername)
    }
    
    @IBAction func commentsTapped(_ sender: Any) {
        guard let mediaItem = mediaItem else { return }
        let commentsVC = UIStoryboard(name: "Comments", bundle: nil).instantiateViewController(withIdentifier: Identifiers.commentsVC) as! CommentsVC
        commentsVC.mediaItemID = mediaItem.itemID
        self.navigationController?.pushViewController(commentsVC, animated: true)
    }
    
    @IBAction func forwardsTapped(_ sender: Any) {
        let forwardListVC = UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: Identifiers.forwardListVC) as! ForwardListVC
        guard let forwardList = mediaItem?.forwardList else { return }
        forwardListVC.users = forwardList.map({ (key, value) in
            return Forwarder(uid: key, dict: value)
        })
        self.navigationController?.pushViewController(forwardListVC, animated: true)
    }
    
    func segueToProfileVC(uid: String, username: String) {
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: Identifiers.profileVC) as! ProfileVC
        profileVC.isCurrentUser = false
        profileVC.username = username
        profileVC.userID = uid
        
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: uid, completion: { (user) in
                profileVC.user = user
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func setUpViews() {

        guard let mediaItem = mediaItem else { return }
        FirebaseController.shared.fetchComments(forMediaItemID: mediaItem.itemID, completion: { (comments) in
            self.numberOfCommentsLabel.isHidden = false
            self.numberOfCommentsLabel.text = "\(comments.count)"
        })
        
        forwardsLabel.text = "\(mediaItem.forwards)"
        creatorUsernameLabel.text = "\(mediaItem.creatorUsername)"
        milesTraveledLabel.text = String(format: "%.1f", mediaItem.milesTraveled)
    }
    
    func calculateMilesTraveled() {
//        let locations = annotations.map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
//        var previousLocation: CLLocation?
//        var distance = 0.0
//        for location in locations {
//            if let previousLocation = previousLocation {
//                distance += location.distance(from: previousLocation)
//            }
//            previousLocation = location
//        }
//        let milesTraveled = distance * 0.000621371
//
//        milesTraveledLabel.text = String(format: "%.1f", milesTraveled)
    }
    
    func createAnnotations() {
        guard let mapRef = mediaItem?.mapReference else { return }
        for (key, value) in mapRef {
            let userID = key
            FirebaseController.shared.fetchUser(uid: userID, completion: { (user) in
                
                guard let lat = value["latitude"] as? Double,
                    let long = value["longitude"] as? Double,
                    let username = user["username"] as? String,
                    let timestamp = value["timestamp"] as? Double else {
                        print("Error retrieving values for MapRef.")
                        return
                }
                
                var forwards = 0
                if let forwardList = self.mediaItem?.forwardList {
                    if let userForwards = forwardList[userID] {
                        if let count = userForwards["count"] as? Int {
                            forwards = count
                        }
                    }
                }
                let avatarURL = user["avatarURL"] as? String ?? "n/a"
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let userAnnotation = UserAnnotation(title: username, userID: userID, avatarURL: avatarURL, coordinate: coordinate, forwards: forwards, timestamp: timestamp)
                
                if userID == self.mediaItem?.creatorID { userAnnotation.isCreator = true }
                self.annotations.append(userAnnotation)
            })
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.navigationBar.isHidden = false
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func unwindToMapVC(segue: UIStoryboardSegue) { }
    @IBAction func unwindToMapVCFromSendVC(segue: UIStoryboardSegue) { }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSendVC" {
            guard let sendVC = segue.destination as? SendVC, let mediaItem = mediaItem else { return }
            sendVC.isForwardingItem = true
            sendVC.mediaItemBeingSent = mediaItem
        }
    }

}

extension MapVC: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, clusterAnnotationForMemberAnnotations memberAnnotations: [MKAnnotation]) -> MKClusterAnnotation {
        let cluster = MKClusterAnnotation(memberAnnotations: memberAnnotations)
        
        cluster.title = "Users"
        return cluster
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let userAnnotation = view as! UserAnnotationView
        guard let user = userAnnotation.annotation as? UserAnnotation else { return }
        
        let uid = user.userID
        segueToProfileVC(uid: uid, username: "")
    }
}
