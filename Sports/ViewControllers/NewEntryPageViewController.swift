//
//  NewEntryPageViewController.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 26/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import UIKit
import MapKit

/**
 NewEntryPageViewController is the page view controlling all the SetupWalkthrough views
*/
class NewEntryPageViewController: UIViewController {

    // MARK: - Private Properties
    private var viewModel: CreateNewActivityViewModel!
    private let topView = UIView()
    private let bottomView = UIView()
    private var compactConstraints: [NSLayoutConstraint] = []
    private var regularConstraints: [NSLayoutConstraint] = []
    private let sportPicker = UIPickerView()
    private let mapView = MKMapView()
    private let durationPicker = UIDatePicker()
    private let intensitySlider = UISlider()
    private let locationSegmentedControl = UILocationSegmentedControll()
    private let storageSegmentedControl = UISegmentedControl()
    private let commitButton = UIButton()
    private let locationLabel = UILabel()
    private let durationLabel = UILabel()
    private let sportLabel = UILabel()
    private let intensityLabel = UILabel()
    private let storageLabel = UILabel()
    
    // MARK: - Public Methods
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        viewModel = CreateNewActivityViewModel(self)
        bindToViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        layoutTrait(traitCollection: traitCollection)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait(traitCollection: traitCollection)
    }

    func layoutTrait(traitCollection:UITraitCollection) {
        if self.isLandscapeScreenOrientation() {
            if regularConstraints.count > 0 && regularConstraints[0].isActive {
                NSLayoutConstraint.deactivate(regularConstraints)
            }
            // activating compact constraints
            NSLayoutConstraint.activate(compactConstraints)
        } else {
            if compactConstraints.count > 0 && compactConstraints[0].isActive {
                NSLayoutConstraint.deactivate(compactConstraints)
            }
            // activating regular constraints
            NSLayoutConstraint.activate(regularConstraints)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        commitButton.addShadow(withRadius: 25, withSize: 5, withOpacity: 0.5, withOffset: CGSize(width: 0, height: 0), withColor: ActivityRecordsTableViewController.blueColor)
    }


    // MARK: - Private methods
    private func setupUI() {
        self.view.backgroundColor = UIColor.white
        self.navigationItem.title = NSLocalizedString("Create new Activity", comment: "")
        
        view.addSubview(topView)
        view.addSubview(bottomView)
        topView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false

        topView.addSubview(mapView)
        mapView.showsUserLocation = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = 20
        mapView.layer.masksToBounds = true
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = ActivityRecordsTableViewController.blueColor.cgColor
        
        topView.addSubview(intensityLabel)
        intensityLabel.text = NSLocalizedString("How did that feel?", comment: "")
        intensityLabel.textAlignment = .center
        intensityLabel.font = UIFont.systemFont(ofSize: 15)
        intensityLabel.textColor = ActivityRecordsTableViewController.blueColor
        intensityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        topView.addSubview(intensitySlider)
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 5
        intensitySlider.tintColor = ActivityRecordsTableViewController.blueColor
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        intensitySlider.addTarget(self, action: #selector(onSliderValueChanged), for: UIControl.Event.valueChanged)
        intensitySlider.value = 2.5
        intensitySlider.setEmojiForIntensity(value: intensitySlider.value/5)
        
        //Bottom part
        bottomView.addSubview(sportLabel)
        sportLabel.text = NSLocalizedString("Pick sport", comment: "")
        sportLabel.textAlignment = .center
        sportLabel.font = UIFont.systemFont(ofSize: 15)
        sportLabel.textColor = ActivityRecordsTableViewController.blueColor
        sportLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.addSubview(sportPicker)
        sportPicker.translatesAutoresizingMaskIntoConstraints = false
        sportPicker.layer.cornerRadius = 20
        sportPicker.layer.masksToBounds = true
        sportPicker.layer.borderWidth = 1
        sportPicker.layer.borderColor = ActivityRecordsTableViewController.blueColor.cgColor
        sportPicker.dataSource = self
        sportPicker.delegate = self
        
        bottomView.addSubview(durationLabel)
        durationLabel.text = NSLocalizedString("Duration", comment: "")
        durationLabel.textAlignment = .center
        durationLabel.font = UIFont.systemFont(ofSize: 15)
        durationLabel.textColor = ActivityRecordsTableViewController.blueColor
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.addSubview(durationPicker)
        durationPicker.countDownDuration = 60.0
        durationPicker.datePickerMode = .countDownTimer
        durationPicker.translatesAutoresizingMaskIntoConstraints = false
        durationPicker.layer.cornerRadius = 20
        durationPicker.backgroundColor = UIColor.white
        durationPicker.layer.masksToBounds = true;
        durationPicker.layer.borderWidth = 1
        durationPicker.layer.borderColor = ActivityRecordsTableViewController.blueColor.cgColor
        
        bottomView.addSubview(locationLabel)
        locationLabel.text = NSLocalizedString("Location", comment: "")
        locationLabel.textAlignment = .center
        locationLabel.font = UIFont.systemFont(ofSize: 15)
        locationLabel.textColor = ActivityRecordsTableViewController.blueColor
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.addSubview(locationSegmentedControl)
        locationSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        locationSegmentedControl.insertSegment(with: UIImage.init(named: "my_location"), at: 0, animated: false)
        locationSegmentedControl.insertSegment(with: UIImage.init(named: "search"), at: 0, animated: false)
        locationSegmentedControl.contentVerticalAlignment = .center
        locationSegmentedControl.contentHorizontalAlignment = .center
        locationSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 75.0 / 255.0, green: 86.0 / 255.0, blue: 104.0 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont()], for: .selected)
        locationSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 150.0 / 255.0, green: 159.0 / 255.0, blue: 170.0 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont()], for: .normal)
        locationSegmentedControl.selectedSegmentIndex = 1
        locationSegmentedControl.delegate = self
        if viewModel.locationGranted.value == false {
            locationSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 200.0 / 255.0, green: 0, blue: 0, alpha: 0.8), NSAttributedString.Key.font: UIFont()], for: .normal)
            locationSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
        }
        
        bottomView.addSubview(storageLabel)
        storageLabel.text = NSLocalizedString("Storage", comment: "")
        storageLabel.textAlignment = .center
        storageLabel.font = UIFont.systemFont(ofSize: 15)
        storageLabel.textColor = ActivityRecordsTableViewController.blueColor
        storageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.addSubview(storageSegmentedControl)
        storageSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        storageSegmentedControl.insertSegment(with: UIImage.init(named: "cloud_2"), at: 0, animated: false)
        storageSegmentedControl.insertSegment(with: UIImage.init(named: "iphone"), at: 0, animated: false)
        storageSegmentedControl.contentVerticalAlignment = .center
        storageSegmentedControl.contentHorizontalAlignment = .center
        storageSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 75.0 / 255.0, green: 86.0 / 255.0, blue: 104.0 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont()], for: .selected)
        storageSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 150.0 / 255.0, green: 159.0 / 255.0, blue: 170.0 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont()], for: .normal)
        storageSegmentedControl.addTarget(self, action: #selector(self.onStorageLocationChanged), for: .valueChanged)
        storageSegmentedControl.selectedSegmentIndex = 0
        
        bottomView.addSubview(commitButton)
        commitButton.setImage(UIImage.init(named: "plus")?.withTintColor(ActivityRecordsTableViewController.blueColor), for: .normal)
        commitButton.backgroundColor = .white
        commitButton.translatesAutoresizingMaskIntoConstraints = false
        commitButton.addTarget(self, action: #selector(self.onCommitButtonPressed), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            topView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        regularConstraints.append(contentsOf:[
            topView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            topView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            bottomView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.5),
            bottomView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor)
        ])

        compactConstraints.append(contentsOf:[
            topView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            topView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5),
            bottomView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor),
            bottomView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.5)
        ])
        
        NSLayoutConstraint.activate(regularConstraints)
        
        //map view
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topView.topAnchor, constant: 20),
            mapView.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 10),
            mapView.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -10)
        ])
        
        //intensity label
        NSLayoutConstraint.activate([
            intensityLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20),
            intensityLabel.heightAnchor.constraint(equalToConstant: 20),
            intensityLabel.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
            intensityLabel.trailingAnchor.constraint(equalTo: topView.trailingAnchor)
        ])
        
        //intensity slider
        NSLayoutConstraint.activate([
            intensitySlider.heightAnchor.constraint(equalToConstant: 20),
            intensitySlider.bottomAnchor.constraint(equalTo: topView.bottomAnchor, constant: 10),
            intensitySlider.topAnchor.constraint(equalTo: intensityLabel.topAnchor, constant: 20),
            intensitySlider.leadingAnchor.constraint(equalTo: topView.leadingAnchor, constant: 20),
            intensitySlider.trailingAnchor.constraint(equalTo: topView.trailingAnchor, constant: -20)
        ])
        
        //sport label
        NSLayoutConstraint.activate([
            sportLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            sportLabel.heightAnchor.constraint(equalToConstant: 20),
            sportLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 10),
            sportLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.45)
        ])
        
        //sport picker
        NSLayoutConstraint.activate([
            sportPicker.topAnchor.constraint(equalTo: sportLabel.bottomAnchor, constant: 10),
            sportPicker.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.45),
            sportPicker.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 10)
        ])
        
        //duration label
        NSLayoutConstraint.activate([
            durationLabel.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: 20),
            durationLabel.heightAnchor.constraint(equalToConstant: 20),
            durationLabel.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -10),
            durationLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.45)
        ])
        
        //duration picker
        NSLayoutConstraint.activate([
            durationPicker.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 10),
            durationPicker.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.45),
            durationPicker.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -10)
        ])
        
        //location label
        NSLayoutConstraint.activate([
            //locationLabel.topAnchor.constraint(equalTo: durationPicker.bottomAnchor, constant: 20),
            locationLabel.heightAnchor.constraint(equalToConstant: 40),
            locationLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 10),
            locationLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.25)
        ])
        
        //save to segmented controll
        NSLayoutConstraint.activate([
            locationSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            locationSegmentedControl.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.35),
            locationSegmentedControl.leadingAnchor.constraint(equalTo: locationLabel.trailingAnchor, constant: 10),
            sportPicker.bottomAnchor.constraint(equalTo: locationSegmentedControl.topAnchor, constant: -30),
            durationPicker.bottomAnchor.constraint(equalTo: locationSegmentedControl.topAnchor, constant: -30),
            locationLabel.centerYAnchor.constraint(equalTo: locationSegmentedControl.centerYAnchor)
        ])
        
        //storage label
        NSLayoutConstraint.activate([
            storageLabel.heightAnchor.constraint(equalToConstant: 40),
            storageLabel.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 10),
            storageLabel.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.25)
        ])
        
        //storage segmented controll
        NSLayoutConstraint.activate([
            storageSegmentedControl.topAnchor.constraint(equalTo: locationSegmentedControl.bottomAnchor, constant: 10),
            storageSegmentedControl.bottomAnchor.constraint(equalTo: bottomView.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            storageSegmentedControl.heightAnchor.constraint(equalToConstant: 40),
            storageSegmentedControl.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.35),
            storageSegmentedControl.leadingAnchor.constraint(equalTo: locationLabel.trailingAnchor, constant: 10),
            storageLabel.centerYAnchor.constraint(equalTo: storageSegmentedControl.centerYAnchor)
        ])
        
        //commit button
        NSLayoutConstraint.activate([
            commitButton.heightAnchor.constraint(equalToConstant: 50),
            commitButton.widthAnchor.constraint(equalToConstant: 50),
            commitButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -40.0),
            commitButton.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor, constant: -40)
        ])
    }
    
    @objc private func onSliderValueChanged() {
        intensitySlider.setEmojiForIntensity(value: intensitySlider.value/5)
        viewModel.dataForNewActivity.value.intensity = intensitySlider.value
    }
    
    @objc private func onCommitButtonPressed() {
        if viewModel.areDataValid() {
            
            viewModel.dataForNewActivity.value.duration = Int(durationPicker.countDownDuration / 60)
            viewModel.commit { (result) in
                if result == true {
                    guard let viewController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController else { return }
                    viewController.selectedIndex = 1
                } else {
                    let alert = UIAlertController(title: NSLocalizedString("Failure", comment: ""), message: NSLocalizedString("Creating new sport activity failed", comment: ""), preferredStyle: .alert)
                    let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func onStorageLocationChanged() {
        viewModel.saveToCloud.value = storageSegmentedControl.selectedSegmentIndex == 1
    }
    
    private func showLocationSearchVC() {
        if viewModel.location.value == nil {
            if viewModel.locationGranted.value {
                locationSegmentedControl.selectedSegmentIndex = 1
            }
            else {
                locationSegmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
            }
        }
        
        let locationPicker = LocationPickerViewController()

        locationPicker.viewModel = viewModel
        locationPicker.completion = { location in
            if let newLocation = location {
                self.locationSegmentedControl.selectedSegmentIndex = 0
                self.viewModel.customLocation.value = true
                self.viewModel.location.value = newLocation
            }
        }

        navigationController?.pushViewController(locationPicker, animated: true)
    }

    private func bindToViewModel() {
        
        viewModel.locationGranted.bind { [weak self] (observable, newVal, oldVal) in
            if self?.locationSegmentedControl.numberOfSegments == 2 {
                self?.locationSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor(red: 150.0 / 255.0, green: 159.0 / 255.0, blue: 170.0 / 255.0, alpha: 1), NSAttributedString.Key.font: UIFont()], for: .normal)
            }
        }
        
        viewModel.userLocation.bind { [weak self] (observable, newVal, oldVal) in
            if let location = newVal, self?.viewModel.location.value == nil, !(self?.viewModel.customLocation.value ?? false) {
                self?.showLocation(location.coordinate, withMarker: false)
            } else if self?.viewModel.customLocation.value == true ,
                      let location = self?.viewModel.location.value {
                self?.showLocation(location.coordinate, withMarker: false)
            } else {
                self?.showLocation(nil, withMarker: false)
            }
        }
        
        viewModel.location.bind { [weak self] (observable, newVal, oldVal) in
            if let location = newVal {
                self?.showLocation(location.coordinate, withMarker: true)
            } else if self?.viewModel.customLocation.value == false,
                      let location = self?.viewModel.userLocation.value {
                self?.showLocation(location.coordinate, withMarker: false)
            } else {
                self?.showLocation(nil, withMarker: false)
            }
        }
        
        viewModel.dataForNewActivity.bind{ [weak self] (observable, newVal, oldVal) in
            self?.durationPicker.countDownDuration = TimeInterval(newVal.duration)
            self?.intensitySlider.value = newVal.intensity
            self?.intensitySlider.setEmojiForIntensity(value: (self?.intensitySlider.value ?? 2.5)/5)
            self?.sportPicker.selectRow(Int(newVal.sport.rawValue), inComponent: 0, animated: true)
        }
        
    }
    
    private func showLocation(_ location: CLLocationCoordinate2D?, withMarker showMarker: Bool) {
        guard let newLocation = location else {
            mapView.region = MKCoordinateRegion()
            mapView.removeAnnotations(mapView.annotations)
            commitButton.isEnabled = false
            return
        }
        let newCamera = MKMapCamera(lookingAtCenter: newLocation, fromDistance: CLLocationDistance(600), pitch: 1, heading: CLLocationDirection(0))
        mapView.setCamera(newCamera, animated: true)
        if showMarker {
            let marker = MKPointAnnotation()
            marker.coordinate = newLocation
            mapView.addAnnotation(marker)
        } else {
            mapView.removeAnnotations(mapView.annotations)
        }
        
        commitButton.isEnabled = true
    }
    
    private func getSportString(_ index: Int) -> String {
        switch index {
        case 0:
            return NSLocalizedString("Run", comment: "")
        case 1:
            return NSLocalizedString("Weight", comment: "")
        case 2:
            return NSLocalizedString("Cardio", comment: "")
        case 3:
            return NSLocalizedString("Swim", comment: "")
        case 4:
            return NSLocalizedString("Bike", comment: "")
        case 5:
            return NSLocalizedString("Football", comment: "")
        default:
            print("Error: correct sport type not found!")
            return ""
        }
    }
    
    private func getSportIcon(_ index: Int) -> UIImage? {
        switch index {
        case 0:
            return UIImage.init(named: "sport_run")
        case 1:
            return UIImage.init(named: "sport_weight")
        case 2:
            return UIImage.init(named: "sport_cardio")
        case 3:
            return UIImage.init(named: "sport_swim")
        case 4:
            return UIImage.init(named: "sport_bike")
        case 5:
            return UIImage.init(named: "sport_football")
        default:
            print("Error: correct sport type not found!")
            return nil
        }
    }
}


extension NewEntryPageViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
}

extension NewEntryPageViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let myView = UIView()

        let myImageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 40, height:40))
        myImageView.image = getSportIcon(row)
        
        let myLabel = UILabel(frame: CGRect(x: 60, y: 20, width: 100, height:20))
        myLabel.font = UIFont.boldSystemFont(ofSize: 15)
        myLabel.text = getSportString(row)

        myView.addSubview(myLabel)
        myView.addSubview(myImageView)
        
        return myView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.dataForNewActivity.value.sport = SportType.init(rawValue: Int16(row)) ?? .run
    }
}

extension NewEntryPageViewController: UILocationSegmentedControllDelegate {
    func segmentChanged() {
        if locationSegmentedControl.selectedSegmentIndex == 0 {
            showLocationSearchVC()
        }
        else {
            viewModel.customLocation.value = false
            viewModel.location.value = nil
        }
    }
    
    func segmentNotChanged() {
        if locationSegmentedControl.selectedSegmentIndex == 0 {
            showLocationSearchVC()
        }
    }
    
    func isSegmentEnabled(_ index: Int) -> Bool {
        if index == 1,
           viewModel.locationGranted.value == false {
            let alert = UIAlertController(title: NSLocalizedString("Location", comment: ""), message: NSLocalizedString("GPS is not available. Please allow location services to use your current location", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return false
        }
        
        return true
    }
}
