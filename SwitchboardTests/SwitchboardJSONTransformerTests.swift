//
//  SwitchboardJSONTransformerTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 3/1/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardJSONTransformerTests: XCTestCase {
    
    func testJSONTransformation() {
        let switchboard = Switchboard()
        switchboard.experiments.removeAll()
        switchboard.inactiveExperiments.removeAll()
        switchboard.features.removeAll()
        switchboard.inactiveFeatures.removeAll()
        XCTAssertTrue(switchboard.experiments.isEmpty)
        XCTAssertTrue(switchboard.inactiveExperiments.isEmpty)
        XCTAssertTrue(switchboard.features.isEmpty)
        XCTAssertTrue(switchboard.inactiveFeatures.isEmpty)
        
        // Setup
        let activeFeatureName = "activeFeature"
        let activeFeature = SwitchboardFeature(name: activeFeatureName, values: ["yack": "jack"])!
        switchboard.features.insert(activeFeature)
        XCTAssertTrue(switchboard.features.contains(where: { $0.name == activeFeatureName }))

        let inactiveFeatureName = "inactiveFeatureName"
        let inactiveFeature = SwitchboardFeature(name: inactiveFeatureName)!
        switchboard.inactiveFeatures.insert(inactiveFeature)
        XCTAssertTrue(switchboard.inactiveFeatures.contains(where: { $0.name == inactiveFeatureName }))

        let activeExpName = "activeExp"
        let activeExperiment = SwitchboardExperiment(name: activeExpName, values: ["cohort": "yay"], switchboard: switchboard)!
        switchboard.experiments.insert(activeExperiment)
        XCTAssertTrue(switchboard.experiments.contains(where: { $0.name == activeExpName }))
        
        let inactiveExpName = "inactiveExp"
        let inactiveExperiment = SwitchboardExperiment(name: inactiveExpName, values: ["cohort": "yup"], switchboard: switchboard)!
        switchboard.inactiveExperiments.insert(inactiveExperiment)
        XCTAssertTrue(switchboard.inactiveExperiments.contains(where: { $0.name == inactiveExpName }))
        
        // Test JSON transformation
        let json = SwitchboardJSONTransformer.convertConfigurationToJSON(for: switchboard)
        
        // Check all features and experiments are there
        let af = json[activeFeatureName] as! [String: Any]
        let iaf = json[inactiveFeatureName] as! [String: Any]
        let ae = json[activeExpName] as! [String: Any]
        let iae = json[inactiveExpName] as! [String: Any]
        XCTAssertNotNil(af)
        XCTAssertNotNil(iaf)
        XCTAssertNotNil(ae)
        XCTAssertNotNil(iae)
        
        // Check active/inactive
        XCTAssertTrue(af[SwitchboardKeys.isActive] as! Bool)
        XCTAssertFalse(iaf[SwitchboardKeys.isActive] as! Bool)
        XCTAssertTrue(ae[SwitchboardKeys.isActive] as! Bool)
        XCTAssertFalse(iae[SwitchboardKeys.isActive] as! Bool)
        
        // Check structure
        XCTAssertTrue((af[SwitchboardKeys.values] as! [String: Any])["yack"] as! String == "jack")
        XCTAssertTrue((ae[SwitchboardKeys.values] as! [String: Any])[SwitchboardKeys.cohort] as! String == "yay")
        XCTAssertTrue((iae[SwitchboardKeys.values] as! [String: Any])[SwitchboardKeys.cohort] as! String == "yup")
    }
    
}
