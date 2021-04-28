//
//  ActivityRecordsTableViewController.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 26/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import UIKit
import MapKit

/**
 ActivityRecordsTableViewController is the view representing the history of activity records
 User can show only local or cloud activities, or mixed together
 All lists are sorted by date, new on top
*/
class ActivityRecordsTableViewController: UIViewController {
    
    static let blueColor = UIColor.init(red: 93/255, green: 171/255, blue: 229/255, alpha: 1)
    
    // MARK: - Private Properties
    private lazy var mapDetailVC = MapDetailViewController()
    private var table = UITableView(frame: CGRect(), style: .plain)
    private var mainView = UIView()
    private var regularConstraints = [NSLayoutConstraint]()
    private var landscapeConstraints = [NSLayoutConstraint]()
    private var mainViewWidthConstraint: NSLayoutConstraint?
    private var mainViewHalfWidthConstraint: NSLayoutConstraint?
    private var sideView = UIView()
    private var mapView = MKMapView()
    private var stopwatchIcon = UIImageView()
    private var durationLabel = UILabel()
    private var intensityIcon = UIImageView()
    private var intensitySlider = UISlider()
    private let viewModel = ActivityRecordsTableModel()
    private var activeIndexPath: IndexPath? = nil

    // MARK: - Public Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        bindToModel()
        layoutTrait()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layoutTrait()
    }
    
    private func layoutTrait() {
        UIView.animate(withDuration: 0.5) {
            if self.isLandscapeScreenOrientation() {
                if self.regularConstraints.count > 0, self.regularConstraints.first!.isActive {
                    NSLayoutConstraint.deactivate(self.regularConstraints)
                }
                if self.landscapeConstraints.count > 0, !self.landscapeConstraints.first!.isActive {
                    NSLayoutConstraint.activate(self.landscapeConstraints)
                }
                self.intensitySlider.isHidden = false
                
                if self.viewModel.selectedEntry.value == nil {
                    self.viewModel.selectedEntry.value = self.viewModel.getEntry(for: 0, database: .all)
                }
                
            } else {
                if self.landscapeConstraints.count > 0, self.landscapeConstraints.first!.isActive {
                    NSLayoutConstraint.deactivate(self.landscapeConstraints)
                }
                if self.regularConstraints.count > 0, !self.regularConstraints.first!.isActive {
                    NSLayoutConstraint.activate(self.regularConstraints)
                }
                self.intensitySlider.isHidden = true
            }
        }
        if let index = activeIndexPath {
            self.table.reloadRows(at: [index], with: .automatic)
        }
    }

    // MARK: - Private Methods
    private func setupUI() {

        self.view.backgroundColor = UIColor(white: 1, alpha: 1)
        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(sideView)
        sideView.translatesAutoresizingMaskIntoConstraints = false
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapMapView(_:)))
        sideView.addGestureRecognizer(tapGestureRecognizer)
        
        sideView.addSubview(mapView)
        mapView.isUserInteractionEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.borderWidth = 1
        mapView.layer.borderColor = ActivityRecordsTableViewController.blueColor.cgColor
        mapView.layer.cornerRadius = 20
        
        mainView.addSubview(table)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.allowsMultipleSelection = false
        table.backgroundColor = .none
        table.separatorStyle = .none
        table.register(ActivityRecordsTableViewCell.self, forCellReuseIdentifier: ActivityRecordsTableViewCellID)
        
        sideView.addSubview(stopwatchIcon)
        stopwatchIcon.translatesAutoresizingMaskIntoConstraints = false
        stopwatchIcon.image = UIImage.init(named: "stopwatch")?.withTintColor(ActivityRecordsTableViewController.blueColor)

        sideView.addSubview(durationLabel)
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        durationLabel.text = "duration"
        durationLabel.textColor = UIColor(white: 0.2, alpha: 1)
        durationLabel.font = durationLabel.font.withSize(durationLabel.font.pointSize * 0.7)
        
        sideView.addSubview(intensityIcon)
        intensityIcon.translatesAutoresizingMaskIntoConstraints = false
        intensityIcon.image = UIImage.init(named: "intensity")?.withTintColor(ActivityRecordsTableViewController.blueColor)
        
        sideView.addSubview(intensitySlider)
        intensitySlider.minimumValue = 0
        intensitySlider.maximumValue = 5
        intensitySlider.isUserInteractionEnabled = false
        intensitySlider.tintColor = ActivityRecordsTableViewController.blueColor
        intensitySlider.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        regularConstraints.append(NSLayoutConstraint(item: mainView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0))
        landscapeConstraints.append(NSLayoutConstraint(item: mainView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.55, constant: 0))
    
        NSLayoutConstraint.activate([
            sideView.topAnchor.constraint(equalTo: view.topAnchor),
            sideView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sideView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sideView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor, constant: 10),
            table.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            table.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor, constant: 5.0),
            table.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor, constant: -5.0)
        ])
        
        landscapeConstraints.append(contentsOf:[
            mapView.topAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.topAnchor, constant: 120),
            mapView.bottomAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            mapView.trailingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            mapView.leadingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.leadingAnchor, constant: 10)
        ])
        
        landscapeConstraints.append(contentsOf:[
            stopwatchIcon.topAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.topAnchor, constant: 30),
            stopwatchIcon.heightAnchor.constraint(equalToConstant: 30),
            stopwatchIcon.widthAnchor.constraint(equalToConstant: 30),
            stopwatchIcon.leadingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.leadingAnchor, constant: 10.0)
        ])
        
        landscapeConstraints.append(contentsOf:[
            durationLabel.topAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.topAnchor, constant: 30),
            durationLabel.heightAnchor.constraint(equalToConstant: 30),
            durationLabel.trailingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
            durationLabel.leadingAnchor.constraint(equalTo: stopwatchIcon.trailingAnchor, constant: 10.0)
        ])
        
        landscapeConstraints.append(contentsOf:[
            intensityIcon.topAnchor.constraint(equalTo: stopwatchIcon.bottomAnchor, constant: 10),
            intensityIcon.heightAnchor.constraint(equalToConstant: 30),
            intensityIcon.widthAnchor.constraint(equalToConstant: 30),
            intensityIcon.leadingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.leadingAnchor, constant: 10.0)
        ])
        
        landscapeConstraints.append(contentsOf:[
            intensitySlider.topAnchor.constraint(equalTo: stopwatchIcon.bottomAnchor, constant: 10),
            intensitySlider.heightAnchor.constraint(equalToConstant: 30),
            intensitySlider.trailingAnchor.constraint(equalTo: sideView.safeAreaLayoutGuide.trailingAnchor, constant: -10.0),
            intensitySlider.leadingAnchor.constraint(equalTo: intensityIcon.trailingAnchor, constant: 10.0)
        ])
    }

    private func bindToModel() {

        viewModel.cloudEntries.bind { [weak self] (observer, val, oldVal) in
            let diffs = val.difference(from: oldVal)
            self?.activityEvent(diffs, db: .remote)
        }

        viewModel.localEntries.bind { [weak self] (observer, val, oldVal) in
            let diffs = val.difference(from: oldVal)
            self?.activityEvent(diffs, db: .local)
        }
        
        viewModel.selectedEntry.bind{ [weak self] (observer, val, oldVal) in
            self?.showEntryDetail()
        }
        viewModel.locationCoorinates.bind { [weak self] (observable, value, oldVal) in
            self?.setMapLocation(value)
        }
    }
    
    @objc private func didTapMapView(_ sender: UITapGestureRecognizer) {
        
        if let activeEntry = viewModel.selectedEntry.value {
            showMapDetailVC(activeEntry.coordinates)
        }
    }
    
    private func showMapDetailVC(_ coordinates: CLLocationCoordinate2D) {
        mapDetailVC.setLocation(coordinates)
        mapDetailVC.modalPresentationStyle = .popover

        let ppc = mapDetailVC.popoverPresentationController
        ppc?.permittedArrowDirections = .any
        ppc?.delegate = self
        ppc?.barButtonItem = navigationItem.rightBarButtonItem
        ppc?.sourceView = self.view

        present(mapDetailVC, animated: true, completion: nil)
    }

    private func showEntryDetail() {
        if let activeEntry = viewModel.selectedEntry.value,
           let selectedIndex = viewModel.getIndex(of: activeEntry) {
        
            selectRow(selectedIndex)
            setMapLocation(activeEntry.coordinates)
            setEntryDetails(activeEntry)
        }
    }

    private func setMapLocation(_ coordinates: CLLocationCoordinate2D?) {
        if let coordinates = coordinates {
            //self.marker.map = self.mapView
            let newCamera = MKMapCamera(lookingAtCenter: coordinates, fromDistance: CLLocationDistance(10), pitch: 1, heading: CLLocationDirection(0))
            self.mapView.setCamera(newCamera, animated: true)
            let marker = MKPointAnnotation()
            marker.coordinate = coordinates
            mapView.addAnnotation(marker)
        }
        else {
            mapView.setRegion(MKCoordinateRegion(), animated: true)
            self.mapView.removeAnnotations(mapView.annotations)
        }
    }
    
    private func selectRow(_ index: Int) {
        if index < tableView(table, numberOfRowsInSection: 0) {
            if let existingSelection = table.indexPathsForSelectedRows {
                for indexPath in existingSelection {
                    table.deselectRow(at: indexPath, animated: true)
                    self.tableView(table, didDeselectRowAt: indexPath)
                    table.reloadRows(at: [indexPath], with: .none)
                }
            }
            table.selectRow(at: IndexPath(row: index, section: 0), animated: true, scrollPosition: .bottom)
            tableView(table, didSelectRowAt: IndexPath(row: index, section: 0))
            table.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
    }
    
    private func setEntryDetails(_ entry: ActivityRecordDataModel) {
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

        //intensity
        intensitySlider.value = entry.intensity
        intensitySlider.setEmojiForIntensity(value: intensitySlider.value/5)
    }

    private func activityEvent(_ diffs: CollectionDifference<ActivityRecordDataModel>, db: DBSetting) {
        for change in diffs {
          switch change {
          case .remove(offset: _, element: _, associatedWith: _):
            if let activeIndex = activeIndexPath {
                //self.tableView(self.table, didDeselectRowAt: activeIndex)
                self.table.deleteRows(at: [activeIndex], with: .left)
                activeIndexPath = nil
                self.table.reloadRows(at: [activeIndex], with: .automatic)
            } else {
                self.table.reloadData()
            }
          case let .insert(_, newElement, _):
            if let index = self.viewModel.getIndex(of: newElement) {
                self.table.insertRows(at: [IndexPath(row: index, section: 0)], with: .left)
            }
            }
        }
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ActivityRecordsTableViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .fullScreen
    }
}

// MARK: - UITableView DataSource methods
extension ActivityRecordsTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.getCellCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ActivityRecordsTableViewCell") as? ActivityRecordsTableViewCell else {
            print("table view cell did not load")
            return UITableViewCell()
        }

        if let record = viewModel.getEntry(for: indexPath.row, database: .all) {
            cell.setup(with: record, isActive: self.viewModel.selectedEntry.value == record)
            cell.mapDetailCallback = self.showMapDetailVC(_:)
            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UITableView Delegate methods
extension ActivityRecordsTableViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if activeIndexPath == indexPath, !isLandscapeScreenOrientation() {
            return 310
        }
        
        return 110
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let myCell = tableView.cellForRow(at: indexPath) as? ActivityRecordsTableViewCell {

            activeIndexPath = nil
            self.viewModel.selectedEntry.observingActive = false
            self.viewModel.selectedEntry.value = nil
            self.viewModel.selectedEntry.observingActive = true
            CATransaction.setCompletionBlock({
                myCell.shadow = false
            })
            
            CATransaction.begin()
            tableView.beginUpdates()
            myCell.isActive = false
            tableView.endUpdates()
            CATransaction.commit()

        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let myCell = tableView.cellForRow(at: indexPath) as? ActivityRecordsTableViewCell else {
            return
        }
        
        if let activePath = activeIndexPath {
            if activePath == indexPath { return }
            self.tableView(table, didDeselectRowAt: activePath)
        }

        activeIndexPath = indexPath
        self.viewModel.selectedEntry.observingActive = false
        self.viewModel.selectedEntry.value = myCell.currentRecord
        if let record = myCell.currentRecord {
            self.setMapLocation(record.coordinates)
            self.setEntryDetails(record)
        }
        self.viewModel.selectedEntry.observingActive = true
        CATransaction.setCompletionBlock({
            myCell.shadow = true
        })
        
        CATransaction.begin()
        tableView.beginUpdates()
        myCell.isActive = true
        tableView.endUpdates()
        CATransaction.commit()
    }
}
