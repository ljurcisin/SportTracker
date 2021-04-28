//
//  CreateNewActivityViewModel.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 04/04/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import Foundation
import MapKit

/**
 CreateNewActivityViewModel is view model class responsible for all logic behind setup walkthrough page view controller
 It holds and gather all data needed for creating new record, it also calls API method for creating new sport record
*/
final class CreateNewActivityViewModel: NSObject {

    // MARK: - Public Properties
    var dataForNewActivity = Observable<NewActivityData> (NewActivityData())
    var location = Observable<Location?> (nil)
    var userLocation = Observable<Location?> (nil)
    let saveToCloud = Observable<Bool> (false)
    let customLocation = Observable<Bool> (false)
    let locationGranted = Observable<Bool> (false)


    // MARK: - private Properties
    private let locationManager = CLLocationManager()

    // MARK: - Public methods
    convenience init(_ parentVC: UIViewController) {
        self.init()

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            userLocation.value = Location(name: "user location", location: location)
        }

        locationManager.requestLocation()
    }

    func reset() {
        dataForNewActivity.value = NewActivityData()
        userLocation.value = nil
        location.value = nil
        saveToCloud.value = false
        customLocation.value = false
        locationManager.requestLocation()

    }
    
    func areDataValid() -> Bool {
        if customLocation.value {
            return location.value != nil
        } else {
            return userLocation.value != nil
        }
    }

    func commit(_ callback: ((_ result: Bool) -> Void)?) {
        guard let selectedLocation = customLocation.value ? location.value : userLocation.value else {
            callback?(false)
            return
        }

        if saveToCloud.value {
            APIManager.get().addCloudEntry(with: dataForNewActivity.value.sport,
                                           intensity: dataForNewActivity.value.intensity,
                                           locationX: selectedLocation.coordinate.latitude,
                                           locationY: selectedLocation.coordinate.longitude,
                                           duration: dataForNewActivity.value.duration,
                                           callback: { (success: Bool) in
                if success {
                    self.reset()
                    callback?(true)
                }
                else {
                    callback?(false)
                }
            })
        } else {
            APIManager.get().addLocalEntry(with: dataForNewActivity.value.sport,
                                           intensity: dataForNewActivity.value.intensity,
                                           locationX: selectedLocation.coordinate.latitude,
                                           locationY: selectedLocation.coordinate.longitude,
                                           duration: dataForNewActivity.value.duration,
                                           callback: { (success: Bool) in
                if success {
                    self.reset()
                    callback?(true)
                }
                else {
                    callback?(false)
                }
            })
        }
    }
}

//
// MARK: - CLLocationManager delegate methods
extension CreateNewActivityViewModel: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            locationGranted.value = false
        } else if status == CLAuthorizationStatus.authorizedWhenInUse {
            locationGranted.value = true
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.userLocation.value = Location(name: "user location", location: location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
}
