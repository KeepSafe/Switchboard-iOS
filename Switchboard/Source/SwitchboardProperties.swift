//
//  SwitchboardProperties.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/21/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public struct SwitchboardPropertyKeys {
    public static let osMajorVersion = "os_major_version"
    public static let osVersion = "os_version"
    public static let device = "device"
    public static let lang = "lang"
    public static let manufacturer = "manufacturer"
    public static let country = "country"
    public static let appId = "appId"
    public static let version = "version"
    public static let build = "build"
    public static let uuid = "uuid"
}

open class SwitchboardProperties {

    // MARK: - Public Properties

    open static func defaults(withUuid uuid: String) -> [String: Any] {
        let parameters: [String: Any] = [
            SwitchboardPropertyKeys.uuid: uuid,
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
