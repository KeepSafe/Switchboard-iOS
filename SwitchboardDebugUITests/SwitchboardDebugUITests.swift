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

let app = XCUIApplication()

final class SwitchboardDebugUITests: XCTestCase {

    // MARK: - Setup
        
    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        app.launch()

        clearSwitchboardValuesAndCache()
        clearSwitchboardPrefillCache()
    }

    // MARK: - Generic Tests
    
    func testShowingDebugView() {
        waitFor(app.navigationBars["Switchboard Debug"], toExist: false)
        tapEventually(app.buttons["Show Switchboard Debug"])
        waitFor(app.navigationBars["Switchboard Debug"])
    }

    // MARK: - Features

    func testShowingFeatures() {
        waitFor(app.navigationBars["Features"], toExist: false)
        showFeaturesList()
        waitFor(app.navigationBars["Features"])
    }

    func testShowingFeatureDetail() {
        showFeatureDetail(for: "activeFeature1")
        waitFor(app.navigationBars["Edit Feature"])
        tapCancel()

        showFeatureDetail(for: "inactiveFeature1")
        waitFor(app.navigationBars["Edit Feature"])
        tapCancel()
    }
    
    func testEnableAllFeatures() {
        showFeaturesList()
        waitForCell(containing: "🔵 activeFeature1")
        waitForCell(containing: "🔴 inactiveFeature1")
        tapEventually(app.buttons["Enable All"])
        waitForCell(containing: "🔵 activeFeature1")
        waitForCell(containing: "🔵 inactiveFeature1")
    }
    
    func testDisableAllFeatures() {
        showFeaturesList()
        waitForCell(containing: "🔵 activeFeature1")
        waitForCell(containing: "🔴 inactiveFeature1")
        tapEventually(app.buttons["Disable All"])
        waitForCell(containing: "🔴 activeFeature1")
        waitForCell(containing: "🔴 inactiveFeature1")
    }

    func testAddingFeature() {
        addFeature(selectingFromPrefill: false, named: "newFeature")
        waitForCell(containing: "newFeature")
    }

    func testRemovingFeature() {
        addFeature(selectingFromPrefill: false, named: "newFeature")
        removeFeature(named: "newFeature")
    }
    
    func testPrefillingFeaturesVerifyAndCancel() {
        prefillFeature(named: "prefilledFeature")
        tapEventually(app.navigationBars["Features"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add a feature?"]
        tapEventually(actionSheet.buttons["Select from existing"])
        waitForCell(containing: "prefilledFeature")
        tapCancel()
    }
    
    func testDeletingLastPrefillFeatureDismissesPrefillView() {
        prefillFeature(named: "prefilledFeature")
        
        tapEventually(app.navigationBars["Features"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add a feature?"]
        tapEventually(actionSheet.buttons["Select from existing"])
        waitFor(app.navigationBars["Prefill Features"])
        
        swipeCellLeft(containing: "prefilledFeature")
        tapDelete()

        waitForCell(containing: "prefilledFeature", toExist: false)
        waitFor(app.navigationBars["Prefill Features"], toExist: false)
    }

    func testTogglingFeatures() {
        showFeaturesList()

        // Toggle active to inactive
        waitForCell(containing: "🔵 activeFeature1")
        showFeatureDetail(for: "activeFeature1")
        toggleEnabledSwitch()
        saveForm()
        waitForCell(containing: "🔴 activeFeature1")

        // Toggle inactive to active
        waitForCell(containing: "🔴 inactiveFeature1")
        showFeatureDetail(for: "inactiveFeature1")
        toggleEnabledSwitch()
        saveForm()
        waitForCell(containing: "🔵 inactiveFeature1")
    }

    func testCancellingFeatureChanges() {
        showFeaturesList()

        // Toggle active to inactive but cancel before saving
        waitForCell(containing: "🔵 activeFeature1")
        showFeatureDetail(for: "activeFeature1")
        toggleEnabledSwitch()
        tapCancel()
        waitForCell(containing: "🔴 activeFeature1", toExist: false)
        waitForCell(containing: "🔵 activeFeature1")
    }

    // MARK: - Experiments

    func testShowingExperiments() {
        waitFor(app.navigationBars["Experiments"], toExist: false)
        showExperimentsList()
        waitFor(app.navigationBars["Experiments"])
    }

    func testShowingExperimentDetail() {
        showExperimentDetail(for: "activeExperiment1")
        waitFor(app.navigationBars["Edit Experiment"])
        tapCancel()

        showExperimentDetail(for: "inactiveExperiment1")
        waitFor(app.navigationBars["Edit Experiment"])
        tapCancel()
    }
    
    func testEnableAllExperiments() {
        showExperimentsList()
        waitForCell(containing: "🔵 activeExperiment1")
        waitForCell(containing: "🔴 inactiveExperiment1")
        tapEventually(app.buttons["Enable All"])
        waitForCell(containing: "🔵 activeExperiment1")
        waitForCell(containing: "🔵 inactiveExperiment1")
    }
    
    func testDisableAllExperiments() {
        showExperimentsList()
        waitForCell(containing: "🔵 activeExperiment1")
        waitForCell(containing: "🔴 inactiveExperiment1")
        tapEventually(app.buttons["Disable All"])
        waitForCell(containing: "🔴 activeExperiment1")
        waitForCell(containing: "🔴 inactiveExperiment1")
    }
    
    func testPrefillingExperimentsCancel() {
        showExperimentsList()
        tapEventually(app.navigationBars["Experiments"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add an experiment?"]
        tapEventually(actionSheet.buttons["Select from existing"])
        tapCancel()
    }

    func testPrefillingExperimentsFromProgrammaticNameMappings() {
        addExperiment(selectingFromPrefill: true, named: "availableCohortExperiment")
        waitForCell(containing: "availableCohortExperiment")
    }
    
    func testDeletingLastPrefillDismissesPrefillView() {
        showExperimentsList()
        tapEventually(app.navigationBars["Experiments"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add an experiment?"]
        tapEventually(actionSheet.buttons["Select from existing"])
        waitFor(app.navigationBars["Prefill Experiments"])
        
        swipeCellLeft(containing: "availableCohortExperiment")
        tapDelete()
        waitForCell(containing: "availableCohortExperiment", toExist: false)
        waitFor(app.navigationBars["Prefill Experiments"], toExist: false)
    }
    
    func testPrepopulatingAvailableCohorts() {
        addExperiment(selectingFromPrefill: true, named: "availableCohortExperiment")
        showExperimentDetail(for: "availableCohortExperiment")
        waitForCell(containing: "control")
        waitForCell(containing: "cohort1")
        waitForCell(containing: "cohort2")
        tapCancel()
    }

    func testAddingExperiment() {
        addExperiment(selectingFromPrefill: false, named: "newExperiment", cohort: "yay")
        waitForCell(containing: "newExperiment")
    }

    func testRemovingExperiment() {
        addExperiment(selectingFromPrefill: false, named: "newExperiment", cohort: "yay")
        waitForCell(containing: "newExperiment")

        swipeCellLeft(containing: "newExperiment")
        tapDelete()
        waitForCell(containing: "newExperiment", toExist: false)
    }

    func testTogglingExperiments() {
        showExperimentsList()

        // Toggle active to inactive
        waitForCell(containing: "🔵 activeExperiment1")
        showExperimentDetail(for: "activeExperiment1")
        toggleEnabledSwitch()
        saveForm()
        waitForCell(containing: "🔴 activeExperiment1")

        // Toggle inactive to active
        waitForCell(containing: "🔴 inactiveExperiment1")
        showExperimentDetail(for: "inactiveExperiment1")
        toggleEnabledSwitch()
        saveForm()
        waitForCell(containing: "🔵 inactiveExperiment1")
    }

    func testAddingCohort() {
        addExperimentCohort(named: "newCohort", on: "activeExperiment1")

        waitForCell(containing: "newCohort")
        waitForCell(containing: "123", toExist: false) // old cohort value
    }

    func testDeletingNewCohortResetsToOriginalCohort() {
        addExperimentCohort(named: "newCohort", on: "activeExperiment1")
        waitForCell(containing: "newCohort")

        tapCell(containing: "activeExperiment1")
        swipeCellLeft(containing: "newCohort")
        tapDelete()
        saveForm()

        waitForCell(containing: "newCohort", toExist: false)
        waitForCell(containing: "123") // gets set back to original value
    }

    func testChangingExperimentState() {
        showExperimentsList()

        // Reset it just in case we had a failed test scenario
        showExperimentDetail(for: "activeExperiment1")
        tapEventually(app.buttons["Reset experiment"])
        waitForTextField(containing: "New State: Entitled to start")
        saveForm()
        waitForCell(containing: "entitled to start")

        // Start it
        showExperimentDetail(for: "activeExperiment1")
        waitForTextField(containing: "Current State: Entitled to start")
        tapEventually(app.buttons["Start experiment"])
        waitForTextField(containing: "New State: Started")
        saveForm()
        waitForCell(containing: "started")

        // Complete it
        showExperimentDetail(for: "activeExperiment1")
        tapEventually(app.buttons["Complete experiment"])
        waitForTextField(containing: "New State: Completed")
        saveForm()
        waitForCell(containing: "completed")

        // Reset it
        showExperimentDetail(for: "activeExperiment1")
        tapEventually(app.buttons["Reset experiment"])
        waitForTextField(containing: "New State: Entitled to start")
        saveForm()
        waitForCell(containing: "entitled to start")
    }

    func testCancellingExperimentChanges() {
        showExperimentsList()

        // Toggle active to inactive but cancel before saving
        waitForCell(containing: "🔵 activeExperiment1")
        showExperimentDetail(for: "activeExperiment1")
        toggleEnabledSwitch()
        tapCancel()
        waitForCell(containing: "🔴 activeExperiment1", toExist: false)
        waitForCell(containing: "🔵 activeExperiment1")
    }

    func testPreventingExperimentFromStarting() {
        let preventedExp = "somePreventedExperimentNameHere"
        addExperiment(selectingFromPrefill: false, named: preventedExp, cohort: "yay")

        // Reset it just in case we had a failed test scenario
        showExperimentDetail(for: preventedExp)
        tapEventually(app.buttons["Reset experiment"])
        waitForTextField(containing: "New State: Entitled to start")
        saveForm()

        // Try to start it but it should fail
        showExperimentDetail(for: preventedExp)
        tapEventually(app.buttons["Start experiment"])
        waitForTextField(containing: "New State: Started")
        saveForm()
        waitForCell(containing: "started ∙ cohort: yay", toExist: false) // specifically, this experiment
    }
    
}

// MARK: - Private API

fileprivate extension SwitchboardDebugUITests {

    func clearSwitchboardValuesAndCache() {
        tapEventually(app.buttons["Reset Switchboard"])
    }
    
    func clearSwitchboardPrefillCache() {
        tapEventually(app.buttons["Reset Switchboard's Prefill"])
    }

    // TODO: This seems broken as of Xcode 9; alternatives?
    func resetSwitchboard(confirmed: Bool = false) {
        showSwitchboardDebug()

        let firstCell = app.staticTexts["Features"]
        let start = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
        let finish = firstCell.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 30))
        start.press(forDuration: 1, thenDragTo: finish)

        if confirmed {
            tapEventually(app.alerts["Are you sure?"].buttons["Confirm"])
        } else {
            tapEventually(app.alerts["Are you sure?"].buttons["Cancel"])
        }
    }

    func showSwitchboardDebug() {
        tapEventually(app.buttons["Show Switchboard Debug"])
    }

    func showFeaturesList() {
        showSwitchboardDebug()
        tapCell(containing: "Features")
    }

    func showExperimentsList() {
        showSwitchboardDebug()
        tapCell(containing: "Experiments")
    }

    func showFeatureDetail(for featureName: String) {
        if app.navigationBars["Features"].exists == false {
            showFeaturesList()
        }
        tapCell(containing: featureName)
    }

    func showExperimentDetail(for experimentName: String) {
        if app.navigationBars["Experiments"].exists == false {
            showExperimentsList()
        }
        tapCell(containing: experimentName)
    }

    func addFeature(selectingFromPrefill: Bool, named name: String) {
        showFeaturesList()

        tapEventually(app.navigationBars["Features"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add a feature?"]
        if selectingFromPrefill {
            tapEventually(actionSheet.buttons["Select from existing"])
            tapCell(containing: name)
        } else {
            let addFeatureAlert = app.alerts["Add Feature"]
            let featureNameTextField = addFeatureAlert.collectionViews.textFields["Feature name"]
            tapEventually(featureNameTextField)
            featureNameTextField.typeText(name)
            tapEventually(addFeatureAlert.buttons["Save"])
        }
    }
    
    func prefillFeature(named name: String) {
        addFeature(selectingFromPrefill: false, named: name)
        removeFeature(named: name)
    }
    
    func removeFeature(named name: String) {
        waitForCell(containing: name)
        swipeCellLeft(containing: name)
        tapDelete()
        waitForCell(containing: name, toExist: false)
    }

    func addExperiment(selectingFromPrefill: Bool, named name: String, cohort: String = "yay") {
        showExperimentsList()

        tapEventually(app.navigationBars["Experiments"].buttons["Add"])
        let actionSheet = app.sheets["How do you want to add an experiment?"]
        if selectingFromPrefill {
            tapEventually(actionSheet.buttons["Select from existing"])
            tapCell(containing: name)
        } else {
            tapEventually(actionSheet.buttons["Type in name and cohort"])
            let addExperimentAlert = app.alerts["Add Experiment"]
            let featureNameTextField = addExperimentAlert.collectionViews.textFields["Experiment name"]
            tapEventually(featureNameTextField)
            featureNameTextField.typeText(name)
            let cohortNameTextField = addExperimentAlert.collectionViews.textFields["Cohort name"]
            tapEventually(cohortNameTextField)
            cohortNameTextField.typeText(cohort)
            tapEventually(addExperimentAlert.buttons["Save"])
        }
    }

    func addExperimentCohort(named name: String, on experimentName: String) {
        showExperimentDetail(for: experimentName)

        tapCell(containing: "Add cohort")
        let addCohortAlert = app.alerts["Add Cohort"]
        addCohortAlert.collectionViews.textFields["Cohort name"].typeText("newCohort")
        tapEventually(addCohortAlert.buttons["Save"])

        saveForm()
    }

    func tapDelete() {
        tapEventually(app.buttons["Delete"])
    }

    func tapCancel() {
        tapEventually(app.buttons["Cancel"])
    }

    func saveForm() {
        tapEventually(app.buttons["Save"])
    }

    func toggleEnabledSwitch() {
        tapEventually(app.switches["Enabled Toggle"])
    }

}
