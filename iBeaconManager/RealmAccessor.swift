//
//  RealmAccessor.swift
//  iBeaconManager
//
//  Created by Masashi Tanaka on 2017/03/10.
//  Copyright © 2017年 Masashi Tanaka. All rights reserved.
//

import RealmSwift

// MARK: - RealmAccessor

class RealmAccessor {
    
    fileprivate let realm = try! Realm() // swiftlint:disable:this force_try

    internal func get<T: Object>(_ type: T.Type, predicate: NSPredicate) -> T? {
        return self.realm.objects(type).filter(predicate).first
    }
}

// MARK: - BeaconAccessor

class BeaconAccessor: RealmAccessor {

    internal func initializeData() -> Results<Beacon> {
        var beacons: [Beacon] = []
        
        for i in 0..<5 {
            let beacon = Beacon()
            beacon.id = i
            beacons.append(beacon)
        }
        
        self.white(beacons)
        
        return self.getAll()
    }
    
    internal func getAll() -> Results<Beacon> {
        var beacons = self.realm.objects(Beacon.self)
        
        if beacons.count == 0 {
            beacons = self.initializeData()
        }
        
        return beacons
    }
    
    internal func white(_ beacons: [Beacon]) {
        do {
            try self.realm.write {
                self.realm.add(beacons)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    internal func white(_ beacons: [BeaconModel]) {
        do {
            try self.realm.write {
                beacons.forEach {
                    let predicate = NSPredicate(format: "id == %d", $0.id)

                    if let beacon = self.get(Beacon.self, predicate: predicate) {
                        beacon.uuidString = $0.uuidString
                        beacon.major.value = $0.major
                        beacon.minor.value = $0.minor
                    }
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
}
