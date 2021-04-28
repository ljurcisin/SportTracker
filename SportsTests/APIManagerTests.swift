//
//  APIManagerTests.swift
//  SportsTests
//
//  Created by Lubomir Jurcisin on 06/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import XCTest
import Firebase

@testable import Sports

class APIManagerTests: XCTestCase {

    var localEntries = [ActivityRecordDataModel]()
    var cloudEntries = [ActivityRecordDataModel]()

    override func setUpWithError() throws {
        try super.setUpWithError()

        //initialize api manager
        _ = APIManager.get().delegate = self
    }

    override func tearDownWithError() throws {
        super.tearDown()

        APIManager.get().deleteAllCloudData()
    }

    func testCreatingNewLocally() throws {
        var callbackResult = false
        let promise = expectation(description: "Completion handler invoked")
        APIManager.get().addLocalEntry(with: .bike, intensity: 4.5, locationX: 15.15, locationY: 25.25, duration: 61, callback: { (success: Bool) in
            callbackResult = success
            promise.fulfill()
        })

        wait(for: [promise], timeout: timeoutValue)

        XCTAssertTrue(callbackResult)
        if !callbackResult {
            return
        }

        let addedActivity = localEntries.last
        XCTAssertNotNil(addedActivity, "Error: local entry was not created successfuly")
        if let activity = addedActivity {
        XCTAssertEqual(activity.isLocal, true, "Error: local entry was not created with correct setting")
        XCTAssertEqual(activity.type, .bike, "Error: local entry was not created successfuly")
        XCTAssertEqual(activity.duration, 61, "Error: local entry was not created successfuly")
        XCTAssertEqual(activity.intensity, 4.5, "Error: local entry was not created successfuly")
        XCTAssertEqual(activity.locationX, 15.15, "Error: local entry was not created successfuly")
        XCTAssertEqual(activity.locationY, 25.25, "Error: local entry was not created successfuly")
        }
        
        let promise2 = expectation(description: "Completion handler invoked")
        APIManager.get().delete(entry: addedActivity!) { (success: Bool) in
            callbackResult = success
            promise2.fulfill()
        }

        wait(for: [promise2], timeout: timeoutValue)

        XCTAssertTrue(callbackResult)
        XCTAssertTrue(localEntries.isEmpty)
    }

    func testCreatingNewRemotelly() throws {
        var callbackResult = false
        let promise = expectation(description: "Completion handler invoked")
        APIManager.get().addCloudEntry(with: .bike, intensity: 4.5, locationX: 15.15, locationY: 25.25, duration: 61, callback: { (success: Bool) in
            callbackResult = success
            promise.fulfill()
        })

        wait(for: [promise], timeout: timeoutValue)

        XCTAssertTrue(callbackResult)
        if !callbackResult {
            return
        }

        let addedActivity = cloudEntries.last
        XCTAssertNotNil(addedActivity, "Error: cloud entry was not created successfuly")
        if let activity = addedActivity {
            XCTAssertEqual(activity.isLocal, false, "Error: cloud entry was not created with correct setting")
            XCTAssertEqual(activity.type, .bike, "Error: local entry was not created successfuly")
            XCTAssertEqual(activity.duration, 61, "Error: local entry was not created successfuly")
            XCTAssertEqual(activity.intensity, 4.5, "Error: local entry was not created successfuly")
            XCTAssertEqual(activity.locationX, 15.15, "Error: local entry was not created successfuly")
            XCTAssertEqual(activity.locationY, 25.25, "Error: local entry was not created successfuly")
        }

        let promise2 = expectation(description: "Completion handler invoked")
        APIManager.get().delete(entry: addedActivity!) { (success: Bool) in
            callbackResult = success
            promise2.fulfill()
        }

        wait(for: [promise2], timeout: timeoutValue)

        XCTAssertTrue(callbackResult)
        XCTAssertTrue(cloudEntries.isEmpty)
    }
}

extension APIManagerTests: APIDelegate {
    func cloudActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool) {
        cloudEntries.append(newEntry)
    }

    func localActivityAdded(_ newEntry: ActivityRecordDataModel, fromFetch: Bool) {
        localEntries.append(newEntry)
    }

    func cloudActivityRemoved(_ removed: ActivityRecordDataModel) {
        cloudEntries.remove(at: cloudEntries.firstIndex(of: removed)!)
    }

    func localActivityRemoved(_ removed: ActivityRecordDataModel) {
        localEntries.remove(at: localEntries.firstIndex(of: removed)!)
    }
}
