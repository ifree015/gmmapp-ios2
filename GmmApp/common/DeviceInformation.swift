//
//  DeviceInformation.swift
//  GmmApp
//
//  Created by GwangHyeok Yu on 2023/03/21.
//

import Foundation

import UIKit

enum DeviceInformation {
    
    static func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
}
