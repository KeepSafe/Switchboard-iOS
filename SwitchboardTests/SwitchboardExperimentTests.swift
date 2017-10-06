//
//  SwitchboardExperimentTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/18/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardExperimentTests: XCTestCase {

    // MARK: - Shared

    let exp1 = SwitchboardExperiment(name: "exp1", values: ["cohort": "yay"])!
    let exp2 = SwitchboardExperiment(name: "exp2", values: ["cohort": "yay2"])!

    // MARK: - Setup

    override func setUp() {
        exp1.clearState()
        exp2.clearState()

        exp1.clearDependencies()
        exp2.clearDependencies()
    }

    // MARK: - Instantiation

    func testInstantiationRequiresCohort() {
        let exp = SwitchboardExperiment(name: "noCohortGiven", values: ["no": "cohort"])
        XCTAssertNil(exp, "Should return a nil instance if no cohort is given")
    }

    func testInstantiationWithCohortSucceeds() {
        let exp = SwitchboardExperiment(name: "cohortGiven", values: ["cohort": "yay"])
        XCTAssertNotNil(exp, "Should return a non-nil instance since cohort is given")
    }

    func testInstantiatingArray() {
        // Two experiments and one feature should gives us two experiments
        // since it filters out the feature
        let jsonDict = [
            "exp1": ["isActive": true, "values": ["cohort": "yay1"]],
            "exp2": ["isActive": true, "values": ["cohort": "yay2"]],
            "feature": ["isActive": true, "values": ["thisIsAFeature": "noCohort"]]
        ]

        let instances = Array(SwitchboardExperimentFactory.from(json: jsonDict))
        XCTAssertEqual(instances.count, 2)
        XCTAssertTrue(instances.filter({ $0.name == "exp1" }).count == 1)
        XCTAssertTrue(instances.filter({ $0.name == "exp2" }).count == 1)
    }

    func testInstantiatingArrayRequiresValues() {
        // Experiments must have a valid values dictionary
        let jsonDict: [String: Any] = [
            "exp1": ["isActive": true, "values": nil],
            "exp2": ["isActive": true, "values": ["cohort": "yay2"]],
        ]

        let instances = SwitchboardExperimentFactory.from(json: jsonDict)
        XCTAssertEqual(instances.count, 1)
        XCTAssertTrue(instances.first?.name == "exp2")
    }

    func testInstantiatingArrayOfActiveAndInactiveExperiments() {
        // Experiments must be active
        let jsonDict = [
            "exp1": ["isActive": false, "values": ["cohort": "yay"]],
            "exp2": ["isActive": true, "values": ["cohort": "yay2"]],
            ]

        var instances = SwitchboardExperimentFactory.from(json: jsonDict)
        XCTAssertEqual(instances.count, 1)
        XCTAssertTrue(instances.first?.name == "exp2")

        instances = SwitchboardExperimentFactory.from(json: jsonDict, active: false)
        XCTAssertEqual(instances.count, 1)
        XCTAssertTrue(instances.first?.name == "exp1")
    }

    // MARK: - Properties

    func testNameProperty() {
        XCTAssertTrue(exp1.name == "exp1")
    }

    func testCohortProperty() {
        XCTAssertTrue(exp1.cohort == "yay")
    }

    func testValuesProperty() {
        let expValues = SwitchboardExperiment(name: "exp1", values: ["cohort": "yay", "prop1": "value"])
        XCTAssertTrue(expValues?.values["prop1"] as? String == "value")
    }

    func testCanBeStartedProperty() {
        // Note: we'll test how dependencies impact this further down
        XCTAssertTrue(exp1.canBeStarted)

        // Now start it and verify false
        XCTAssertTrue(exp1.start())
        XCTAssertFalse(exp1.canBeStarted)

        // Now complete it and verify false
        XCTAssertTrue(exp1.complete())
        XCTAssertFalse(exp1.canBeStarted)
    }

    func testPreventFromStartingClosure() {
        let switchboard = Switchboard()
        let expName = "exp1"
        let expPrevention = SwitchboardExperiment(name: expName, values: ["cohort": "yay"], switchboard: switchboard)!
        XCTAssertTrue(expPrevention.canBeStarted)

        // Add some conditional logic
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName == expName // prevent it
        }
        XCTAssertFalse(expPrevention.canBeStarted)

        // Change the logic
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName != expName // allow only this one
        }
        XCTAssertTrue(expPrevention.canBeStarted)

        switchboard.preventExperimentFromStarting = nil
        XCTAssertTrue(expPrevention.canBeStarted)
    }

    func testIsEntitledProperty() {
        XCTAssertTrue(exp1.isEntitled)

        // Now start it and verify false
        XCTAssertTrue(exp1.start())
        XCTAssertFalse(exp1.isEntitled)

        // Now complete it and verify false
        XCTAssertTrue(exp1.complete())
        XCTAssertFalse(exp1.isEntitled)
    }

    func testShouldTrackAnalyticsProperty() {
        let expWithAnalytics = SwitchboardExperiment(name: "expWithAnalytics", values: ["cohort": "yay"])!
        XCTAssertTrue(expWithAnalytics.shouldTrackAnalytics)

        let expWithoutAnalytics = SwitchboardExperiment(name: "expWithoutAnalytics", values: ["cohort": "yay", "disable_analytics": true])!
        XCTAssertFalse(expWithoutAnalytics.shouldTrackAnalytics)
    }

    func testisActiveProperty() {
        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.isActive)

        // Now complete it and make sure it's false
        XCTAssertTrue(exp1.complete())
        XCTAssertFalse(exp1.isActive)
    }

    func testCanBeCompletedProperty() {
        XCTAssertFalse(exp1.canBeCompleted)
        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.isActive)
        XCTAssertTrue(exp1.canBeCompleted)

        // Now complete it and make sure it's false
        XCTAssertTrue(exp1.complete())
        XCTAssertFalse(exp1.canBeCompleted)
    }

    func testIsCompletedProperty() {
        XCTAssertFalse(exp1.isCompleted)
        XCTAssertTrue(exp1.start())
        XCTAssertFalse(exp1.isCompleted)
        XCTAssertTrue(exp1.complete())
        XCTAssertTrue(exp1.isCompleted)
    }

    func testDependenciesProperty() {
        exp2.add(dependency: exp1)
        XCTAssertTrue(exp2.dependencies.first == exp1)
    }

    // MARK: - State

    func testClearingState() {
        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.isActive)
        exp1.clearState()
        XCTAssertFalse(exp1.isActive)

        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.complete())
        XCTAssertTrue(exp1.isCompleted)
        exp1.clearState()
        XCTAssertFalse(exp1.isCompleted)
    }

    func testCompletingTwiceDoesNothing() {
        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.complete())
        XCTAssertTrue(exp1.isCompleted)
        XCTAssertFalse(exp1.complete())
        exp1.clearState()
        XCTAssertFalse(exp1.isCompleted)
    }

    // MARK: - Analytics

    func testStartingCallsAnalytics() {
        let analytics = TestAnalyticsProvider()
        let expWithAnalytics = SwitchboardExperiment(name: "expWithAnalytics", values: ["cohort": "yay"], analytics: analytics)!

        XCTAssertTrue(expWithAnalytics.start())
        wait(for: [analytics.trackStartedExpectation], timeout: 5)

        expWithAnalytics.clearState()
    }

    func testCompletingCallsAnalytics() {
        let analytics = TestAnalyticsProvider()
        let expWithAnalytics = SwitchboardExperiment(name: "expWithAnalytics", values: ["cohort": "yay"], analytics: analytics)!

        XCTAssertTrue(expWithAnalytics.start())
        XCTAssertTrue(expWithAnalytics.complete())
        wait(for: [analytics.trackCompletedExpectation], timeout: 5)

        expWithAnalytics.clearState()
    }

    func testTrackEvent() {
        let analytics = TestAnalyticsProvider()
        let expWithAnalytics = SwitchboardExperiment(name: "expWithAnalytics", values: ["cohort": "yay"], analytics: analytics)!

        expWithAnalytics.track(event: "testing")
        wait(for: [analytics.trackOnExperimentExpectation], timeout: 5)
    }

    // MARK: - Dependencies

    func testAddingDependency() {
        exp2.add(dependency: exp1)
        XCTAssertTrue(exp2.dependencies.first == exp1)
    }

    func testRemovingDependency() {
        exp2.add(dependency: exp1)
        XCTAssertTrue(exp2.dependencies.first == exp1)

        exp2.remove(dependency: exp1)
        XCTAssertNil(exp2.dependencies.first)
    }

    func testClearingDependencies() {
        exp2.add(dependency: exp1)
        XCTAssertTrue(exp2.dependencies.first == exp1)

        exp2.clearDependencies()
        XCTAssertNil(exp2.dependencies.first)
    }

    func testDependencyPreventsExecution() {
        exp2.add(dependency: exp1)

        XCTAssertFalse(exp2.canBeStarted)
        XCTAssertFalse(exp2.start())
    }

    func testFulfilledDependencyAllowsExecution() {
        exp2.add(dependency: exp1)

        XCTAssertFalse(exp2.canBeStarted)
        XCTAssertFalse(exp2.start())

        // Fulfill the dependency
        XCTAssertTrue(exp1.start())
        XCTAssertTrue(exp1.complete())

        XCTAssertTrue(exp2.canBeStarted)
        XCTAssertTrue(exp2.start())
    }

    // MARK: - Equality

    func testEqualityWorks() {
        let equal1 = SwitchboardExperiment(name: "exp1", values: ["cohort": "yay"])
        let equal2 = SwitchboardExperiment(name: "exp1", values: ["cohort": "yay"])
        XCTAssertNotNil(equal1)
        XCTAssertNotNil(equal2)
        XCTAssertTrue(equal1 == equal2)

        let exp3 = SwitchboardExperiment(name: "exp3", values: ["cohort": "yay"])
        let exp4 = SwitchboardExperiment(name: "exp4", values: ["cohort": "yay"])
        XCTAssertNotNil(exp3)
        XCTAssertNotNil(exp4)
        XCTAssertTrue(exp3 != exp4)

        // Old style
        XCTAssertFalse(equal1?.isEqual("notAnExperiment") == true)
    }

    // MARK: - Hashable

    func testHashableWorks() {
        var setOfExperiments = Set<SwitchboardExperiment>()
        let equal1 = SwitchboardExperiment(name: "exp1", values: ["cohort": "yay"])!
        let equal2 = SwitchboardExperiment(name: "exp2", values: ["cohort": "yay"])!
        setOfExperiments.insert(equal1)
        XCTAssertTrue(setOfExperiments.contains(equal1))
        XCTAssertFalse(setOfExperiments.contains(equal2))
    }

}
