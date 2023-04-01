//
//  DeviceInformation.swift
//  GmmApp
//
//  Created by GwangHyeok Yu on 2023/03/21.
//

import Foundation

import UIKit

struct DeviceInformation {
    
    func getDeviceId() -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    func getDeviceModel() -> String {
        // 1. 시뮬레이터 체크 수행
        if let modelName = ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"], modelName.count > 0 {
            return modelName
        }
        
        // 2. 실제 디바이스 체크 수행
        let selector = NSSelectorFromString("_\("deviceInfo")ForKey:")
        guard UIDevice.current.responds(to: selector) else {
            return ""
        }
        log("real device")
        return UIDevice.current.model
        //return String(describing: UIDevice.current.perform(selector, with: "marketing-name").takeRetainedValue())
    }
    
    func getOsVersion() -> String {
        return UIDevice.current.systemVersion
    }
    
    func getAppVersionCode() -> String {
      if let info: [String: Any] = Bundle.main.infoDictionary, let buildNumber: String = info["CFBundleVersion"] as? String {
            return buildNumber
      }
      return ""
    }
    
    func getAppVersionName() -> String {
        if let info = Bundle.main.infoDictionary, let version = info["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    
    func getRegistrationToken() -> String? {
        return ""
    }
}
