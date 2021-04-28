//
//  Constants.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 31/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import CoreLocation

//constatns
let timeoutValue: TimeInterval = 5
let KeychainItem_Service = "FDKeychain"
let KeychainItem_UUID = "Local"
let ActivityRecordsTableViewCellID = "ActivityRecordsTableViewCell"
let bratislavaCoordinates = CLLocationCoordinate2D(latitude: 48.1415887, longitude: 17.100087)
let ActivityRecordDataModelEntityName = "ActivityRecordDataModel"

enum FirebaseKeyword {
    static let type = "type"
    static let intensity = "intensity"
    static let locationX = "locationX"
    static let locationY = "locationY"
    static let duration = "duration"
}

enum DBSetting: Int {
    case local
    case remote
    case all
}

@objc enum SportType: Int16 {
    case run
    case weight
    case cardio
    case swim
    case bike
    case football
}
