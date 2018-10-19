//
//  XCTestCase+Switchboard.swift
//  SwitchboardDebugUITests
//
//  Created by Rob Phillips on 10/19/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

import XCTest

extension XCTestCase {

    func waitForTextField(containing label: String) {
        waitFor(app.textField(containing: label))
    }

    func waitForCell(containing label: String, toExist exists: Bool = true) {
        waitFor(app.cell(containing: label), toExist: exists)
    }

    func tapCell(containing label: String) {
        tapEventually(app.cell(containing: label))
    }

    func swipeCellLeft(containing label: String) {
        let cell = app.cell(containing: label)
        waitFor(cell)
        cell.swipeLeft()
    }

    /// Waits for the given element to either exist or fail to exist
    func waitFor(_ element: XCUIElement, toExist exists: Bool = true, timeout: TimeInterval = 5) {
        waitFor(element, conditionalName: "exists", isTrue: exists, timeout: timeout)
    }

    /// Waits for the given element and conditional name to be true/false
    /// e.g. `conditionalName` of `exists` checks for a predicate around existance
    ///      and this needs to match with a property value on the element
    func waitFor(_ element: XCUIElement, conditionalName: String, isTrue: Bool = true, timeout: TimeInterval = 5) {
        let exists = NSPredicate(format: "\(conditionalName) == \(isTrue ? 1 : 0)")
        expectation(for: exists, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: timeout, handler: nil)
    }

    /// Taps the button once it can be tapped
    func tapEventually(_ element: XCUIElement) {
        waitToBeHittable(element)
        element.tap()
    }

    /// Waits for the given element to be hittable (i.e. visible)
    func waitToBeHittable(_ element: XCUIElement, isTrue: Bool = true) {
        let hittable = NSPredicate(format: "hittable == \(isTrue ? 1 : 0)")
        expectation(for: hittable, evaluatedWith: element, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }

}
