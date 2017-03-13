//
//  BeaconModel.swift
//  iBeaconManager
//
//  Created by Masashi Tanaka on 2017/02/20.
//  Copyright © 2017年 Masashi Tanaka All rights reserved.
//

import CoreLocation

class BeaconModel {
    
    internal var id: Int
    internal var uuidString: String?
    internal var major: Int?
    internal var minor: Int?
    private let measuredPower: Int8 = -60
    internal var isOn = false
    
    init(id: Int, uuidString: String?, major: Int?, minor: Int?) {
        self.id = id
        self.uuidString = uuidString
        self.major = major
        self.minor = minor
    }
    
    // MARK: Internal

    internal func advertisement() -> [String: Any]? {
        guard let uuidString = self.uuidString else { return nil }
        guard let proximityUUID = NSUUID.init(uuidString: uuidString) else { return nil }

        let major = UInt16(self.major ?? 1)
        let minor = UInt16(self.minor ?? 1)
        
        var buffer = [CUnsignedChar](repeating: 0, count: 21)
        proximityUUID.getBytes(&buffer)
        buffer[16] = CUnsignedChar(major >> 8)
        buffer[17] = CUnsignedChar(major & 255)
        buffer[18] = CUnsignedChar(minor >> 8)
        buffer[19] = CUnsignedChar(minor & 255)
        buffer[20] = CUnsignedChar(bitPattern: measuredPower)
        
        let data = Data(bytes: buffer, count: buffer.count)
        
        return ["kCBAdvDataAppleBeaconKey": data]
    }
}
