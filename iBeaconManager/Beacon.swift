//
//  Beacon.swift
//  iBeaconManager
//
//  Created by Masashi Tanaka on 2017/03/10.
//  Copyright © 2017年 Masashi Tanaka. All rights reserved.
//

import RealmSwift

final class Beacon: Object {

    dynamic internal var id: Int = 0
    dynamic internal var uuidString: String?
    internal let major = RealmOptional<Int>()
    internal let minor = RealmOptional<Int>()

    override static func primaryKey() -> String? {
        return "id"
    }

}
