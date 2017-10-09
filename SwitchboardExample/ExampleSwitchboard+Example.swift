//
//  ExampleSwitchboard+Example.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/9/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

enum ExampleSwitchboardExperiment: String {
    case activeExperiment1
    case inactiveExperiment1
}

enum ExampleSwitchboardFeature: String {
    case activeFeature1
    case inactiveFeature1
}

extension ExampleSwitchboard {

    // MARK: - Strongly-typed Versions

    // We recommend creating strongly typed wrapper functions around Switchboard's string-based functions
    // so you avoid passing strings around that can have typos. This also keeps things well-encapsulated
    // and gives you some auto-complete help as well

    // Note: the default value for this `isIn` function should be false
    static func isIn(experiment: ExampleSwitchboardExperiment, defaultValue: Bool = false) -> Bool {
        return self.shared.isIn(experimentNamed: experiment.rawValue, defaultValue: defaultValue)
    }

    // Note: the default value for this `isNotIn` function should be true
    static func isNotIn(experiment: ExampleSwitchboardExperiment, defaultValue: Bool = true) -> Bool {
        return self.shared.isNotIn(experimentNamed: experiment.rawValue, defaultValue: defaultValue)
    }

    // Note: the default value for this `isEnabled` function should be false
    static func isEnabled(feature: ExampleSwitchboardFeature, defaultValue: Bool = false) -> Bool {
        return self.shared.isEnabled(featureNamed: feature.rawValue, defaultValue: defaultValue)
    }

    // Note: the default value for this `isNotEnabled` function should be true
    static func isNotEnabled(feature: ExampleSwitchboardFeature, defaultValue: Bool = true) -> Bool {
        return self.shared.isNotEnabled(featureNamed: feature.rawValue, defaultValue: defaultValue)
    }

    static func experiment<T: SwitchboardExperiment>(named name: ExampleSwitchboardExperiment) -> T? {
        guard let experiment = self.shared.experiment(named: name.rawValue) else { return nil }
        return T.init(name: experiment.name, values: experiment.values)
    }

    static func feature<T: SwitchboardFeature>(named name: ExampleSwitchboardFeature) -> T? {
        guard let feature = self.shared.feature(named: name.rawValue) else { return nil }
        return T(name: feature.name, values: feature.values)
    }

    // MARK: - JSON Helpers

    // Some networking libs return optionals for responses, so we do that here just to simulate it
    static func defaultExperimentsAndFeatures() -> [String: Any]? {
        let defaults: [String: Any] = [
            ExampleSwitchboardExperiment.activeExperiment1.rawValue: ["isActive": true, "values": ["cohort": "123", "iLoveLamp": true]],
            ExampleSwitchboardExperiment.inactiveExperiment1.rawValue: ["isActive": false, "values": ["cohort": "456"]],
            ExampleSwitchboardFeature.activeFeature1.rawValue: ["isActive": true, "values": ["someValue": "goes here"]],
            ExampleSwitchboardFeature.inactiveFeature1.rawValue: ["isActive": false, "values": ["are you awesome": true]]
        ]
        return defaults
    }

}
