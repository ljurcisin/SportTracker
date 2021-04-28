//
//  RecordsViewController.swift
//  Sports
//
//  Created by Lubomir Jurcisin on 26/03/2020.
//  Copyright © 2020 Lubomir Jurcisin. All rights reserved.
//

import UIKit
import BetterSegmentedControl
import GoogleMaps

class ActivityRecordsTableViewController: UIViewController {

    private var table = UITableView(frame: CGRect(), style: .plain)
    private var mainView = UIView()
    private var segmentedControl: BetterSegmentedControl?
    private var mainViewWidthConstraint: NSLayoutConstraint?
    private var mainViewHalfWidthConstraint: NSLayoutConstraint?

    private var isInitialized = false

    var mapView = GMSMapView()
    var marker = GMSMarker()
    
    var activeDB: DBSetting = .local

    internal var selectedIndexPath: IndexPath? {
        didSet {
            table.beginUpdates()
            if isInitialized {
                if isLandscapeScreenOrientation() {
                    setLocation(on: selectedIndexPath)
                }
            }
            table.endUpdates()

        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let image = UIImage(named: "background"){
            self.view.backgroundColor = UIColor(patternImage: image)
        }

        view.addSubview(mainView)
        mainView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainView.topAnchor.constraint(equalTo: view.topAnchor),
            mainView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mainView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])

        mainViewWidthConstraint = NSLayoutConstraint(item: mainView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        mainViewHalfWidthConstraint = NSLayoutConstraint(item: mainView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.55, constant: 0)
        mainViewWidthConstraint?.isActive = true

        view.addSubview(mapView)
        mapView.isUserInteractionEnabled = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.leadingAnchor.constraint(equalTo: mainView.trailingAnchor)
        ])

        view.bringSubviewToFront(mainView)
        marker.map = mapView

        // Do any additional setup after loading the view.
        let topPoint = view.safeAreaInsets.top

        segmentedControl = BetterSegmentedControl(
            frame: CGRect(x: view.frame.width * 0.1, y: topPoint + 30, width: view.frame.width * 0.8, height: 40),
            segments: LabelSegment.segments(withTitles: ["Local", "Remote", "All"],
            normalFont: UIFont(name: "HelveticaNeue-Light", size: 15.0)!,
            normalTextColor: (UIColor(white: 0.8, alpha: 1)),
            selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 15.0)!,
            selectedTextColor: .white),
            index: activeDB.rawValue,
            options: [.backgroundColor(UIColor.init(white: 0.2, alpha: 0.6)),
                      .indicatorViewBackgroundColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)),
                      .cornerRadius(20.0),
                      .animationSpringDamping(1.0)])

        guard let segmentedControl = segmentedControl else { return }

        segmentedControl.addTarget(self, action: #selector(self.changeDB(_:)), for: .valueChanged)
        mainView.addSubview(segmentedControl)

        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.topAnchor, constant: 20),
            segmentedControl.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            segmentedControl.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            segmentedControl.heightAnchor.constraint(equalToConstant: 44)
        ])

        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .none
        table.separatorStyle = .none
        table.register(ActivityRecordsTableViewCell.self, forCellReuseIdentifier: ActivityRecordsTableViewCellID)

        mainView.addSubview(table)

        table.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10),
            table.bottomAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            table.leadingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.leadingAnchor, constant: 5.0),
            table.trailingAnchor.constraint(equalTo: mainView.safeAreaLayoutGuide.trailingAnchor, constant: -5.0)
        ])

        isInitialized = true
    }

    private func showMapDetail() {
        if isLandscapeScreenOrientation(),
            let constraint = self.mainViewHalfWidthConstraint,
            !constraint.isActive {
            UIView.animate(withDuration: 0.5) {
                self.mainViewWidthConstraint?.isActive = false
                self.mainViewHalfWidthConstraint?.isActive = true
                if self.selectedIndexPath == nil, self.tableView(self.table, numberOfRowsInSection: 0) > 0 {
                    self.selectedIndexPath = IndexPath(row: 0, section: 0)
                    self.table.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    self.table.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: false)
                }
            }
        } else if !isLandscapeScreenOrientation(),
            let constraint = self.mainViewWidthConstraint,
            !constraint.isActive {
            UIView.animate(withDuration: 0.5) {
                self.mainViewWidthConstraint?.isActive = true
                self.mainViewHalfWidthConstraint?.isActive = false
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showMapDetail()
        if let selectedIndexPath = selectedIndexPath, selectedIndexPath.row < self.tableView(table, numberOfRowsInSection: 0) {
            table.scrollToRow(at: selectedIndexPath, at: .bottom, animated: false)
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.showMapDetail()
            self.table.reloadSections(IndexSet(integer: 0), with: .left)
        }, completion: nil)
    }

    @objc private func changeDB(_ sender: BetterSegmentedControl) {
        let oldDB = activeDB
        activeDB = DBSetting(rawValue: sender.index) ?? .all

        let animation: UITableView.RowAnimation = activeDB.rawValue > oldDB.rawValue ? .left : .right
        table.reloadSections(IndexSet(integer: 0), with: animation)

        if let activeIndex = selectedIndexPath,
            let activeSportRecord = DbManager.get().getEntry(for: activeIndex.row, database: oldDB) {
            if let newIndex = DbManager.get().getIndex(of: activeSportRecord, in: activeDB) {
                selectedIndexPath = IndexPath(row: newIndex, section: 0)
                table.reloadRows(at: [selectedIndexPath!], with: .fade)
                table.scrollToRow(at: selectedIndexPath!, at: .bottom, animated: true)
            }
            else {
                selectedIndexPath = nil
            }

            if activeIndex.row < self.tableView(table, numberOfRowsInSection: 0) {
                table.reloadRows(at: [activeIndex], with: .fade)
            }

        }
        else {
            selectedIndexPath = nil
        }

        if selectedIndexPath == nil {
            if isLandscapeScreenOrientation(),
                self.tableView(self.table, numberOfRowsInSection: 0) > 0 {
                self.selectedIndexPath = IndexPath(row: 0, section: 0)
                self.table.reloadRows(at: [self.selectedIndexPath!], with: .fade)
                self.table.scrollToRow(at: self.selectedIndexPath!, at: .bottom, animated: true)
            }
            else {
                table.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: true)
            }
        }
    }

    private func setLocation(on index: IndexPath?) {
        if let index = index, let entry = DbManager.get().getEntry(for: index.row, database: activeDB) {
            setLocation(for: entry)
        }
        else {
            setLocation(for: nil)
        }
    }

    private func setLocation(for entry: ActivityRecordDataModel?) {
        if let entry = entry {
            self.marker.map = self.mapView
            DbManager.get().getCoordinates(for: entry) { (coordinates: CLLocationCoordinate2D?) in
                if let coordinates = coordinates {
                    let newCamera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 16)
                    self.mapView.animate(to: newCamera)
                    self.marker.position = coordinates

                }
            }
        }
        else {
            let newCamera = GMSCameraPosition.camera(withTarget: CLLocationCoordinate2D(), zoom: 0)
            self.mapView.animate(to: newCamera)
            self.marker.map = nil
        }
    }

    private func isLandscapeScreenOrientation() -> Bool {
        //UIDevice.current.orientation.isLandscape { returns .unknown, bug in simulator?
        return UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height
    }
}

extension ActivityRecordsTableViewController: DbManagerDelegate {

    func cloudEntryAdded(_ newEntry: ActivityRecordDataModel) {
        var indexInAll: Int? = 0
        guard let index = DbManager.get().getIndex(of: newEntry, indexInAll: &indexInAll) else { return }
        guard let indexAll = indexInAll else { return }
        var newIndexPath: IndexPath?

        if activeDB == .local {
            newIndexPath = IndexPath(row: index , section: 0)
            if let segmentedControl = segmentedControl {
                segmentedControl.setIndex(1)
            }
            else {
                activeDB = .remote
            }
        }
        else {
            newIndexPath = IndexPath(row: activeDB == .remote ? index : indexAll , section: 0)
            if isInitialized {
                table.insertRows(at: [newIndexPath!], with: .fade)
            }
        }

        selectedIndexPath = newIndexPath
        if isInitialized {
            table.selectRow(at: newIndexPath!, animated: true, scrollPosition: .bottom)
            table.scrollToRow(at: newIndexPath!, at: .bottom, animated: false)
        }
    }

    func localEntryAdded(_ newEntry: ActivityRecordDataModel) {
        var indexInAll: Int? = 0
        guard let index = DbManager.get().getIndex(of: newEntry, indexInAll: &indexInAll) else { return }
        guard let indexAll = indexInAll else { return }
        let newIndexPath: IndexPath?

        if activeDB == .remote {
            newIndexPath = IndexPath(row: index , section: 0)
            if let segmentedControl = segmentedControl {
                segmentedControl.setIndex(0)
            }
            else {
                activeDB = .local
            }
        }
        else {
            newIndexPath = IndexPath(row: activeDB == .local ? index : indexAll , section: 0)
            if isInitialized {
                table.insertRows(at: [newIndexPath!], with: .fade)
            }
        }
        selectedIndexPath = newIndexPath
        if isInitialized {
            table.selectRow(at: newIndexPath, animated: true, scrollPosition: .bottom)
            table.scrollToRow(at: newIndexPath!, at: .bottom, animated: false)
        }
    }
}

extension ActivityRecordsTableViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if activeDB == .local {
            return DbManager.get().localEntries.count
        }
        else if activeDB == .remote {
            return DbManager.get().cloudEntries.count
        }
        else {
            return DbManager.get().allEntries.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RecordTableViewCell") as? ActivityRecordsTableViewCell else {
            return UITableViewCell()
        }

        if let record = DbManager.get().getEntry(for: indexPath.row, database: activeDB) {
            cell.setData(with: record)
            if indexPath == selectedIndexPath {
                cell.isActive = true
            }
            return cell
        }

        return UITableViewCell()
    }

}

extension ActivityRecordsTableViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let index = selectedIndexPath,
            index == indexPath,
            !isLandscapeScreenOrientation() {
            return 310
        }

        return 110
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if let index = selectedIndexPath,
            let myCell = tableView.cellForRow(at: index) as? ActivityRecordsTableViewCell {

            if indexPath == index {
                return nil
            }

            myCell.isActive = false
            selectedIndexPath = nil
        }

        return indexPath
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let myCell = tableView.cellForRow(at: indexPath) as? ActivityRecordsTableViewCell else {
            return
        }

        //check for horizontal orientation
        if isLandscapeScreenOrientation() {
            myCell.isActive = true
            selectedIndexPath = indexPath
        }
        else {

            if myCell.isActive {
                myCell.isActive = false
                selectedIndexPath = nil
            }
            else {

                myCell.isActive = true

                CATransaction.begin()
                selectedIndexPath = indexPath
                CATransaction.commit()
            }
        }
    }

}
