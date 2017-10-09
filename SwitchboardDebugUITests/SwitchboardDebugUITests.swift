//
//  SwitchboardDebugUITests.swift
//  SwitchboardDebugUITests
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
import Switchboard
@testable import SwitchboardExample

final class SwitchboardDebugUITests: XCTestCase {

    // MARK: - Setup

    var app: XCUIApplication!
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        clearSwitchboardValuesAndCache()
    }

    // MARK: - Generic Tests
    
    func testShowingDebugView() {
        XCTAssertFalse(app.navigationBars["Switchboard Debug"].exists)
        app.buttons["Show Switchboard Debug"].tap()
        XCTAssertTrue(app.navigationBars["Switchboard Debug"].exists)
    }

    // MARK: - Features

    func testShowingFeatures() {
        XCTAssertFalse(app.navigationBars["Features"].exists)
        showFeaturesList()
        XCTAssertTrue(app.navigationBars["Features"].exists)
    }

    func testShowingFeatureDetail() {
        showFeatureDetail(for: "activeFeature1")
        XCTAssertTrue(app.navigationBars["Edit Feature"].exists)
        tapCancel()

        showFeatureDetail(for: "inactiveFeature1")
        XCTAssertTrue(app.navigationBars["Edit Feature"].exists)
        tapCancel()
    }

    func testAddingFeature() {
        addFeature(named: "newFeature")
        XCTAssertTrue(app.cellExists(containing: "newFeature"))
    }

    func testRemovingFeature() {
        addFeature(named: "newFeature")
        XCTAssertTrue(app.cellExists(containing: "newFeature"))

        app.swipeCellLeft(containing: "newFeature")
        tapDelete()
        XCTAssertFalse(app.cellExists(containing: "newFeature"))
    }

    func testTogglingFeatures() {
        showFeaturesList()

        // Toggle active to inactive
        XCTAssertTrue(app.cellExists(containing: "🔵 activeFeature1"))
        showFeatureDetail(for: "activeFeature1")
        toggleEnabledSwitch()
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "🔴 activeFeature1"))

        // Toggle inactive to active
        XCTAssertTrue(app.cellExists(containing: "🔴 inactiveFeature1"))
        showFeatureDetail(for: "inactiveFeature1")
        toggleEnabledSwitch()
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "🔵 inactiveFeature1"))
    }

    func testCancellingFeatureChanges() {
        showFeaturesList()

        // Toggle active to inactive but cancel before saving
        XCTAssertTrue(app.cellExists(containing: "🔵 activeFeature1"))
        showFeatureDetail(for: "activeFeature1")
        toggleEnabledSwitch()
        tapCancel()
        XCTAssertFalse(app.cellExists(containing: "🔴 activeFeature1"))
        XCTAssertTrue(app.cellExists(containing: "🔵 activeFeature1"))
    }

    // MARK: - Experiments

    func testShowingExperiments() {
        XCTAssertFalse(app.navigationBars["Experiments"].exists)
        showExperimentsList()
        XCTAssertTrue(app.navigationBars["Experiments"].exists)
    }

    func testShowingExperimentDetail() {
        showExperimentDetail(for: "activeExperiment1")
        XCTAssertTrue(app.navigationBars["Edit Experiment"].exists)
        tapCancel()

        showExperimentDetail(for: "inactiveExperiment1")
        XCTAssertTrue(app.navigationBars["Edit Experiment"].exists)
        tapCancel()
    }

    func testAddingExperiment() {
        addExperiment(named: "newExperiment", cohort: "yay")
        XCTAssertTrue(app.cellExists(containing: "newExperiment"))
    }

    func testRemovingExperiment() {
        addExperiment(named: "newExperiment", cohort: "yay")
        XCTAssertTrue(app.cellExists(containing: "newExperiment"))

        app.swipeCellLeft(containing: "newExperiment")
        tapDelete()
        XCTAssertFalse(app.cellExists(containing: "newExperiment"))
    }

    func testTogglingExperiments() {
        showExperimentsList()

        // Toggle active to inactive
        XCTAssertTrue(app.cellExists(containing: "🔵 activeExperiment1"))
        showExperimentDetail(for: "activeExperiment1")
        toggleEnabledSwitch()
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "🔴 activeExperiment1"))

        // Toggle inactive to active
        XCTAssertTrue(app.cellExists(containing: "🔴 inactiveExperiment1"))
        showExperimentDetail(for: "inactiveExperiment1")
        toggleEnabledSwitch()
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "🔵 inactiveExperiment1"))
    }

    func testAddingCohort() {
        addExperimentCohort(named: "newCohort", on: "activeExperiment1")

        XCTAssertTrue(app.cellExists(containing: "newCohort"))
        XCTAssertFalse(app.cellExists(containing: "123")) // old cohort value
    }

    func testDeletingNewCohortResetsToOriginalCohort() {
        addExperimentCohort(named: "newCohort", on: "activeExperiment1")
        XCTAssertTrue(app.cellExists(containing: "newCohort"))

        app.tapCell(containing: "activeExperiment1")
        app.swipeCellLeft(containing: "newCohort")
        tapDelete()
        saveForm()

        XCTAssertFalse(app.cellExists(containing: "newCohort"))
        XCTAssertTrue(app.cellExists(containing: "123")) // gets set back to original value
    }

    func testChangingExperimentState() {
        showExperimentsList()

        // Reset it just in case we had a failed test scenario
        showExperimentDetail(for: "activeExperiment1")
        app.buttons["Reset experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Entitled to start"))
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "entitled to start"))

        // Start it
        showExperimentDetail(for: "activeExperiment1")
        XCTAssertTrue(app.textFieldExists(containing: "Current State: Entitled to start"))
        app.buttons["Start experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Started"))
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "started"))

        // Complete it
        showExperimentDetail(for: "activeExperiment1")
        app.buttons["Complete experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Completed"))
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "completed"))

        // Reset it
        showExperimentDetail(for: "activeExperiment1")
        app.buttons["Reset experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Entitled to start"))
        saveForm()
        XCTAssertTrue(app.cellExists(containing: "entitled to start"))
    }

    func testCancellingExperimentChanges() {
        showExperimentsList()

        // Toggle active to inactive but cancel before saving
        XCTAssertTrue(app.cellExists(containing: "🔵 activeExperiment1"))
        showExperimentDetail(for: "activeExperiment1")
        toggleEnabledSwitch()
        tapCancel()
        XCTAssertFalse(app.cellExists(containing: "🔴 activeExperiment1"))
        XCTAssertTrue(app.cellExists(containing: "🔵 activeExperiment1"))
    }

    func testPreventingExperimentFromStarting() {
        let preventedExp = "somePreventedExperimentNameHere"
        addExperiment(named: preventedExp, cohort: "yay")

        // Reset it just in case we had a failed test scenario
        showExperimentDetail(for: preventedExp)
        app.buttons["Reset experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Entitled to start"))
        saveForm()

        // Try to start it but it should fail
        showExperimentDetail(for: preventedExp)
        app.buttons["Start experiment"].tap()
        XCTAssertTrue(app.textFieldExists(containing: "New State: Started"))
        saveForm()
        XCTAssertFalse(app.cellExists(containing: "started ∙ cohort: yay")) // specifically, this experiment
    }
    
}

// MARK: - Private API

fileprivate extension SwitchboardDebugUITests {

    func clearSwitchboardValuesAndCache() {
        app.buttons["Reset Switchboard"].tap()
    }

    // TODO: This seems broken as of Xcode 9; alternatives?
    func resetSwitchboard(confirmed: Bool = false) {
        showSwitchboardDebug()

        let firstCell = app.staticTexts["Features"]
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 30))
        start.press(forDuration: 1, thenDragTo: finish)

        if confirmed {
            app.alerts["Are you sure?"].buttons["Confirm"].tap()
        } else {
            app.alerts["Are you sure?"].buttons["Cancel"].tap()
        }
    }

    func showSwitchboardDebug() {
        app.buttons["Show Switchboard Debug"].tap()
    }

    func showFeaturesList() {
        showSwitchboardDebug()
        app.tapCell(containing: "Features")
    }

    func showExperimentsList() {
        showSwitchboardDebug()
        app.tapCell(containing: "Experiments")
    }

    func showFeatureDetail(for featureName: String) {
        if app.navigationBars["Features"].exists == false {
            showFeaturesList()
        }
        app.tapCell(containing: featureName)
    }

    func showExperimentDetail(for experimentName: String) {
        if app.navigationBars["Experiments"].exists == false {
            showExperimentsList()
        }
        app.tapCell(containing: experimentName)
    }

    func addFeature(named name: String) {
        showFeaturesList()

        app.navigationBars["Features"].buttons["Add"].tap()
        let addFeatureAlert = app.alerts["Add Feature"]
        let featureNameTextField = addFeatureAlert.collectionViews.textFields["Feature name"]
        featureNameTextField.tap()
        featureNameTextField.typeText(name)
        addFeatureAlert.buttons["Save"].tap()
    }

    func addExperiment(named name: String, cohort: String) {
        showExperimentsList()

        app.navigationBars["Experiments"].buttons["Add"].tap()
        let addExperimentAlert = app.alerts["Add Experiment"]
        let featureNameTextField = addExperimentAlert.collectionViews.textFields["Experiment name"]
        featureNameTextField.tap()
        featureNameTextField.typeText(name)
        let cohortNameTextField = addExperimentAlert.collectionViews.textFields["Cohort name"]
        cohortNameTextField.tap()
        cohortNameTextField.typeText(cohort)
        addExperimentAlert.buttons["Save"].tap()
    }

    func addExperimentCohort(named name: String, on experimentName: String) {
        showExperimentDetail(for: experimentName)

        app.tapCell(containing: "Add cohort")
        let addCohortAlert = app.alerts["Add Cohort"]
        addCohortAlert.collectionViews.textFields["Cohort name"].typeText("newCohort")
        addCohortAlert.buttons["Save"].tap()

        saveForm()
    }

    func tapDelete() {
        app.buttons["Delete"].tap()
    }

    func tapCancel() {
        app.buttons["Cancel"].tap()
    }

    func saveForm() {
        app.buttons["Save"].tap()
    }

    func toggleEnabledSwitch() {
        app.switches["Enabled Toggle"].tap()
    }

}
