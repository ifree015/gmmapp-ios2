//
//  JavascriptInterface.swift
//  GmmApp
//
//  Created by GwangHyeok Yu on 2023/03/24.
//

import Foundation
import WebKit

class JavascriptBridge {
    static let deviceInfo = DeviceInformation()
    
    static func createWKUserContentController(messageHandler: WKScriptMessageHandler) -> WKUserContentController {
        let contentController = WKUserContentController()
        contentController.add(messageHandler, name: "getAppName")
        contentController.add(messageHandler, name: "getAppInfo")
        contentController.add(messageHandler, name: "getPhoneNumber")
        contentController.add(messageHandler, name: "isPermission")
        contentController.add(messageHandler, name: "getLastKnownLocation")
        contentController.add(messageHandler, name: "setThemeMode")
        
        return contentController
    }
    
}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let data = message.body as? [String: Any], let guid = data["guid"] as? String else {
            return
        }
        debug("messageName: \(message.name), data: \(data)")
        
        switch message.name {
        case "getAppName":
            executePromise(guid: guid, data: "AppName")
        case "getAppInfo":
            let appInfo: AppInfo = .init(mblInhrIdnnVal: JavascriptBridge.deviceInfo.getDeviceId(),
                                         deviceModel: JavascriptBridge.deviceInfo.getDeviceModel(),
                                         mbphOsVer: String(format: "iOS %@", JavascriptBridge.deviceInfo.getOsVersion()),
                                         moappVerCd: JavascriptBridge.deviceInfo.getAppVersionCode(),
                                         moappVer: JavascriptBridge.deviceInfo.getAppVersionName(),
                                         pushTknVal: JavascriptBridge.deviceInfo.getRegistrationToken())
            do {
                let jsonData = try JSONEncoder().encode(appInfo)
                executePromise(guid: guid, data: String(data: jsonData, encoding: .utf8)!)
            } catch {
                log(error.localizedDescription)
                executePromise(guid: guid)
            }
        case "getPhoneNumber":
            debug(guid)
        case "isPermission":
            debug(guid)
        case "getLastKnownLocation":
            let location: [String: Any] = [
                "mblInhrIdnnVal": JavascriptBridge.deviceInfo.getDeviceId(),
                "deviceModel": JavascriptBridge.deviceInfo.getDeviceModel(),
            ]
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: location)
                executePromise(guid: guid, data: String(data: jsonData, encoding: .utf8)!)
            } catch {
                log(error.localizedDescription)
                executePromise(guid: guid)
            }
        case "setThemeMode":
            let mode = data["data"] as? String
            debug("mode: \(mode!)")
            UserDefaults.standard.set(mode, forKey: "Appearance")
            self.updateUserInterfaceStyle()
        default:
            log("not matched message")
        }
    }
    
    func executePromise(guid: String, data: String = "") {
        let execString = String(format: "promiseNativeCaller.executePromise('%@', %@)", guid, (data.isEmpty ? "undefined" : "'\(data)'"))
        debug(execString)
        self.webView.evaluateJavaScript(execString) {
            (data, err) in
            if let err = err {
                log(err)
            }
        }
    }
}

struct AppInfo: Codable {
    var mblInhrIdnnVal: String
    var deviceModel: String
    var mblOsKndCd = "I"
    var mbphOsVer: String
    var moappVerCd: String
    var moappVer: String
    var pushTknVal: String?
}

extension UIColor {
    convenience init(red: CGFloat, green: CGFloat, blue: CGFloat) {
        self.init(red: red / 255.0, green: green / 255.0, blue: blue / 255.0, alpha: 1)
    }
}

extension ViewController {
    
    func updateUserInterfaceStyle() {
        guard let appearance = UserDefaults.standard.string(forKey: "Appearance") else { return }
        
        var window: UIWindow!
        if #available(iOS 15.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = windowScene.windows.first
            }
        }
        guard #available(iOS 15.0, *) else {
            window = UIApplication.shared.windows.first
        }
        
        if appearance == "light" {
            window.overrideUserInterfaceStyle = .light
            self.view.backgroundColor = UIColor.white
        } else if appearance == "dark" {
            window.overrideUserInterfaceStyle = .dark
            self.view.backgroundColor = UIColor(red: 18, green: 18, blue: 18) // #121212
        } else { // system
            window.overrideUserInterfaceStyle = .unspecified
            if self.traitCollection.userInterfaceStyle == .dark {
                self.view.backgroundColor = UIColor(red: 18, green: 18, blue: 18)
            } else {
                self.view.backgroundColor = UIColor.white
            }
        }
    }
}
