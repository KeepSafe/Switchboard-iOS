//
//  TestAnalyticsProvider.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/21/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

struct TestAnalyticsProvider: SwitchboardAnalyticsProvider {

    let trackStartedExpectation = XCTestExpectation(description: "trackStarted")
    let trackCompletedExpectation = XCTestExpectation(description: "trackCompleted")
    let trackOnExperimentExpectation = XCTestExpectation(description: "trackOnExperiment")
    let trackOnFeatureExpectation = XCTestExpectation(description: "trackOnFeature")

    func entitled(experiments: Set<SwitchboardExperiment>, features: Set<SwitchboardFeature>) {
        // unhandled during tests
    }

    func trackStarted(for experiment: SwitchboardExperiment) {
        trackStartedExpectation.fulfill()
    }

    func trackCompleted(for experiment: SwitchboardExperiment) {
        trackCompletedExpectation.fulfill()
    }

    func track(event: String, for experiment: SwitchboardExperiment, properties: [String : Any]?) {
        trackOnExperimentExpectation.fulfill()
    }

    func track(event: String, for feature: SwitchboardFeature, properties: [String : Any]?) {
        trackOnFeatureExpectation.fulfill()
    }

}
