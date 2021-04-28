//
//  ActivityRecordDataModel.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 01/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData

/**
 ActivityRecordDataModel is data model of activity record
 It is core data entity, so it can be directly serialized and stored localy
*/
class ActivityRecordDataModel: NSManagedObject {

    // MARK: - Public Properties
    // serialized properties
    @NSManaged var type: SportType
    @NSManaged var intensity: Float
    @NSManaged var locationX: Double
    @NSManaged var locationY: Double
    @NSManaged var duration: Int32
    @NSManaged var timestamp: Date

    // cached temporary properties
    var isLocal = false
    var isActive = false
    lazy var coordinates: CLLocationCoordinate2D = {
        return CLLocationCoordinate2D(latitude: locationX, longitude: locationY)
    }()

    // MARK: - Public Methods
    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        isLocal = context != nil
    }

    convenience init(context: NSManagedObjectContext, localSave: Bool, type: SportType, intensity: Float, locX: Double, locY: Double, duration: Int, timestamp: Date = Date()) {
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: ActivityRecordDataModelEntityName, in: context)

        if(!localSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }

        // Init class variables
        self.type = type
        self.intensity = intensity
        self.locationX = locX
        self.locationY = locY
        self.duration = Int32(duration)
        self.timestamp = timestamp
    }

    class func fetchEntryRequest() -> NSFetchRequest<ActivityRecordDataModel> {
        return NSFetchRequest<ActivityRecordDataModel>(entityName: ActivityRecordDataModelEntityName)
    }
}
