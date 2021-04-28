//
//  ActivityRecordsTableViewCell.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 30/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import UIKit
import MapKit

/**
 ActivityRecordsTableViewCell is the view class of activity record table view cell
 It uses ActivityRecordDataModel class for loading all the information about the activity
 It expands on user touch and shows the map with the location of activity
*/
class ActivityRecordsTableViewCell: UITableViewCell {

    // MARK: - Private properties
    private var mainView = UIView()
    private var shadowView = UIView()
    private var nameLabel = UILabel()
    private var durationLabel = UILabel()
    private var datelabel = UILabel()
    private var mapView = MKMapView()
    private let marker = MKPointAnnotation()
    private var cloudIcon = UIImageView()
    private var sportIcon = UIImageView()
    private var stopwatchIcon = UIImageView()
    private var intensityIcon = UIImageView()
    private var intensitySlider = UISlider()
    private var deleteButton = UIButton()
    private var activeViewsConstraints = [NSLayoutConstraint]()
    private var shadowSize = Float(0.0)

    private(set) var currentRecord: ActivityRecordDataModel?
    
    // MARK: - Public property
    var mapDetailCallback : ((_ coordinates: CLLocationCoordinate2D)-> Void)?

    // MARK: - Public Properties
    var isActive: Bool = false {
        didSet {
            if isActive && !isLandscapeScreenOrientation() {
                if activeViewsConstraints.count > 0, !activeViewsConstraints.first!.isActive {
                    NSLayoutConstraint.activate(activeViewsConstraints)
                }
                mapView.isHidden = false
                stopwatchIcon.isHidden = false
                intensityIcon.isHidden = false
                intensitySlider.isHidden = false
                durationLabel.isHidden = false
                
            } else {
                if activeViewsConstraints.count > 0, activeViewsConstraints.first!.isActive {
                    NSLayoutConstraint.deactivate(activeViewsConstraints)
                }
                mapView.isHidden = true
                stopwatchIcon.isHidden = true
                intensityIcon.isHidden = true
                intensitySlider.isHidden = true
                durationLabel.isHidden = true
            }
        }
    }
    
    var shadow: Bool = false {
        didSet {
            shadowView.layer.masksToBounds = !shadow
            if shadow {
                shadowSize = 0.9
                shadowView.animateLayer(\.shadowOpacity, to: 0.9, duration:0.3)
            } else {
                shadowSize = 0
                shadowView.animateLayer(\.shadowOpacity, to: 0, duration:0.3)
            }
        }
    }

    // MARK: - Public Methods
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
        setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        deleteButton.addShadow(withRadius: 20, withSize: 2, withOpacity: 0.4, withOffset: CGSize(width: 0.5, height: 2), withColor: UIColor.black)
        shadowView.addShadow(withRadius: 20, withSize: 3, withOpacity: shadowSize, withOffset: CGSize(width: 0, height: 0), withColor: ActivityRecordsTableViewController.blueColor)
    }

    func setup(with entry: ActivityRecordDataModel, isActive active: Bool) {
        currentRecord = entry
        isActive = active
        shadow = active
        
        //type of the sport
        nameLabel.text = getSportTypeText()
        
        //duration
        var durationText = ""
        if entry.duration >= 60 {
            let hours = Int(entry.duration / 60) > 1 ? NSLocalizedString(" hours ", comment: "") : NSLocalizedString(" hour ", comment: "")
            durationText = String(Int(entry.duration / 60)) + hours
        }

        let mins = Int(entry.duration % 60)
        if mins > 0 {
            let minString = mins > 1 ? NSLocalizedString(" minutes", comment: "") : NSLocalizedString(" minute", comment: "")
            durationText.append(String(mins) + minString)
        }
        durationLabel.text = durationText

        let df = DateFormatter()
        df.dateFormat = "dd.MMMM YYYY hh:mm"
        datelabel.text = df.string(from: entry.timestamp)

        //other
        cloudIcon.alpha = entry.isLocal ? 0 : 100
        sportIcon.image = getSportTypeIcon()
        intensitySlider.value = currentRecord?.intensity ?? 0
        intensitySlider.setEmojiForIntensity(value: intensitySlider.value/5)

        //location
        let coords = CLLocationCoordinate2D(latitude: entry.locationX, longitude: entry.locationY)
        let newCamera = MKMapCamera(lookingAtCenter: coords, fromDistance: CLLocationDistance(10), pitch: 1, heading: CLLocationDirection(0))
        self.mapView.setCamera(newCamera, animated: true)
        self.marker.coordinate = coords
    }

    // MARK: - Private Methods
    @objc private func deleteButtonPressed(sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Delete", comment: ""), message: NSLocalizedString("Are you sure you want to delete this activity?", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let currentRecord = self.currentRecord {
                APIManager.get().delete(entry: currentRecord) { (result) in
                }
            }
        })
        let noAction = UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .default, handler: nil)
        alert.addAction(okAction)
        alert.addAction(noAction)

        parentViewController?.present(alert, animated: true, completion: nil)
    }

    private func setupUI() {
        backgroundColor = .none
        selectionStyle = .none
        contentView.backgroundColor = .none
        contentView.layer.cornerRadius = 20
        contentView.layer.masksToBounds = false
        
        mainView.backgroundColor = UIColor.init(white: 240/255, alpha: 1)
        mainView.layer.cornerRadius = 20
        mainView.layer.masksToBounds = true
        
        shadowView.backgroundColor = .none
        shadowView.layer.cornerRadius = 20
        shadowView.layer.borderWidth = 0
        shadowView.layer.masksToBounds = false

        contentView.addSubview(shadowView)
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        
        shadowView.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(sportIcon)
        sportIcon.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.textColor = .black
        mainView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        mainView.addSubview(datelabel)
        datelabel.translatesAutoresizingMaskIntoConstraints = false
        datelabel.textColor = UIColor(white: 0.2, alpha: 1)
        datelabel.font = durationLabel.font.withSize(durationLabel.font.pointSize * 0.7)
        
        mainView.addSubview(stopwatchIcon)
        stopwatchIcon.translatesAutoresizingMaskIntoConstraints = false
        stopwatchIcon.image = UIImage.init(named: "stopwatch")?.withTintColor(ActivityRecordsTableViewController.blueColor)

        mainView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.textColor = UIColor(white: 0.2, alpha: 1)
        durationLabel.font = durationLabel.font.withSize(durationLabel.font.pointSize * 0.7)
        
        mainView.addSubview(intensityIcon)
        intensityIcon.translatesAutoresizingMaskIntoConstraints = false
        intensityIcon.image = UIImage.init(named: "intensity")?.withTintColor(ActivityRecordsTableViewController.blueColor)
        
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 5
        intensitySlider.isUserInteractionEnabled = false
        intensitySlider.tintColor = ActivityRecordsTableViewController.blueColor
        mainView.addSubview(intensitySlider)
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
        
        mainView.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = ActivityRecordsTableViewController.blueColor.cgColor

        mapView.layer.cornerRadius = 20
        mapView.addAnnotation(marker)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView(_:)))
        mapView.addGestureRecognizer(tapGestureRecognizer)

        mainView.addSubview(cloudIcon)
        cloudIcon.translatesAutoresizingMaskIntoConstraints = false

        deleteButton.setImage(UIImage(named: "delete"), for: .normal)
        deleteButton.backgroundColor = .white
        mapView.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.addTarget(self, action: #selector(self.deleteButtonPressed), for: .touchUpInside)

        cloudIcon.image = UIImage(named: "cloud")
        cloudIcon.alpha = 0
    }
    
    @objc private func didTapMapView(_ sender: UITapGestureRecognizer) {
        if let activeEntry = currentRecord {
            mapDetailCallback?(activeEntry.coordinates)
        }
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            shadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            shadowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            shadowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            shadowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
        
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: shadowView.topAnchor, constant: 0),
            mainView.bottomAnchor.constraint(equalTo: shadowView.bottomAnchor, constant: 0),
            mainView.leadingAnchor.constraint(equalTo: shadowView.leadingAnchor, constant: 0),
            mainView.trailingAnchor.constraint(equalTo: shadowView.trailingAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            sportIcon.heightAnchor.constraint(equalToConstant: 65),
            sportIcon.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 19),
            sportIcon.trailingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 80.0),
            sportIcon.widthAnchor.constraint(equalToConstant: 65)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.heightAnchor.constraint(equalToConstant: 20),
            nameLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 30),
            nameLabel.leadingAnchor.constraint(equalTo: sportIcon.trailingAnchor, constant: 15.0),
            nameLabel.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.8)
        ])
        
        NSLayoutConstraint.activate([
            datelabel.heightAnchor.constraint(equalToConstant: 15),
            datelabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 7),
            datelabel.leadingAnchor.constraint(equalTo: sportIcon.trailingAnchor, constant: 15.0),
            datelabel.widthAnchor.constraint(equalTo: mainView.widthAnchor, multiplier: 0.8)
        ])
        
        //detail views
        activeViewsConstraints.append(contentsOf:[
            stopwatchIcon.heightAnchor.constraint(equalToConstant: 20),
            stopwatchIcon.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 100),
            stopwatchIcon.leadingAnchor.constraint(equalTo: sportIcon.leadingAnchor, constant: 0),
            stopwatchIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        activeViewsConstraints.append(contentsOf:[
            durationLabel.heightAnchor.constraint(equalToConstant: 20),
            durationLabel.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 100),
            durationLabel.leadingAnchor.constraint(equalTo: stopwatchIcon.trailingAnchor, constant: 10),
            durationLabel.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: 0)
        ])
        
        activeViewsConstraints.append(contentsOf:[
            intensityIcon.heightAnchor.constraint(equalToConstant: 20),
            intensityIcon.topAnchor.constraint(equalTo: stopwatchIcon.bottomAnchor, constant: 10),
            intensityIcon.leadingAnchor.constraint(equalTo: sportIcon.leadingAnchor, constant: 0),
            intensityIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        activeViewsConstraints.append(contentsOf:[
            intensitySlider.heightAnchor.constraint(equalToConstant: 20),
            intensitySlider.topAnchor.constraint(equalTo: stopwatchIcon.bottomAnchor, constant: 10),
            intensitySlider.leadingAnchor.constraint(equalTo: intensityIcon.trailingAnchor, constant: 5),
            intensitySlider.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -20)
        ])
        
        activeViewsConstraints.append(contentsOf:[
            mapView.bottomAnchor.constraint(greaterThanOrEqualTo: mainView.bottomAnchor, constant: -5),
            mapView.leadingAnchor.constraint(equalTo: mainView.leadingAnchor, constant: 5),
            mapView.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -5),
            mapView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 160)
        ])
        
        NSLayoutConstraint.activate([
            cloudIcon.heightAnchor.constraint(equalToConstant: 20),
            cloudIcon.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 10),
            cloudIcon.trailingAnchor.constraint(equalTo: mainView.trailingAnchor, constant: -15.0),
            cloudIcon.widthAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            deleteButton.heightAnchor.constraint(equalToConstant: 40),
            deleteButton.widthAnchor.constraint(equalToConstant: 40),
            deleteButton.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -20.0),
            deleteButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -20)
        ])
    }
    
    private func getSportTypeIcon() -> UIImage? {
        if let entry = currentRecord {
            switch entry.type {
            case .run:
                return UIImage.init(named: "sport_run")
            case .bike:
                return UIImage.init(named: "sport_bike")
            case .swim:
                return UIImage.init(named: "sport_swim")
            case .weight:
                return UIImage.init(named: "sport_weight")
            case .cardio:
                return UIImage.init(named: "sport_cardio")
            case .football:
                return UIImage.init(named: "sport_football")
            default:
                print("Error: correct icon not found")
                return nil
            }
        }
        
        return nil
    }
    
    private func getSportTypeText() -> String {
        if let entry = currentRecord {
            switch entry.type {
            case .run:
                return NSLocalizedString("Run", comment: "")
            case .bike:
                return NSLocalizedString("Bike", comment: "")
            case .swim:
                return NSLocalizedString("Swim", comment: "")
            case .weight:
                return NSLocalizedString("Weight training", comment: "")
            case .cardio:
                return NSLocalizedString("Cardio", comment: "")
            case .football:
                return NSLocalizedString("Football", comment: "")
            default:
                print("Error: correct icon not found")
                return "Unrecognized Sport"
            }
        }
        
        return "Unrecognized Sport"
    }
    
    func isLandscapeScreenOrientation() -> Bool {
        //UIDevice.current.orientation.isLandscape { returns .unknown, bug in simulator?
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}


