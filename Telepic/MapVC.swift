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

    @IBOutlet weak var mapView: MKMapView!
    var mediaItem: MediaItem?
    var annotations = [UserAnnotation]()
    
    @IBOutlet weak var forwardsLabel: UILabel!
    @IBOutlet weak var creatorUsernameLabel: UILabel!
    @IBOutlet weak var milesTraveledLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        mapView.register(UserAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        
        setUpViews()
        createAnnotations()
        mapView.addAnnotations(annotations)
        calculateMilesTraveled()
    }
    
    @IBAction func creatorTapped(_ sender: Any) {
        segueToProfileVC()
    }
    
    func segueToProfileVC() {
        guard let mediaItem = mediaItem else { return }
        let creatorID = mediaItem.creatorID
        let profileVC = UIStoryboard(name: "Profile", bundle: nil).instantiateInitialViewController() as! ProfileVC
        DispatchQueue.main.async {
            FirebaseController.shared.fetchUser(uid: creatorID, completion: { (user) in
                profileVC.user = user
                profileVC.userID = creatorID
                NotificationCenter.default.post(Notification(name: Notifications.didLoadUser))
            })
        }
        
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func setUpViews() {
        guard let mediaItem = mediaItem else { return }
        forwardsLabel.text = "\(mediaItem.forwards)"
        creatorUsernameLabel.text = "\(mediaItem.creatorUsername)"
    }
    
    func calculateMilesTraveled() {
        let locations = annotations.map { CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude) }
        var previousLocation: CLLocation?
        var distance = 0.0
        for location in locations {
            if let previousLocation = previousLocation {
                distance += location.distance(from: previousLocation)
            }
            previousLocation = location
        }
        let milesTraveled = distance * 0.000621371
        milesTraveledLabel.text = String(format: "%.1f", milesTraveled)
    }
    
    func createAnnotations() {
        guard let mapRef = mediaItem?.mapReference else { return }
        for (key, value) in mapRef {
            let userID = key
            guard let lat = value["latitude"] as? Double,
                let long = value["longitude"] as? Double,
                let avatarURL = value["avatarURL"] as? String,
                let username = value["username"] as? String,
                let timestamp = value["timestamp"] as? Double else {
                print("Error retrieving values for MapRef.")
                return
            }
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            let userAnnotation = UserAnnotation(title: username, userID: userID, avatarURL: avatarURL, coordinate: coordinate, forwards: 0, timestamp: timestamp)
            self.annotations.append(userAnnotation)
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToMapVC(segue: UIStoryboardSegue) { }
    @IBAction func unwindToMapVCFromSendVC(segue: UIStoryboardSegue) { }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "toSendVC" {
            guard let sendVC = segue.destination as? SendVC else { return }
            sendVC.isFromMapVC = true
        }
        
        if segue.identifier == "toCommentsVC" {
            guard let commentsVC = segue.destination as? CommentsVC else { return }
            commentsVC.mediaItemID = self.mediaItem?.itemID
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
        
        
    }
}
