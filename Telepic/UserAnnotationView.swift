//
//  UserAnnotationView.swift
//  Telepic
//
//  Created by Michael Bart on 10/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import UIKit
import MapKit
import Kingfisher

class UserAnnotationView: MKAnnotationView {

    override var annotation: MKAnnotation? {
        willSet {
            guard let userAnnotation = newValue as? UserAnnotation else { return }
            canShowCallout = true
            clusteringIdentifier = "be"
            calloutOffset = CGPoint(x: -5, y: 5)
            
            guard let avatarURL = URL(string: userAnnotation.avatarURL) else { return }
            let avatarButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            if userAnnotation.avatarURL == "n/a" {
                avatarButton.setBackgroundImage(#imageLiteral(resourceName: "avatar-1"), for: .normal)
                let resizedImage = #imageLiteral(resourceName: "avatar-1").resizeImageWith(newSize: CGSize(width: 30, height: 30)).circularImage(size: nil)
                self.image = resizedImage
            }
            
            avatarButton.kf.setBackgroundImage(with: avatarURL, for: .normal, placeholder: #imageLiteral(resourceName: "avatar-1"), options: [], progressBlock: nil) { (image, error, cacheType, url) in
                if let image = image {
                    self.rightCalloutAccessoryView = avatarButton
                    let resizedImage = image.resizeImageWith(newSize: CGSize(width: 30, height: 30)).circularImage(size: nil)
                    self.image = resizedImage
                }
            }
        }
    }
}

