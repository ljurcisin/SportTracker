//
//  AcivityRecordsTableModel.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 03/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import CoreLocation

/**
 ActivityRecordsTableModel is view model class responsible for all logic behind table view controller showing all existing records
 It is also APIManager delegate object and listen for all new or removed records, keeps them and reloads the history table
*/
final class ActivityRecordsTableModel: NSObject {

    // MARK: - Public Properties
    let cloudEntries = ObservableSortedArray<[ActivityRecordDataModel]> ([], sortRule: { (value1, value2) -> Bool in
        if let value1 = value1 as? ActivityRecordDataModel,
            let value2 = value2 as? ActivityRecordDataModel {
            return value1.timestamp > value2.timestamp
        }

        //shoudnt ever happend
        return true
    })

    let localEntries = ObservableSortedArray<[ActivityRecordDataModel]> ([], sortRule: { (value1, value2) -> Bool in
        if let value1 = value1 as? ActivityRecordDataModel,
            let value2 = value2 as? ActivityRecordDataModel {
            return value1.timestamp > value2.timestamp
        }

        //shoudnt ever happend
        return true
    })

    var allEntries = [ActivityRecordDataModel]() {
        didSet {
            allEntries.sort { (item1, item2) -> Bool in
                return item1.timestamp > item2.timestamp
            }
        }
    }

    let selectedEntry = ObservableOptional<ActivityRecordDataModel> (nil)
    let locationCoorinates = ObservableOptional<CLLocationCoordinate2D> (nil)

    // MARK: - Public Methods
    override init() {
        super.init()

        APIManager.get().delegate = self
        APIManager.get().fetchCloudEntries()
        APIManager.get().fetchLocalEntries()
    }

    func getEntry(for index: Int, database: DBSetting) -> ActivityRecordDataModel? {
        if database == .local, index < localEntries.value.count {
            return localEntries.value[index]
        }
        else if database == .remote, index < cloudEntries.value.count {
            return cloudEntries.value[index]
        }
        else if index < allEntries.count {
            return allEntries[index]
        }

        return nil

    }

    func getIndex(of entry: ActivityRecordDataModel) -> Int? {
        return allEntries.firstIndex(of: entry)
    }

    func getCellCount() -> Int {
        return getCellCount(for: .all)
    }

    func getCellCount(for dbSetting: DBSetting) ->Int {
        if dbSetting == .local {
            return localEntries.value.count
        }
        else if dbSetting == .remote {
            return cloudEntries.value.count
        }
        else {
            return  allEntries.count
        }
    }
    
    // MARK: - Private Methods
    private func setLocation(on index: IndexPath?) {
        if let index = index, let entry = getEntry(for: index.row, database: .all) {
            self.locationCoorinates.value = entry.coordinates
        }
        else {
            locationCoorinates.value = nil
        }
    }
}

// MARK: - API Delegate methods
extension ActivityRecordsTableModel: APIDelegate {

    func cloudActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool) {
        allEntries.append(newEntry)
        cloudEntries.value.append(newEntry)

        // if new record has been added by user right now and it is not from initial fetching of all records,
        // lets move to the right db and select new entry
        if !fromFetch {
            selectedEntry.value = newEntry
        }
    }

    func localActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool) {
        allEntries.append(newEntry)
        localEntries.value.append(newEntry)

        // if new record has been added by user right now and it is not from initial fetching of all records,
        // lets move to the right db and select new entry
        if !fromFetch {
            selectedEntry.value = newEntry
        }
    }

    func cloudActivityRemoved(_ removed: ActivityRecordDataModel) {
        selectedEntry.value = nil
        if let indexInAll = allEntries.firstIndex(of: removed) {
            allEntries.remove(at: indexInAll)
        }

        if let index = cloudEntries.value.firstIndex(of: removed) {
            cloudEntries.value.remove(at: index)
        }
    }

    func localActivityRemoved(_ removed: ActivityRecordDataModel) {
        selectedEntry.value = nil
        if let indexInAll = allEntries.firstIndex(of: removed) {
            allEntries.remove(at: indexInAll)
        }
        if let index = localEntries.value.firstIndex(of: removed) {
            localEntries.value.remove(at: index)
        }
    }
}

