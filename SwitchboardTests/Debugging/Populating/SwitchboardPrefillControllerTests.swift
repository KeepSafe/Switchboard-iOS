//
//  SwitchboardPrefillControllerTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
    import XCTest
    @testable import Switchboard
    
    final class SwitchboardPrefillControllerTests: XCTestCase {
        
        // MARK: - API
        
        func testClearCache() {
            let pc = SwitchboardPrefillController()
            addFeature(in: pc)
            addExperiment(in: pc)
            
            pc.clearCache()
            XCTAssertTrue(pc.features.isEmpty)
            XCTAssertTrue(pc.experiments.isEmpty)
            // Try to restore anything cached in a new controller
            let pc2 = SwitchboardPrefillController()
            XCTAssertTrue(pc2.features.isEmpty)
            XCTAssertTrue(pc2.experiments.isEmpty)
        }
        
        func testCachePersistsAcrossInstances() {
            let pc = SwitchboardPrefillController()
            clearFeatures(in: pc)
            clearExperiments(in: pc)
        
            let feature = addFeature(in: pc)
            let exp = addExperiment(in: pc)
            
            let pc2 = SwitchboardPrefillController()
            XCTAssertTrue(pc2.features.contains(feature))
            XCTAssertTrue(pc2.experiments.contains(exp))
        }
        
        func testPopulatingExperimentsFromNameMapping() {
            let pc = SwitchboardPrefillController()
            clearExperiments(in: pc)
            
            SwitchboardExperiment.namesMappedToCohorts = ["populateTest": ["hai"]]
            let switchboard = TestSwitchboardSubclass()
            pc.populateExperimentsIfNeeded(in: switchboard)
            XCTAssertTrue(pc.experiments.first?.name == "populateTest")
        }
        
        func testCanPrefillAndUniqueFeatures() {
            let pc = SwitchboardPrefillController()
            clearFeatures(in: pc)
            
            // Test failing case
            // (feature1 is not unique from feature1)
            let existingFeature1 = SwitchboardFeature(name: "fail")!
            pc.add(feature: existingFeature1)
            XCTAssertTrue(pc.featuresUnique(from: [existingFeature1]).isEmpty)
            XCTAssertFalse(pc.canPrefillFeatures(for: [existingFeature1]))
            
            // Test passing case
            // (feature2 is unique from feature1)
            let existingFeature2 = SwitchboardFeature(name: "pass")!
            XCTAssertTrue(pc.canPrefillFeatures(for: [existingFeature2]))
            XCTAssertFalse(pc.featuresUnique(from: [existingFeature2]).isEmpty)
        }
        
        func testCanPrefillAndUniqueExperiments() {
            let pc = SwitchboardPrefillController()
            let switchboard = TestSwitchboardSubclass()
            clearExperiments(in: pc)
            
            // Test failing case
            // (exp1 is not unique from exp1)
            let existingExp1 = SwitchboardExperiment(name: "fail", cohort: "f", switchboard: switchboard)!
            pc.add(experiment: existingExp1)
            XCTAssertTrue(pc.experimentsUnique(from: [existingExp1]).isEmpty)
            XCTAssertFalse(pc.canPrefillExperiments(for: [existingExp1]))
            
            // Test passing case
            // (exp2 is unique from exp1)
            let existingExp2 = SwitchboardExperiment(name: "pass", cohort: "p", switchboard: switchboard)!
            XCTAssertTrue(pc.canPrefillExperiments(for: [existingExp2]))
            XCTAssertFalse(pc.experimentsUnique(from: [existingExp2]).isEmpty)
        }
        
        func testAddFeatures() {
            let pc = SwitchboardPrefillController()
            clearFeatures(in: pc)
            let feature1 = SwitchboardFeature(name: "addedA")!
            let feature2 = SwitchboardFeature(name: "addedB")!
            pc.add(features: Set([feature1, feature2]))
            XCTAssertTrue(pc.features.contains(feature1))
            XCTAssertTrue(pc.features.contains(feature2))
        }
        
        func testAddFeature() {
            clearFeatures()
            addFeature()
        }
        
        func testAddExperiments() {
            let pc = SwitchboardPrefillController()
            clearFeatures(in: pc)
            let exp1 = SwitchboardExperiment(name: "added1", cohort: "control", switchboard: TestSwitchboardSubclass())!
            let exp2 = SwitchboardExperiment(name: "added2", cohort: "control", switchboard: TestSwitchboardSubclass())!
            pc.add(experiments: Set([exp1, exp2]))
            XCTAssertTrue(pc.experiments.contains(exp1))
            XCTAssertTrue(Array(pc.experiments).contains(exp2))
        }
        
        func testAddExperiment() {
            clearExperiments()
            addExperiment()
        }
        
        func testDeleteFeature() {
            let pc = SwitchboardPrefillController()
            let feature = addFeature(in: pc)
            XCTAssertFalse(pc.features.isEmpty)
            pc.delete(feature: feature)
            XCTAssertTrue(pc.features.isEmpty)
        }
        
        func testDeleteExperiment() {
            let pc = SwitchboardPrefillController()
            let exp = addExperiment(in: pc)
            XCTAssertFalse(pc.experiments.isEmpty)
            pc.delete(experiment: exp)
            XCTAssertTrue(pc.experiments.isEmpty)
        }
        
        func testClearFeatures() {
            clearFeatures()
        }
        
        func testClearExperiments() {
            clearExperiments()
        }
        
    }
    
    fileprivate extension SwitchboardPrefillControllerTests {
        
        @discardableResult
        func addExperiment(in pc: SwitchboardPrefillController = SwitchboardPrefillController()) -> SwitchboardExperiment {
            let exp1 = SwitchboardExperiment(name: "added1", cohort: "control", switchboard: TestSwitchboardSubclass())!
            pc.add(experiment: exp1)
            XCTAssertTrue(pc.experiments.contains(exp1))
            return exp1
        }
        
        @discardableResult
        func addFeature(in pc: SwitchboardPrefillController = SwitchboardPrefillController()) -> SwitchboardFeature {
            let feature1 = SwitchboardFeature(name: "added1")!
            pc.add(feature: feature1)
            XCTAssertTrue(pc.features.contains(feature1))
            return feature1
        }
        
        func clearExperiments(in pc: SwitchboardPrefillController = SwitchboardPrefillController()) {
            pc.clearExperiments()
            XCTAssertTrue(pc.experiments.isEmpty)
        }
        
        func clearFeatures(in pc: SwitchboardPrefillController = SwitchboardPrefillController()) {
            pc.clearFeatures()
            XCTAssertTrue(pc.features.isEmpty)
        }
        
    }
#endif
