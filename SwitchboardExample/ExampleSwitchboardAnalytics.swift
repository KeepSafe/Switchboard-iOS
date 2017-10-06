//
//  ExampleSwitchboardAnalytics.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

final class ExampleSwitchboardAnalytics: SwitchboardAnalyticsProvider {

    func entitled(experiments: Set<SwitchboardExperiment>, features: Set<SwitchboardFeature>) {
        // Track these to know which experiments are entitled to be started or which features are enabled
    }

    func trackStarted(for experiment: SwitchboardExperiment) {
        // Know when an experiment starts
    }

    func trackCompleted(for experiment: SwitchboardExperiment) {
        // Know when an experiment completes
    }

    func track(event: String, for feature: SwitchboardFeature, properties: [String : Any]?) {
        // Generic tracking for a feature, called from the tracking(event...) method on a SwitchboardFeature subclass
    }

    func track(event: String, for experiment: SwitchboardExperiment, properties: [String : Any]?) {
        // Generic tracking for a feature, called from the tracking(event...) method on a SwitchboardExperiment subclass
    }

}
