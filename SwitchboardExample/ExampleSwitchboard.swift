//
//  ExampleSwitchboard.swift
//  SwitchboardExample
//
//  Created by Rob Phillips on 10/3/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Switchboard

final class ExampleSwitchboard: Switchboard {

    // MARK: - Constants

    static let serverUrlString = "https://someServerUrlStringGoesHere.com"

    // MARK: - Instantiation

    static let shared = ExampleSwitchboard()

    // MARK: - Activating

    override func activate(serverUrlString: String, completion: SwitchboardClientCompletion?) {
        // You should save the serverUrlString locally and use it in the download config method

        let uuid = "uid456"
        downloadConfiguration(for: uuid, completion: completion)
    }

    override func downloadConfiguration(for uuid: String, userData: [String : Any]? = nil, completion: SwitchboardClientCompletion?) {
        // If we're debugging, just let it use the debugging cache
        guard isDebugging == false else {
            completion?(nil)
            return
        }

        // Otherwise, fetch from the server

        // If you need to join the default parameters with the user data, just use something like
//        var parameters = SwitchboardProperties.defaults(withUuid: uuid)
//        if let userData = userData {
//            for (key, value) in userData {
//                parameters[key] = value
//            }
//        }

        // For this example, we'll just set the active & inactive features ourselves, but
        // this is a similar order for what to do in your network success callback
        if let json = ExampleSwitchboard.defaultExperimentsAndFeatures() {
            // Active
            experiments = SwitchboardExperimentFactory.from(json: json, analytics: analytics)
            features = SwitchboardFeatureFactory.from(json: json, analytics: analytics)

            // Inactive
            inactiveExperiments = SwitchboardExperimentFactory.from(json: json, analytics: analytics, active: false)
            inactiveFeatures = SwitchboardFeatureFactory.from(json: json, analytics: analytics, active: false)

            // Cache these for any network outages or lags the next time they launch
            SwitchboardCache.cache(experiments: experiments, features: features)

            // Log any entitled experiments and features
            let entitledExperiments = experiments.filter({ $0.isEntitled })
            analytics.entitled(experiments: Set(entitledExperiments), features: features)
        } else {
            // Example of catching a JSON parsing error and returning it
            let error = NSError(domain: "com.keepsafe.switchboard.errors", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error turning the response into a JSON dictionary."])
            completion?(error)
            return
        }

        completion?(nil)
    }

    // MARK: - Private Properties

    fileprivate let analytics = ExampleSwitchboardAnalytics()

    // MARK: - Private Instantiation

    fileprivate override init() {
        super.init()

        restoreFromCache()
        addPreventionLogic()
    }

}

// MARK: - Private API

fileprivate extension ExampleSwitchboard {

    // MARK: - Cache

    func restoreFromCache() {
        let (experiments, features) = SwitchboardCache.restoreFromCache()
        if let experiments = experiments { self.experiments = experiments }
        if let features = features { self.features = features }
    }

    // MARK: - Prevention Logic

    /// You can optionally add conditional logic for preventing experiments from starting or features from enabling
    /// Sometimes you'll want to do this if you're using other A/B testing frameworks so you don't
    /// run Switchboard experiments at the same time as other framework's experiments
    func addPreventionLogic() {
        preventExperimentFromStarting = { experimentName in
            return experimentName == "somePreventedExperimentNameHere" // or other conditional logic
        }

        preventFeatureFromEnabling = { featureName in
            return featureName == "somePreventedFeatureNameHere" // or other conditional logic
        }
    }
    
}
