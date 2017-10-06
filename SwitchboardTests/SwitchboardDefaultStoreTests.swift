//
//  SwitchboardDefaultStoreTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class SwitchboardDefaultStoreTests: XCTestCase {

    // MARK: - Shared

    let store = SwitchboardDefaultStore()
    let exp = SwitchboardExperiment(name: "exp", values: ["cohort": "yay"])!
    let someKey = "someKey"

    // MARK: - Setup

    override func setUp() {
        store.save(bool: false, for: exp, forKey: someKey)
    }

    // MARK: - Properties

    func testNamespaceProperty() {
        XCTAssertTrue(store.namespace == "com.keepsafe.switchboard.exp")
    }

    // MARK: - API

    func testSetterAndGetter() {
        XCTAssertFalse(store.bool(for: exp, forKey: someKey))
        store.save(bool: true, for: exp, forKey: someKey)
        XCTAssertTrue(store.bool(for: exp, forKey: someKey) == true)
    }

}
