//
//  APIDelegate.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 29/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import Firebase
import FDKeychain
import CoreData
import MapKit

protocol APIDelegate {

    func cloudActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool)
    func localActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool)

    func cloudActivityRemoved(_ removed: ActivityRecordDataModel)
    func localActivityRemoved(_ removed: ActivityRecordDataModel)
}

/**
 APIManager is  class responsible for fetching and creating activity records from local or remote storage
 It is implemented as singleton since it is needed through the whole app lifetime
*/
final class APIManager {

    // MARK: - Public Properties
    var delegate: APIDelegate?


    // MARK: - Private Properties
    private static var sharedInstance: APIManager?
    private var deviceUUID = generateUUID()

    //cloud related properties
    private var rootRef: DatabaseReference?
    private var firebaseApp: FirebaseApp?
    private var dbItemsHandle = DatabaseHandle()

    //core data related properties
    private let managedContext: NSManagedObjectContext!


    // MARK: - Public Properties
    class private func generateUUID() -> String {
        if Thread.current.isRunningXCTest {
            return "TEST"
        }
        else {
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
            fatalError()
        }

        managedContext = appDelegate.persistentContainer.viewContext
        guard managedContext != nil else {
            fatalError()
        }

        rootRef = Database.database().reference().child(deviceUUID)
    }

    /**
     Receiving all activity records from remote storage related to the given unique device uuid.
     Notifies delegate about records successfuly fetched
    */
    func fetchCloudEntries() {
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
                    let type = rawValues[FirebaseKeyword.type] as? Int16,
                    let typeEnum = SportType.init(rawValue: type),
                    let intensity = rawValues[FirebaseKeyword.intensity] as? Double,
                    let locationX = rawValues[FirebaseKeyword.locationX] as? Double,
                    let locationY = rawValues[FirebaseKeyword.locationX] as? Double,
                    let duration = rawValues[FirebaseKeyword.duration] as? Int else {
                        continue
                }

                let newEntry = ActivityRecordDataModel(context: self.managedContext, localSave: false, type: typeEnum, intensity: Float(intensity), locX: locationX, locY: locationY, duration: duration, timestamp: Date(timeIntervalSince1970: (Double(timestamp) ?? 0.0)))
                self.delegate?.cloudActivityAdded(newEntry, fromFetch: true)
            }

        }, withCancel: {(_ error: Error?) -> Void in
            print(error?.localizedDescription ?? "error while trying to fetch cloud entries")
        })
    }

    /**
     Will create activity record data model object and save it on remote db
     Notifies delegate about success via delegate method
    */
    func addCloudEntry(with type: SportType, intensity: Float, locationX: Double, locationY: Double, duration: Int, callback: ((_ result: Bool) -> Void)?) {
        let time = Timer.scheduledTimer(withTimeInterval: timeoutValue, repeats: false, block: {(_ time: Timer) -> Void in
            time.invalidate()
            print("timout while trying to add new cloud entry")
            callback?(false)
        })

        let timestamp = (Int(Date().timeIntervalSince1970))
        guard let root = rootRef else {
            return
        }

        let valuesToUpdate = [String(timestamp): [FirebaseKeyword.type: type.rawValue,
                                                  FirebaseKeyword.intensity: intensity,
                                                  FirebaseKeyword.locationX: locationX,
                                                  FirebaseKeyword.locationY: locationY,
                                                  FirebaseKeyword.duration: duration] as [String : Any] ]

        root.updateChildValues(valuesToUpdate, withCompletionBlock: {(_ error: Error?, _ ref: DatabaseReference) -> Void in
            time.invalidate()
            if error == nil {

                let newEntry = ActivityRecordDataModel(context: self.managedContext, localSave: false, type: type, intensity: intensity, locX: locationX, locY: locationY, duration: duration, timestamp: Date(timeIntervalSince1970: Double(timestamp)))

                self.delegate?.cloudActivityAdded(newEntry, fromFetch: false)
                callback?(true)
            }
        })
    }

    /**
     Will create activit record data model object and save it on the device
     Notifies delegate about success via delegate method
    */
    func addLocalEntry(with type: SportType, intensity: Float, locationX: Double, locationY: Double, duration: Int, callback: ((_ result: Bool) -> Void)?) {
        guard let context = managedContext else {
            fatalError("something's really bad")
        }

        let newEntry = ActivityRecordDataModel(context: managedContext, localSave: true, type: type, intensity: intensity, locX: locationX, locY: locationY, duration: duration)
        do {
            try context.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            callback?(false)
            return
        }

        self.delegate?.localActivityAdded(newEntry, fromFetch: false)
        callback?(true)
    }

    /**
     Loading all activity records from local storage
     Notifies delegate about records successfuly fetched
    */
    func fetchLocalEntries() {
        guard let context = managedContext else {
            fatalError()
        }

        let entriesFetch = ActivityRecordDataModel.fetchEntryRequest()

        do {
            let fetchedEntries = try context.fetch(entriesFetch)
            for entry in fetchedEntries {
                self.delegate?.localActivityAdded(entry, fromFetch: true)
            }

        } catch {
            print("Failed to fetch local entries: \(error)")
        }
    }

    /**
     Deletes given activity record. ActivityRecordDataModel has an informatiou about its type, local or remote.
     Notifies delegate about succes and also calls optional callback method with result
    */
    func delete(entry: ActivityRecordDataModel, callback: ((_ result: Bool) -> Void)? ) {
        if entry.isLocal {
            if let context = managedContext {
                self.delegate?.localActivityRemoved(entry)
                context.delete(entry)
                do {
                    try context.save()
                }
                catch {
                    print(error.localizedDescription)
                    callback?(false)
                    return
                }
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

                self.delegate?.cloudActivityRemoved(entry)
                callback?(true)
            }
        }
    }

    /**
     Needed for cleaning after unit testing
    */
    func deleteAllCloudData() {
        guard let root = rootRef else {
            return
        }

        root.removeValue()
    }
}
