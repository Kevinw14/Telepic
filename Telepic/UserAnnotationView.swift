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
            if userAnnotation.isCreator {
                clusteringIdentifier = nil
            } else {
                clusteringIdentifier = "be"
            }
            calloutOffset = CGPoint(x: -5, y: 5)
            
            guard let avatarURL = URL(string: userAnnotation.avatarURL) else { return }
            let avatarButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30)))
            if userAnnotation.avatarURL == "n/a" {
                avatarButton.setBackgroundImage(#imageLiteral(resourceName: "avatar-1"), for: .normal)
                let resizedImage = #imageLiteral(resourceName: "avatar-1").resizeImageWith(newSize: CGSize(width: 30, height: 30)).circularImage(size: nil)
                self.image = resizedImage
            }
            
//            let label = UILabel()
//            label.text = userAnnotation.position!
//            label.textAlignment = .center
//            label.textColor = UIColor(hexString: "10BB6C")
//            label.backgroundColor = .white
//            label.frame = CGRect(x: 0, y: 0, width: label.intrinsicContentSize.width + 12, height: label.intrinsicContentSize.width + 12)
//            label.frame.origin.x -= label.frame.width / 2
//            label.frame.origin.y -= label.frame.height / 2
//            label.layer.cornerRadius = label.frame.width / 2
//            label.layer.borderWidth = 2
//            label.clipsToBounds = true
//            label.layer.borderColor = UIColor(hexString: "10BB6C").cgColor
//            self.addSubview(label)
            
//            if userAnnotation.isCreator {
//                let borderView = UIView()
//                borderView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//                borderView.backgroundColor = .clear
//                borderView.layer.borderColor = UIColor(hexString: "10BB6C").cgColor
//                borderView.layer.borderWidth = 2
//                borderView.layer.cornerRadius = borderView.frame.width / 2
//                borderView.clipsToBounds = true
//                self.addSubview(borderView)
//            }
            
            if userAnnotation.isCreator {
                let borderView = UIView()
                borderView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                borderView.backgroundColor = .clear
                borderView.layer.borderColor = UIColor(hexString: "2DAAFC").cgColor
                borderView.layer.borderWidth = 2
                borderView.layer.cornerRadius = borderView.frame.width / 2
                borderView.clipsToBounds = true
                self.addSubview(borderView)
            }
            
            avatarButton.kf.setBackgroundImage(with: avatarURL, for: .normal, placeholder: #imageLiteral(resourceName: "avatar-1"), options: [], progressBlock: nil) { (image, error, cacheType, url) in
                if let image = image {
                    self.rightCalloutAccessoryView = avatarButton
                    let resizedImage = image.resizeImageWith(newSize: CGSize(width: 30, height: 30)).circularImage(size: nil)
                    self.image = resizedImage
                }
                
                if let error = error {
                    print(error.localizedDescription)
                    let resizedImage = UIImage(named: "avatar-1")?.resizeImageWith(newSize: CGSize(width: 30, height: 30)).circularImage(size: nil)
                    self.image = resizedImage
                }
            }
        }
    }
}

