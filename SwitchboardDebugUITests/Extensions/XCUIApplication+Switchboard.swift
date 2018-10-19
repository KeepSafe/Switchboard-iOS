//
//  XCUIApplication+Switchboard.swift
//  SwitchboardDebugUITests
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import XCTest

extension XCUIApplication {

    func textField(containing label: String) -> XCUIElement {
        let matches = textFields.containing(NSPredicate(format: "value CONTAINS %@", label))
        return matches.element(boundBy: 0)
    }

    func cell(containing label: String) -> XCUIElement {
        let matches = cells.containing(NSPredicate(format: "label CONTAINS %@", label))
        return matches.element(boundBy: 0)
    }

}
