//
//  SwitchboardSubclassTests.swift
//  SwitchboardTests
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest
@testable import Switchboard

final class TestSwitchboardSubclass: Switchboard {

    let activateExpectation = XCTestExpectation(description: "activate")
    let downloadConfigurationExpectation = XCTestExpectation(description: "downloadConfiguration")

    override func activate(serverUrlString: String, completion: SwitchboardClientCompletion?) {
        activateExpectation.fulfill()
    }

    override func downloadConfiguration(for uuid: String, trackingId: String?, userData: [String : Any]?, completion: SwitchboardClientCompletion?) {
        downloadConfigurationExpectation.fulfill()
    }

}

final class SwitchboardSubclassTests: XCTestCase {

    // MARK: - Shared

    let subclass = TestSwitchboardSubclass()

    // MARK: - Overrides
    // Note: We just test that overrides don't assert anymore

    func testActivate() {
        subclass.activate(serverUrlString: "https://ilovelamp.com", completion: nil)
        wait(for: [subclass.activateExpectation], timeout: 5)
    }

    func testDownloadConfiguration() {
        subclass.downloadConfiguration(for: "uuid", trackingId: nil, userData: nil, completion: nil)
        wait(for: [subclass.downloadConfigurationExpectation], timeout: 5)
    }

}
