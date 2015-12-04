//
//  MapPin.swift
//  Connect
//
//  Created by Abiel Gutierrez on 12/4/15.
//  Copyright © 2015 Abiel Gutierrez. All rights reserved.
//  I referenced http://stackoverflow.com/questions/24233873/mkannotation-swift when creating this class

import Foundation
import MapKit

class MapPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
}