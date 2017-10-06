//
//  SwitchboardCacheTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardCacheTests: XCTestCase {

    // MARK: - Shared

    static let expName = "exp"
    static let featureName = "feature"
    let exp = SwitchboardExperiment(name: expName, values: ["cohort": "yay"])!
    let feature = SwitchboardFeature(name: featureName)!

    // MARK: - Setup

    override func setUp() {
        SwitchboardCache.clear()
    }

    // MARK: - Default Implementations

    // This tests clearing, restoring, and caching
    func testCachingExperimentsAndFeatures() {
        // Ensure it's empty first
        var (experiments, features) = SwitchboardCache.restoreFromCache()

        XCTAssertNil(experiments)
        XCTAssertNil(features)

        // Cache and see if it's saved
        SwitchboardCache.cache(experiments: [exp], features: [feature])
        (experiments, features) = SwitchboardCache.restoreFromCache()
        XCTAssertTrue(experiments?.isEmpty == false)
        XCTAssertTrue(features?.isEmpty == false)

        XCTAssertTrue(experiments?.first?.name == SwitchboardCacheTests.expName)
        XCTAssertTrue(features?.first?.name == SwitchboardCacheTests.featureName)

        // Clear it and verify
        SwitchboardCache.clear()
        (experiments, features) = SwitchboardCache.restoreFromCache()

        XCTAssertNil(experiments)
        XCTAssertNil(features)
    }

    // This tests clearing, restoring, and caching
    func testNamespacedCachingExperimentsAndFeatures() {
        let namespace = "namespaceForPath"

        // Ensure it's empty first
        var (experiments, features) = SwitchboardCache.restoreFromCache(namespace: namespace)

        XCTAssertNil(experiments)
        XCTAssertNil(features)

        // Cache and see if it's saved
        SwitchboardCache.cache(experiments: [exp], features: [feature], namespace: namespace)
        (experiments, features) = SwitchboardCache.restoreFromCache(namespace: namespace)
        XCTAssertTrue(experiments?.isEmpty == false)
        XCTAssertTrue(features?.isEmpty == false)

        XCTAssertTrue(experiments?.first?.name == SwitchboardCacheTests.expName)
        XCTAssertTrue(features?.first?.name == SwitchboardCacheTests.featureName)

        // Clear it and verify
        SwitchboardCache.clear(namespace: namespace)
        (experiments, features) = SwitchboardCache.restoreFromCache(namespace: namespace)

        XCTAssertNil(experiments)
        XCTAssertNil(features)
    }

}
