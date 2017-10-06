//
//  SwitchboardFeatureTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardFeatureTests: XCTestCase {

    // MARK: - Shared

    let feature1 = SwitchboardFeature(name: "feature1")!

    // MARK: - Instantiation

    func testInstantiationRequiresNoCohort() {
        let feature = SwitchboardFeature(name: "cohortGiven", values: ["cohort": "shouldBeNil"])
        XCTAssertNil(feature, "Should return a nil instance if a cohort is given")
    }

    func testInstantiationWithoutCohortSucceeds() {
        let feature = SwitchboardFeature(name: "noChortGiven")
        XCTAssertNotNil(feature, "Should return a non-nil instance since no cohort is given")
    }

    func testInstantiatingArrayOfActiveAndInactiveFeatures() {
        // Two features and one experiment should gives us two features
        // since it filters out the experiment
        let jsonDict = [
            "feature1": ["isActive": true],
            "feature2": ["isActive": true, "values": [:]],
            "feature3": ["isActive": false],
            "exp": ["isActive": true, "values": ["cohort": "yay"]]
        ]

        var instances = Array(SwitchboardFeatureFactory.from(json: jsonDict))
        XCTAssertEqual(instances.count, 2)
        XCTAssertTrue(instances.filter({ $0.name == "feature1" }).count == 1)
        XCTAssertTrue(instances.filter({ $0.name == "feature2" }).count == 1)

        instances = Array(SwitchboardFeatureFactory.from(json: jsonDict, active: false))
        XCTAssertEqual(instances.count, 1)
        XCTAssertTrue(instances.filter({ $0.name == "feature3" }).count == 1)
    }

    func testInstantiatingArrayRequiresIsActive() {
        // Features must be active
        let jsonDict = [
            "feature1": ["isActive": false],
            "feature2": ["isActive": true],
            ]

        let instances = SwitchboardFeatureFactory.from(json: jsonDict)
        XCTAssertEqual(instances.count, 1)
        XCTAssertTrue(instances.first?.name == "feature2")
    }

    // MARK: - Properties

    func testNameProperty() {
        XCTAssertTrue(feature1.name == "feature1")
    }

    func testValuesProperty() {
        let featureValues = SwitchboardFeature(name: "featureValues", values: ["prop1": "value"])
        XCTAssertTrue(featureValues?.values?["prop1"] as? String == "value")

        let featureNoValues = SwitchboardFeature(name: "featureValues")
        XCTAssertNil(featureNoValues?.values)
    }

    func testShouldTrackAnalyticsProperty() {
        let featureWithAnalytics = SwitchboardFeature(name: "featureWithAnalytics")!
        XCTAssertTrue(featureWithAnalytics.shouldTrackAnalytics)

        let featureWithoutAnalytics = SwitchboardFeature(name: "featureWithoutAnalytics", values: ["disable_analytics": true])!
        XCTAssertFalse(featureWithoutAnalytics.shouldTrackAnalytics)
    }

    // MARK: - Analytics

    func testTrackEvent() {
        let analytics = TestAnalyticsProvider()
        let featureWithAnalytics = SwitchboardFeature(name: "featureWithAnalytics", analytics: analytics)!

        featureWithAnalytics.track(event: "testing")
        wait(for: [analytics.trackOnFeatureExpectation], timeout: 5)
    }

    // MARK: - Equality

    func testEqualityWorks() {
        let equal1 = SwitchboardFeature(name: "feature1")
        let equal2 = SwitchboardFeature(name: "feature1")
        XCTAssertNotNil(equal1)
        XCTAssertNotNil(equal2)
        XCTAssertTrue(equal1 == equal2)

        let feature3 = SwitchboardFeature(name: "feature3")
        let feature4 = SwitchboardFeature(name: "feature4")
        XCTAssertNotNil(feature3)
        XCTAssertNotNil(feature4)
        XCTAssertTrue(feature3 != feature4)


        // Old style
        XCTAssertFalse(equal1?.isEqual("notAFeature") == true)
    }

    // MARK: - Hashable

    func testHashableWorks() {
        var setOfFeatures = Set<SwitchboardFeature>()
        let equal1 = SwitchboardFeature(name: "feature1")!
        let equal2 = SwitchboardFeature(name: "feature2")!
        setOfFeatures.insert(equal1)
        XCTAssertTrue(setOfFeatures.contains(equal1))
        XCTAssertFalse(setOfFeatures.contains(equal2))
    }

}
