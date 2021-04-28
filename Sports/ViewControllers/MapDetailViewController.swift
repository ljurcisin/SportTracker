//
//  MapDetailViewController.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 28/04/2021.
//  Copyright © 2021 Lubomir Jurcisin. All rights reserved.
//

import UIKit
import MapKit

/**
 MapDetailViewController is the fullscren map popover view for location detail
*/
class MapDetailViewController: UIViewController {
    
    private let backButton = UIButton()
    private let mapView = MKMapView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        self.view = mapView
        
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = true
        
        mapView.addSubview(backButton)
        backButton.layer.cornerRadius = 30
        backButton.backgroundColor = .white
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage.init(named: "back")?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5), resizingMode: .stretch), for: .normal)
        backButton.addTarget(self, action: #selector(self.dismissMapDetail), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 60),
            backButton.bottomAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            backButton.trailingAnchor.constraint(equalTo: mapView.safeAreaLayoutGuide.trailingAnchor, constant: -40)
        ])
    }
    
    @objc private func dismissMapDetail() {
        dismiss(animated: true, completion: nil)
    }
    
    //public
    func setLocation(_ location: CLLocationCoordinate2D) {
        mapView.removeAnnotations(mapView.annotations)
        
        let newCamera = MKMapCamera(lookingAtCenter: location, fromDistance: CLLocationDistance(600), pitch: 1, heading: CLLocationDirection(0))
        mapView.setCamera(newCamera, animated: true)
        let marker = MKPointAnnotation()
        marker.coordinate = location
        mapView.addAnnotation(marker)

    }
}
