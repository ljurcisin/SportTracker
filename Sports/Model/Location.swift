//
//  Location.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 27/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//


import Foundation
import CoreLocation

// class because protocol
public class Location: NSObject {
	public let name: String?
	public let location: CLLocation
	
	public init(name: String?, location: CLLocation) {
		self.name = name
		self.location = location
	}
}

import MapKit

extension Location: MKAnnotation {
    @objc public var coordinate: CLLocationCoordinate2D {
		return location.coordinate
	}
	
    public var title: String? {
		return name
	}
}
