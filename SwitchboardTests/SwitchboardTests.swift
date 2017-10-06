//
//  SwitchboardTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardTests: XCTestCase {

    // MARK: - Shared

    static let expName = "exp"
    static let featureName = "feature"
    let exp = SwitchboardExperiment(name: expName, values: ["cohort": "yay"])!
    let feature = SwitchboardFeature(name: featureName)!

    // MARK: - Properties

    func testIsDebuggingProperty() {
        let switchboard = Switchboard()
        XCTAssertFalse(switchboard.isDebugging)
        switchboard.isDebugging = true
        XCTAssertTrue(switchboard.isDebugging)
        switchboard.isDebugging = false
        XCTAssertFalse(switchboard.isDebugging)
    }

    func testExperimentsProperty() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.experiments.isEmpty)
    }

    func testFeaturesProperty() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.features.isEmpty)
    }

    // MARK: - Default Implementations

    func testIsInExperiment() {
        let switchboard = Switchboard()
        XCTAssertFalse(switchboard.isIn(experimentNamed: SwitchboardTests.expName))

        // Add and verify
        switchboard.add(experiment: exp)
        XCTAssertTrue(switchboard.isIn(experimentNamed: SwitchboardTests.expName))
    }

    func testIsInPreventFromStartingClosure() {
        let switchboard = Switchboard()
        let expName = "exp1"
        let expPrevention = SwitchboardExperiment(name: expName, values: ["cohort": "yay"], switchboard: switchboard)!
        switchboard.add(experiment: expPrevention)
        XCTAssertTrue(switchboard.isIn(experimentNamed: expName))

        // Add some conditional logic
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName == expName // prevent it
        }
        XCTAssertFalse(switchboard.isIn(experimentNamed: expName))

        // Change the logic
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName != expName // allow only this one
        }
        XCTAssertTrue(switchboard.isIn(experimentNamed: expName))

        switchboard.preventExperimentFromStarting = nil
        XCTAssertTrue(switchboard.isIn(experimentNamed: expName))
    }

    func testIsInExperimentDefaultValue() {
        let switchboard = Switchboard()

        // This should return true since they aren't in the experiment but the default value is set to true
        XCTAssertTrue(switchboard.isIn(experimentNamed: SwitchboardTests.expName, defaultValue: true))

        // This should return false because they aren't in the experiment
        XCTAssertFalse(switchboard.isIn(experimentNamed: SwitchboardTests.expName, defaultValue: false))

        // This should return true since they are in the experiment
        switchboard.add(experiment: exp)
        XCTAssertTrue(switchboard.isIn(experimentNamed: SwitchboardTests.expName, defaultValue: false))
    }

    func testIsNotInExperiment() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.isNotIn(experimentNamed: SwitchboardTests.expName))
        XCTAssertFalse(switchboard.isIn(experimentNamed: SwitchboardTests.expName))
    }

    func testIsNotInPreventFromStartingClosureOverridesDefaultValue() {
        let switchboard = Switchboard()
        let expName = "exp1"
        XCTAssertFalse(switchboard.isNotIn(experimentNamed: expName, defaultValue: false))

        // Add some conditional logic and verify the default value isn't returned
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName == expName // prevent it
        }
        XCTAssertTrue(switchboard.isNotIn(experimentNamed: expName, defaultValue: false))

        // Change the logic
        switchboard.preventExperimentFromStarting = { experimentName in
            return experimentName != expName // allow only this one
        }
        XCTAssertFalse(switchboard.isNotIn(experimentNamed: expName, defaultValue: false))

        switchboard.preventExperimentFromStarting = nil
        XCTAssertFalse(switchboard.isNotIn(experimentNamed: expName, defaultValue: false))
    }

    func testIsNotInExperimentDefaultValue() {
        let switchboard = Switchboard()

        // This should return true since they're not in the experiment so the default true value doesn't impact it
        XCTAssertTrue(switchboard.isNotIn(experimentNamed: SwitchboardTests.expName, defaultValue: true))

        // This should return false since they're not in the experiment and we set the default value to false
        XCTAssertFalse(switchboard.isNotIn(experimentNamed: SwitchboardTests.expName, defaultValue: false))

        // This should return false since they are in the experiment
        switchboard.add(experiment: exp)
        XCTAssertFalse(switchboard.isNotIn(experimentNamed: SwitchboardTests.expName, defaultValue: true))
    }

    func testfeatureIsEnabled() {
        let switchboard = Switchboard()
        XCTAssertFalse(switchboard.isEnabled(featureNamed: SwitchboardTests.featureName))

        // Add and verify
        switchboard.add(feature: feature)
        XCTAssertTrue(switchboard.isEnabled(featureNamed: SwitchboardTests.featureName))
    }

    func testIsEnabledPreventEnabledClosure() {
        let switchboard = Switchboard()
        let featureName = "feature"
        let featurePrevention = SwitchboardFeature(name: featureName)!
        switchboard.add(feature: featurePrevention)
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName))

        // Add some conditional logic
        switchboard.preventFeatureFromEnabling = { featureName in
            return featureName == featureName // prevent it
        }
        XCTAssertFalse(switchboard.isEnabled(featureNamed: featureName))

        // Change the logic
        switchboard.preventFeatureFromEnabling = { featureName in
            return featureName != featureName // allow only this one
        }
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName))

        switchboard.preventFeatureFromEnabling = nil
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName))
    }

    func testFeatureIsEnabledDefaultValue() {
        let switchboard = Switchboard()

        // This should return true since they don't have this feature but the default value returns as true
        XCTAssertTrue(switchboard.isEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: true))

        // This should return false since they don't have this feature so the default false value doesn't impact it
        XCTAssertFalse(switchboard.isEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: false))

        // This should return true since they have this feature
        switchboard.add(feature: feature)
        XCTAssertTrue(switchboard.isEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: false))
    }

    func testFeatureIsNotEnabled() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.isNotEnabled(featureNamed: SwitchboardTests.featureName))

        // Add and verify
        switchboard.add(feature: feature)
        XCTAssertFalse(switchboard.isNotEnabled(featureNamed: SwitchboardTests.featureName))
    }

    func testIsNotEnabledPreventEnabledClosureOverridesDefaultValue() {
        let switchboard = Switchboard()
        let featureName = "feature"
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName, defaultValue: true))

        // Add some conditional logic
        switchboard.preventFeatureFromEnabling = { featureName in
            return featureName == featureName // prevent it
        }
        XCTAssertFalse(switchboard.isEnabled(featureNamed: featureName, defaultValue: true))
        XCTAssertTrue(switchboard.isNotEnabled(featureNamed: featureName))

        // Change the logic
        switchboard.preventFeatureFromEnabling = { featureName in
            return featureName != featureName // allow only this one
        }
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName, defaultValue: true))

        switchboard.preventFeatureFromEnabling = nil
        XCTAssertTrue(switchboard.isEnabled(featureNamed: featureName, defaultValue: true))
    }

    func testFeatureIsNotEnabledDefaultValue() {
        let switchboard = Switchboard()

        // This should return true since they don't have this feature but the default value returns as true
        XCTAssertTrue(switchboard.isNotEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: true))

        // This should return false since they don't have this feature so the default false value doesn't impact it
        XCTAssertFalse(switchboard.isNotEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: false))

        // This should return false since they have this feature
        switchboard.add(feature: feature)
        XCTAssertFalse(switchboard.isNotEnabled(featureNamed: SwitchboardTests.featureName, defaultValue: true))
    }

    // MARK: - Other API

    func testFetchingExperimentByName() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.experiments.isEmpty)

        // Add and verify
        switchboard.add(experiment: exp)
        XCTAssertNotNil(switchboard.experiment(named: SwitchboardTests.expName))
    }

    func testFetchingFeatureByName() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.features.isEmpty)

        // Add and verify
        switchboard.add(feature: feature)
        XCTAssertNotNil(switchboard.feature(named: SwitchboardTests.featureName))
    }

    func testManuallyAddingAndRemovingExperiment() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.experiments.isEmpty)

        // Add
        switchboard.add(experiment: exp)
        XCTAssertTrue(switchboard.experiments.first == exp)

        // Remove
        switchboard.remove(experiment: exp)
        XCTAssertTrue(switchboard.experiments.isEmpty)
    }

    func testManuallyAddingAndRemovingFeature() {
        let switchboard = Switchboard()
        XCTAssertTrue(switchboard.features.isEmpty)

        // Add
        switchboard.add(feature: feature)
        XCTAssertTrue(switchboard.features.first == feature)

        // Remove
        switchboard.remove(feature: feature)
        XCTAssertTrue(switchboard.features.isEmpty)
    }

}
