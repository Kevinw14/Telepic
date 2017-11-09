//
//  UserAnnotation.swift
//  Telepic
//
//  Created by Michael Bart on 10/23/17.
//  Copyright © 2017 Telepic LLC. All rights reserved.
//

import Foundation
import MapKit

class UserAnnotation: NSObject, MKAnnotation {
    let title: String?
    let userID: String
    let coordinate: CLLocationCoordinate2D
    let forwards: Int
    let avatarURL: String
    let timestamp: Double
    
    init(title: String, userID: String, avatarURL: String, coordinate: CLLocationCoordinate2D, forwards: Int, timestamp: Double) {
        self.title = title
        self.userID = userID
        self.avatarURL = avatarURL
        self.coordinate = coordinate
        self.forwards = forwards
        self.timestamp = timestamp
        
        super.init()
    }
    
    var subtitle: String? {
        return "Forwards: \(forwards)"
    }
}
