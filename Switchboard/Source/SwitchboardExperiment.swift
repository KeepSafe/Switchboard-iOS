//
//  SwitchboardExperiment.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

/// Factory class for instantiating many experiments from a JSON dictionary
open class SwitchboardExperimentFactory {

    // MARK: - Instantiation

    /// Instantiates an array of active `SwitchboardExperiment` instances that the person currently belongs to
    ///
    /// - Parameters:
    ///   - json: A valid JSON dictionary returned from the Switchboard server
    ///   - switchboard: An optional instance of `Switchboard` to check prevent execution logic against
    ///   - store: The key-value store, conforming to `SwitchboardStorable`, to save state into; defaults to using `SwitchboardDefaultStore`
    ///   - analytics: An optional analytics provider, conforming to `SwitchboardAnalyticsProvider`, to log events to
    ///   - active: Whether to return active or inactive experiments
    /// - Returns: An array of `SwitchboardExperiment` instances, if any
    open class func from(json: [String : Any], switchboard: Switchboard? = nil, store: SwitchboardStorable = SwitchboardDefaultStore(), analytics: SwitchboardAnalyticsProvider? = nil, active: Bool = true) -> Set<SwitchboardExperiment> {
        var instances = Set<SwitchboardExperiment>()
        for key in Array(json.keys) {
            guard let dictionary = json[key] as? [String: Any],
                  let values = dictionary[SwitchboardKeys.values] as? [String: Any], // This can sometimes be a string with `<null>` in it
                  let instance = SwitchboardExperiment(name: key, values: values, switchboard: switchboard, store: store, analytics: analytics)
                else { continue }

            let isActive = dictionary[SwitchboardKeys.isActive] as? Bool
            if active {
                guard isActive == true else { continue }
            } else {
                guard isActive == false else { continue }
            }

            instances.insert(instance)
        }
        return instances
    }

}

/// Base class to encapsulate experiment meta data and state
open class SwitchboardExperiment: NSObject, SwitchboardValue {

    // MARK: - Instantiation

    /// Instantiates an experiment that the person currently belongs to
    ///
    /// Note: This will return `nil` if the `values` dictionary does not contain a non-nil `cohort` key
    ///
    /// - Parameters:
    ///   - name: The name of the experiment
    ///   - values: A dictionary of associated values
    ///   - switchboard: An optional instance of `Switchboard` to check prevent execution logic against
    ///   - store: The key-value store, conforming to `SwitchboardStorable`, to save state into; defaults to using `SwitchboardDefaultStore`
    ///   - analytics: An optional analytics provider, conforming to `SwitchboardAnalyticsProvider`, to log events to
    public required init?(name: String, values: [String: Any], switchboard: Switchboard? = nil, store: SwitchboardStorable = SwitchboardDefaultStore(), analytics: SwitchboardAnalyticsProvider? = nil) {
        self.name = name
        // Experiments must be part of a cohort
        guard let _ = values[SwitchboardKeys.cohort] as? String else {
            return nil
        }
        self.switchboard = switchboard
        self.values = values
        self.store = store
        self.analytics = analytics
    }

    // MARK: - Public Properties

    /// The name of the experiment
    open let name: String

    /// The cohort this experiment is a part of
    ///
    /// Note: we allow overrides via debug controller
    open var cohort: String {
        return values[SwitchboardKeys.cohort] as? String ?? "no-cohort-given"
    }

    /// All available cohorts for this experiment, useful for debugging
    ///
    /// Note: we allow overrides via debug controller
    open var availableCohorts = [String]()

    /// A dictionary of values associated with this experiment
    ///
    /// Note: we allow overrides via debug controller
    open var values: [String: Any]

    /// Whether this experiment is allowed to start (e.g. all dependencies fulfilled)
    open var canBeStarted: Bool {
        if switchboard?.preventExperimentFromStarting?(name) == true { return false }

        let noDependencies = dependencies.filter({ $0.isCompleted == false }).count == 0
        return !isActive && noDependencies && !isCompleted
    }

    /// Whether this person is entitled to this experiment
    /// (e.g. they haven't started it yet and the underlying json's `isActive` was true)
    ///
    /// For analytics purposes, you should consider tracking if a person has `isEntitled` true
    /// and then you can segment them as the people who have not started the experiment yet
    /// (but are entitled to start it) against the people who have started the experiment
    open var isEntitled: Bool {
        return !isActive && !isCompleted
    }

    /// Returns true if this experiment has been started but not yet completed
    open var isActive: Bool {
        return store.bool(for: self, forKey: SwitchboardKeys.isStarted) == true && !isCompleted
    }

    /// Whether this experiment is allowed to be completed (i.e. if it's still active)
    open var canBeCompleted: Bool {
        return isActive
    }

    /// Returns true if this experiment has been completed
    open var isCompleted: Bool {
        return store.bool(for: self, forKey: SwitchboardKeys.isCompleted) == true
    }

    /// Whether analytics should be tracked for this experiment, given as a boolean within the `values` dictionary
    open var shouldTrackAnalytics: Bool {
        guard let shouldDisableAnalytics = values[SwitchboardKeys.disableAnalytics] as? Bool else { return true }
        return shouldDisableAnalytics == false
    }

    /// Dependencies that must be completed prior to this experiment being able to start
    open fileprivate(set) var dependencies = Set<SwitchboardExperiment>()

    // MARK: - API

    /// Clears the current state of this experiment (useful for debugging)
    open func clearState() {
        store.save(bool: false, for: self, forKey: SwitchboardKeys.isStarted)
        store.save(bool: false, for: self, forKey: SwitchboardKeys.isCompleted)

        #if !DEBUG
            SwitchboardLogging.logDangerousCall()
        #endif
    }

    /// Starts this experiment
    ///
    /// - Returns: Whether the experiment was able to start
    @discardableResult open func start() -> Bool {
        guard canBeStarted else { return false }

        store.save(bool: true, for: self, forKey: SwitchboardKeys.isStarted)

        if shouldTrackAnalytics {
            analytics?.trackStarted(for: self)
        }

        return true
    }

    /// Completes this experiment
    ///
    /// - Returns: Whether the experiment was able to complete
    @discardableResult open func complete() -> Bool {
        guard canBeCompleted else { return false }

        store.save(bool: true, for: self, forKey: SwitchboardKeys.isCompleted)

        if shouldTrackAnalytics {
            analytics?.trackCompleted(for: self)
        }

        return true
    }

    /// Tracks an event associated with this experiment
    ///
    /// - Parameters:
    ///   - event: A `String` event to track
    ///   - properties: A dictionary of optional properties
    func track(event: String, properties: [String : Any]? = nil) {
        if shouldTrackAnalytics {
            analytics?.track(event: event, for: self, properties: properties)
        }
    }

    /// Adds a dependency that must be completed prior to this experiment starting
    ///
    /// - Parameter dependency: The `SwitchboardExperiment` this experiment depends on
    open func add(dependency: SwitchboardExperiment) {
        dependencies.insert(dependency)
    }

    /// Removes a dependency that must be completed prior to this experiment starting
    ///
    /// - Parameter dependency: The `SwitchboardExperiment` dependency to remove
    open func remove(dependency: SwitchboardExperiment) {
        dependencies.remove(dependency)
    }

    /// Removes all dependencies
    open func clearDependencies() {
        dependencies.removeAll()
    }

    // MARK: - NSCoding

    public convenience required init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: SwitchboardNSCodingKeys.name) as? String,
              let values = aDecoder.decodeObject(forKey: SwitchboardNSCodingKeys.values) as? [String: Any]
            else { return nil }

        self.init(name: name, values: values)

        if let cohorts = aDecoder.decodeObject(forKey: SwitchboardNSCodingKeys.availableCohorts) as? [String] {
            availableCohorts = cohorts
        }
    }

    open func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: SwitchboardNSCodingKeys.name)
        aCoder.encode(values, forKey: SwitchboardNSCodingKeys.values)
        aCoder.encode(availableCohorts, forKey: SwitchboardNSCodingKeys.availableCohorts)
    }

    // MARK: - Private Properties

    fileprivate let switchboard: Switchboard?
    fileprivate let store: SwitchboardStorable
    fileprivate let analytics: SwitchboardAnalyticsProvider?

}

// MARK: - Description

extension SwitchboardExperiment {

    open override var description: String {
        return "<SwitchboardExperiment: name: \"\(name)\" cohort: \"\(cohort)\"  values: \(values)>\n"
    }

}

// MARK: - Equatable

extension SwitchboardExperiment {

    open override func isEqual(_ otherObject: Any?) -> Bool {
        guard let experiment = otherObject as? SwitchboardExperiment else { return false }
        return name == experiment.name
    }

}

// MARK: - Hashable

extension SwitchboardExperiment {

    open override var hashValue: Int {
        return name.hashValue
    }

}
