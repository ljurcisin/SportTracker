//
//  DbManager.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 29/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import Firebase
import FDKeychain
import CoreData
import GoogleMaps
import GooglePlaces

protocol DbManagerDelegate {

    func cloudEntryAdded(_ newEntry: ActivityRecordDataModel)
    func localEntryAdded(_ newEntry: ActivityRecordDataModel)
}

final class APIManager {

    //public
    var delegate: DbManagerDelegate?
    var cloudEntries = [ActivityRecordDataModel]() {
        willSet {
            allEntries = allEntries.filter { !cloudEntries.contains($0) }
        }
        didSet {
            allEntries.append(contentsOf: cloudEntries)
            allEntries.sort { (item1, item2) -> Bool in
                return item1.timestamp < item2.timestamp
            }
            cloudEntries.sort { (item1, item2) -> Bool in
                return item1.timestamp < item2.timestamp
            }
        }
    }
    var localEntries = [ActivityRecordDataModel]() {
        willSet {
            allEntries = allEntries.filter { !localEntries.contains($0) }
        }
        didSet {
            allEntries.append(contentsOf: localEntries)
            allEntries.sort { (item1, item2) -> Bool in
                return item1.timestamp < item2.timestamp
            }
            localEntries.sort { (item1, item2) -> Bool in
                return item1.timestamp < item2.timestamp
            }
        }
    }
    var allEntries = [ActivityRecordDataModel]() {
        willSet {
            assert(true, "should not be called!")
        }
    }

    //private
    private static var sharedInstance: APIManager?
    private var deviceUUID = generateUUID()

    //cloud related members
    private var rootRef: DatabaseReference?
    private var firebaseApp: FirebaseApp?
    private var dbItemsHandle = DatabaseHandle()

    //core data related
    private let managedContext: NSManagedObjectContext!


    //methods
    class private func generateUUID() -> String {
        var CFUUID: String?
        if !(((try? FDKeychain.item(forKey: KeychainItem_UUID, forService: KeychainItem_Service)) != nil)) {
            let UUID: CFUUID = CFUUIDCreate(kCFAllocatorDefault)
            CFUUID = CFUUIDCreateString(kCFAllocatorDefault, UUID) as String?
            do {
                try FDKeychain.saveItem(CFUUID! as NSCoding?, forKey: KeychainItem_UUID, forService: KeychainItem_Service)
            }
            catch {
                print(error.localizedDescription)
            }
        } else {
            CFUUID = try? FDKeychain.item(forKey: KeychainItem_UUID, forService: KeychainItem_Service) as? String
        }
        return CFUUID ?? ""
    }

    //static singleton getter
    class func get() -> APIManager {

        guard let instance = sharedInstance else {
            sharedInstance = APIManager()
            return sharedInstance!
        }

        return instance
    }

    init() {

        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          fatalError("no appDelegate")
        }

        managedContext = appDelegate.persistentContainer.viewContext
        guard managedContext != nil else {
            fatalError("can not continue without managed context")
        }

        rootRef = Database.database().reference().child(deviceUUID)
        loadCloudEntries()
        loadLocalEntries()
    }

    func loadCloudEntries()
    {

        let time = Timer.scheduledTimer(withTimeInterval: timeoutValue, repeats: false, block: {(_ time: Timer) -> Void in
            time.invalidate()
            print("load db entries timeout")
        })

        guard let root = rootRef else {
            return
        }

        root.observeSingleEvent(of: .value, with: {(_ snapshot: DataSnapshot) -> Void in
            if !time.isValid {
                return
            }

            time.invalidate()
            guard let dic = snapshot.value as? [String: [String: Any]] else {
                return
            }

            let timestamps = dic.keys
            for timestamp: String in timestamps {

                guard !timestamp.isEmpty,
                    let rawValues = dic[timestamp],
                    let name = rawValues[FirebaseKeyword.name] as? String,
                    let location = rawValues[FirebaseKeyword.location] as? String,
                    let locationID = rawValues[FirebaseKeyword.locationID] as? String,
                    let duration = rawValues[FirebaseKeyword.duration] as? Int else {
                        continue
                }

                let newEntry = ActivityRecordDataModel(context: self.managedContext, localSave: false, name: name, place: location, placeID: locationID, duration: duration, timestamp: Date(timeIntervalSince1970: (Double(timestamp) ?? 0.0)))
                self.cloudEntries.append(newEntry)
            }

        }, withCancel: {(_ error: Error?) -> Void in
            print(error?.localizedDescription ?? "error while trying to fetch cloud entries")
        })
    }

    func addCloudEntry(with name: String, location: String, locationID: String, duration: Int, callback: ((_ result: Bool) -> Void)?)
    {
        let time = Timer.scheduledTimer(withTimeInterval: timeoutValue, repeats: false, block: {(_ time: Timer) -> Void in
            time.invalidate()
            print("timout while trying to add new cloud entry")
            callback?(false)
        })

        let timestamp = (Int(Date().timeIntervalSince1970))
        guard let root = rootRef else {
            return
        }

        let valuesToUpdate = [String(timestamp): [FirebaseKeyword.name: name,
                                                  FirebaseKeyword.location: location,
                                                  FirebaseKeyword.locationID: locationID,
                                                  FirebaseKeyword.duration: duration] as [String : Any] ]

        root.updateChildValues(valuesToUpdate, withCompletionBlock: {(_ error: Error?, _ ref: DatabaseReference) -> Void in
            time.invalidate()
            if error == nil {

                let newEntry = ActivityRecordDataModel(context: self.managedContext, localSave: false, name: name, place: location, placeID: locationID, duration: duration, timestamp: Date(timeIntervalSince1970: Double(timestamp)))

                self.cloudEntries.append(newEntry)
                self.delegate?.cloudEntryAdded(newEntry)
                callback?(true)
            }
        })
    }

    func addLocalEntry(with name: String, location: String, locationID: String, duration: Int, callback: ((_ result: Bool) -> Void)?)
    {
        guard let context = managedContext else {
            fatalError("something's really bad")
        }

        let newEntry = ActivityRecordDataModel(context: managedContext, localSave: true, name: name, place: location, placeID: locationID, duration: duration)
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            callback?(false)
            return
        }

        self.localEntries.append(newEntry)
        self.delegate?.localEntryAdded(newEntry)
        callback?(true)
    }

    func loadLocalEntries()
    {
        guard let context = managedContext else {
            fatalError("something's really bad")
        }

        let entriesFetch = ActivityRecordDataModel.fetchEntryRequest()

        do {
            let fetchedEntries = try context.fetch(entriesFetch)

            self.localEntries = fetchedEntries

        } catch {
            print("Failed to fetch local entries: \(error)")
        }
    }

    func getEntry(for index: Int, database: DBSetting) -> ActivityRecordDataModel? {
        if database == .local, index < localEntries.count {
            return localEntries[index]
        }
        else if database == .remote, index < cloudEntries.count {
            return cloudEntries[index]
        }
        else if index < allEntries.count {
            return allEntries[index]
        }

        return nil
    }

    func getCoordinates(for entry: ActivityRecordDataModel, callback: ((_ coordinates: CLLocationCoordinate2D?) -> Void)? ) {

        if let coords = entry.cachedCoordinates {
            callback?(coords)
        }
        else {
            // Specify the place data types to return.
            let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.coordinate.rawValue) |
              UInt(GMSPlaceField.placeID.rawValue))!

            GMSPlacesClient.shared().fetchPlace(fromPlaceID: entry.locationID, placeFields: fields, sessionToken: nil, callback: {
              (place: GMSPlace?, error: Error?) in
                if let error = error {
                    print("An error occurred: \(error.localizedDescription)")
                    callback?(nil)
                }

                guard let recordPlace = place else {
                    return
                }

                entry.cachedCoordinates = recordPlace.coordinate
                callback?(recordPlace.coordinate)
            })
        }
    }

    private func getIndex(of entry: ActivityRecordDataModel) -> Int? {
        if entry.isLocal {
            return localEntries.firstIndex(of: entry)
        }
        else {
            return cloudEntries.firstIndex(of: entry)
        }
    }

    func getIndex(of entry: ActivityRecordDataModel, indexInAll: inout Int?) -> Int? {

        indexInAll = allEntries.firstIndex(of: entry)
        return getIndex(of: entry)
    }

    func getIndex(of entry: ActivityRecordDataModel, in DbSetting: DBSetting) -> Int? {

        switch DbSetting {
        case .all:
            return allEntries.firstIndex(of: entry)
        case .local:
            return localEntries.firstIndex(of: entry)
        case .remote:
            return cloudEntries.firstIndex(of: entry)
        }
    }

    func delete(entry: ActivityRecordDataModel, callback: ((_ result: Bool) -> Void)? ) {
        if entry.isLocal {
            if let index = getIndex(of: entry),
                let context = managedContext {
                context.delete(entry)
                do {
                    try context.save()
                }
                catch {
                    print(error.localizedDescription)
                    callback?(false)
                    return
                }
                localEntries.remove(at: index)
                callback?(true)
            }
            else {
                callback?(false)
            }
        }
        else {
            let time = Timer.scheduledTimer(withTimeInterval: timeoutValue, repeats: false, block: {(_ time: Timer) -> Void in
                time.invalidate()
                print("timout while trying to delete cloud entry")
                callback?(false)
            })

            let timestamp = (Int(entry.timestamp.timeIntervalSince1970))
            guard let root = rootRef else {
                return
            }

            let reference = root.child(String(timestamp))
            reference.removeValue { error, _ in
                time.invalidate()
                if let error = error {
                    print(error.localizedDescription)
                    callback?(false)
                    return
                }
                if let index = self.getIndex(of: entry) {
                    self.cloudEntries.remove(at: index)
                }
                callback?(true)
            }
        }
    }
}
