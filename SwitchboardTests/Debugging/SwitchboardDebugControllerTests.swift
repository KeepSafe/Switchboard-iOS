//
//  SwitchboardDebugControllerTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 10/2/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardDebugControllerTests: XCTestCase {

    // MARK: - Active & Inactive

    func testActiveInactiveFeatures() {
        let switchboard = Switchboard()
        let featureName = "feature"
        let feature = SwitchboardFeature(name: featureName)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)

        func containsFeature(forActive: Bool) -> Bool {
            if forActive {
                return debugController.activeFeatures.contains(where: { $0.name == featureName })
            } else {
                return debugController.inactiveFeatures.contains(where: { $0.name == featureName })
            }
        }

        XCTAssertFalse(debugController.exists(feature: feature))

        debugController.activate(feature: feature)
        XCTAssertTrue(containsFeature(forActive: true))

        debugController.deactivate(feature: feature)
        XCTAssertFalse(containsFeature(forActive: true))
        XCTAssertTrue(containsFeature(forActive: false))

        debugController.toggle(feature: feature)
        XCTAssertTrue(containsFeature(forActive: true))
        XCTAssertFalse(containsFeature(forActive: false))

        debugController.toggle(feature: feature)
        XCTAssertFalse(containsFeature(forActive: true))
        XCTAssertTrue(containsFeature(forActive: false))
    }

    func testActiveInactiveExperiments() {
        let switchboard = Switchboard()
        let expName = "exp"
        let experiment = SwitchboardExperiment(name: expName, cohort: "yay", switchboard: switchboard)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)

        func containsExperiment(forActive: Bool) -> Bool {
            if forActive {
                return debugController.activeExperiments.contains(where: { $0.name == expName })
            } else {
                return debugController.inactiveExperiments.contains(where: { $0.name == expName })
            }
        }

        XCTAssertFalse(debugController.exists(experiment: experiment))

        debugController.activate(experiment: experiment)
        XCTAssertTrue(containsExperiment(forActive: true))

        debugController.deactivate(experiment: experiment)
        XCTAssertFalse(containsExperiment(forActive: true))
        XCTAssertTrue(containsExperiment(forActive: false))

        debugController.toggle(experiment: experiment)
        XCTAssertTrue(containsExperiment(forActive: true))
        XCTAssertFalse(containsExperiment(forActive: false))

        debugController.toggle(experiment: experiment)
        XCTAssertFalse(containsExperiment(forActive: true))
        XCTAssertTrue(containsExperiment(forActive: false))
    }

    // MARK: - Feature Mutations

    func testDeleteFeature() {
        let switchboard = Switchboard()
        let featureName = "feature"
        let feature = SwitchboardFeature(name: featureName)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)

        debugController.activate(feature: feature)
        XCTAssertTrue(debugController.exists(feature: feature))
        debugController.delete(feature: feature)
        XCTAssertFalse(debugController.exists(feature: feature))
    }

    func testChangeFeatureValues() {
        let feature = SwitchboardFeature(name: "feature")!
        let debugController = SwitchboardDebugController(switchboard: Switchboard())
        XCTAssertNil(feature.values)
        debugController.change(values: ["valueChanged": true], for: feature)
        XCTAssertTrue((feature.values?["valueChanged"] as? Bool) == true)
    }

    // MARK: - Experiment Mutations

    func testDeleteExperiment() {
        let switchboard = Switchboard()
        let expName = "exp"
        let experiment = SwitchboardExperiment(name: expName, cohort: "yay", switchboard: switchboard)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)

        debugController.activate(experiment: experiment)
        XCTAssertTrue(debugController.exists(experiment: experiment))
        debugController.delete(experiment: experiment)
        XCTAssertFalse(debugController.exists(experiment: experiment))
    }

    func testChangeExperimentCohort() {
        let switchboard = Switchboard()
        let experiment = SwitchboardExperiment(name: "experiment", cohort: "hai", switchboard: switchboard)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)
        XCTAssertTrue(experiment.cohort == "hai")
        debugController.change(cohort: "there", experiment: experiment)
        XCTAssertTrue(experiment.cohort == "there")
    }

    func testChangeExperimentValues() {
        let switchboard = Switchboard()
        let experiment = SwitchboardExperiment(name: "experiment", cohort: "hai", switchboard: switchboard)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)
        XCTAssertNil(experiment.values["valueChanged"])
        debugController.change(values: ["valueChanged": true], for: experiment)
        XCTAssertTrue((experiment.values["valueChanged"] as? Bool) == true)
    }

    func testChangeExperimentAvailableCohorts() {
        let switchboard = Switchboard()
        let experiment = SwitchboardExperiment(name: "experiment", cohort: "hai", switchboard: switchboard)!
        let debugController = SwitchboardDebugController(switchboard: switchboard)
        XCTAssertTrue(experiment.availableCohorts.isEmpty)
        debugController.update(availableCohorts: ["first", "second"], for: experiment)
        XCTAssertTrue(experiment.availableCohorts.first == "first")
        XCTAssertTrue(experiment.availableCohorts.last == "second")
    }

    // MARK: - Caching

    func testCachingRestoringAndClearing() {
        let activeExpName = "activeExp"
        let activeFeatureName = "activeFeature"
        let inactiveExpName = "inactiveExp"
        let inactiveFeatureName = "inactiveFeature"
        let activeExp = SwitchboardExperiment(name: activeExpName, values: ["cohort": "yay"])!
        let activeFeature = SwitchboardFeature(name: activeFeatureName)!
        let inactiveExp = SwitchboardExperiment(name: inactiveExpName, values: ["cohort": "yay"])!
        let inactiveFeature = SwitchboardFeature(name: inactiveFeatureName)!

        let switchboard = Switchboard()

        func ensureCache(isEmpty: Bool, within debugVC: SwitchboardDebugController) {
            XCTAssertTrue(debugVC.activeExperiments.isEmpty == isEmpty)
            XCTAssertTrue(debugVC.inactiveExperiments.isEmpty == isEmpty)
            XCTAssertTrue(debugVC.activeFeatures.isEmpty == isEmpty)
            XCTAssertTrue(debugVC.inactiveFeatures.isEmpty == isEmpty)
        }

        // Ensure it's empty first
        let debugController1 = SwitchboardDebugController(switchboard: switchboard) // cache is restored upon init
        ensureCache(isEmpty: true, within: debugController1)

        // Add some active/inactive, then cache and see if it's saved
        debugController1.activate(experiment: activeExp)
        debugController1.deactivate(experiment: inactiveExp)
        debugController1.activate(feature: activeFeature)
        debugController1.deactivate(feature: inactiveFeature)
        debugController1.cacheAll()

        let debugController2 = SwitchboardDebugController(switchboard: switchboard) // cache is restored upon init
        XCTAssertTrue(debugController2.activeExperiments.first == activeExp)
        XCTAssertTrue(debugController2.inactiveExperiments.first == inactiveExp)
        XCTAssertTrue(debugController2.activeFeatures.first == activeFeature)
        XCTAssertTrue(debugController2.inactiveFeatures.first == inactiveFeature)

        // Clear and ensure it clears the cache and switchboard
        debugController2.clearCacheAndSwitchboard()
        let debugController3 = SwitchboardDebugController(switchboard: switchboard) // cache is restored upon init
        ensureCache(isEmpty: true, within: debugController3)
    }

    func testCachingSetsAndClearsIsDebuggingFlag() {
        let switchboard = Switchboard()
        XCTAssertFalse(switchboard.isDebugging)
        let debugController = SwitchboardDebugController(switchboard: switchboard)
        debugController.cacheAll()
        XCTAssertTrue(switchboard.isDebugging)
        debugController.clearCacheAndSwitchboard()
        XCTAssertFalse(switchboard.isDebugging)
    }

}
