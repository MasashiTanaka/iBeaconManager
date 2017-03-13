//
//  ViewController.swift
//  iBeaconManager
//
//  Created by Masashi Tanaka on 2017/02/17.
//  Copyright © 2017年 Masashi Tanaka All rights reserved.
//

import Cocoa
import CoreLocation
import CoreBluetooth
import RealmSwift

class ViewController: NSViewController {
    
    fileprivate enum CellIdentifier: String {
        case cellUUID = "CellUUID"
        case cellMajor = "CellMajor"
        case cellMinor = "CellMinor"
        case cellToggle = "CellToggle"
    }
    
    @IBOutlet weak private var tableView: NSTableView!
    @IBOutlet weak private var tableHeaderView: NSTableHeaderView!
    
    private let beaconAccessor = BeaconAccessor()
    fileprivate var beacons: [BeaconModel] = []
    fileprivate var peripheralManager: CBPeripheralManager!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
    }

    // MARK: Private

    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(willTerminateNotification(_:)), name: Notification.Name.NSApplicationWillTerminate, object: nil)
        
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        self.setupTableView()
        self.setupBeaconObjects()
        
        self.tableView.reloadData()
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsColumnSelection = false
    }
    
    private func setupBeaconObjects() {
        let beaconEntities = self.beaconAccessor.getAll()
        
        beaconEntities.forEach {
            let beacon = BeaconModel(id: $0.id, uuidString: $0.uuidString, major: $0.major.value, minor: $0.minor.value)
            self.beacons.append(beacon)
        }
    }

    // MARK: Fileprivate
    
    fileprivate func cellValue(row: Int, cellIdentifier: CellIdentifier) -> Any? {
        let beacon = self.beacons[row]
        
        switch cellIdentifier {
        case .cellUUID:
            return beacon.uuidString
        case .cellMajor:
            return beacon.major
        case .cellMinor:
            return beacon.minor
        case .cellToggle:
            return beacon.isOn
        }
    }
    
    // MARK: Internal
    
    internal func willTerminateNotification(_ notification: Notification) {
        self.beaconAccessor.white(self.beacons)
    }
    
}

// MARK: - NSTableViewDataSource

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.beacons.count
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        guard let tableColumn = tableColumn else { return }
        guard let identifier = CellIdentifier.init(rawValue: tableColumn.identifier) else { return }
        
        let beacon = self.beacons[row]
        
        switch identifier {
        case .cellUUID:
            beacon.uuidString = object as? String
        case .cellMajor:
            if let value = object as? String {
                beacon.major = Int(value)
            } else {
                beacon.major = nil
            }
        case .cellMinor:
            if let value = object as? String {
                beacon.minor = Int(value)
            } else {
                beacon.minor = nil
            }
        case .cellToggle:
            let isOn = object as? Bool ?? false
            
            if !isOn && beacon.isOn {
                self.peripheralManager.stopAdvertising()
            }

            beacon.isOn = isOn
        }
        
        guard identifier == .cellToggle else { return }
        guard object as? Bool == true else { return }

        self.beacons.forEach {
            $0.isOn = false
        }

        guard let advertisement =  beacon.advertisement() else {
            // UUIDが未入力の場合の処理
            tableView.reloadData()

            return
        }
        
        beacon.isOn = true
        tableView.reloadData()

        self.peripheralManager.stopAdvertising()
        self.peripheralManager.startAdvertising(advertisement)
    }

}

// MARK: - NSTableViewDelegate

extension ViewController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let identifier = tableColumn?.identifier else { return nil }
        guard let cellIdentifier = CellIdentifier.init(rawValue: identifier) else { return nil }
        
        return self.cellValue(row: row, cellIdentifier: cellIdentifier)
    }
    
}

extension ViewController: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        // エラー処理
        if peripheral.state != .poweredOn {
        }
    }

}
