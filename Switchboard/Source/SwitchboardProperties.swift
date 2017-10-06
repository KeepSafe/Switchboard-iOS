//
//  SwitchboardProperties.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/21/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public struct SwitchboardPropertyKeys {
    static let osMajorVersion = "os_major_version"
    static let osVersion = "os_version"
    static let device = "device"
    static let lang = "lang"
    static let manufacturer = "manufacturer"
    static let country = "country"
    static let appId = "appId"
    static let version = "version"
    static let build = "build"
}

open class SwitchboardProperties {

    // MARK: - Public Properties

    open static var defaults: [String: Any] {
        let parameters: [String: Any] = [
            SwitchboardPropertyKeys.osMajorVersion: ProcessInfo().operatingSystemVersion.majorVersion,
            SwitchboardPropertyKeys.osVersion: UIDevice.current.systemVersion,
            SwitchboardPropertyKeys.device: UIDevice.current.model,
            SwitchboardPropertyKeys.lang: Locale.preferredLanguages[0],
            SwitchboardPropertyKeys.manufacturer: "Apple",
            SwitchboardPropertyKeys.country: Locale.current.regionCode ?? unknown,
            SwitchboardPropertyKeys.appId: bundleIdentifier,
            SwitchboardPropertyKeys.version: versionName,
            SwitchboardPropertyKeys.build: buildName
        ]
        return parameters
    }

    // MARK: - Private Properties

    fileprivate static var versionName: String { return bundleValue(for: "CFBundleShortVersionString") }
    fileprivate static var buildName: String { return bundleValue(for: "CFBundleVersion") }
    fileprivate static var bundleIdentifier: String { return bundleValue(for: "CFBundleIdentifier") }
    fileprivate static let unknown = "unknown"

}

// MARK: - Private API

fileprivate extension SwitchboardProperties {

    static func bundleValue(for key: String) -> String {
        return Bundle.main.object(forInfoDictionaryKey: key) as? String ?? unknown
    }

}
