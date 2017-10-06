//
//  SwitchboardDebugController.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

fileprivate final class SwitchboardDebugCache: SwitchboardCache {
    override class var cacheDirectoryName: String { return "switchboardDebug" }
}

open class SwitchboardDebugController {

    // MARK: - Instantiation

    /// Instantiates with the given `Switchboard` instance containing
    /// the server's features and experiments
    ///
    /// - Parameter switchboard: An instance of the `Switchboard` class
    public init(switchboard: Switchboard) {
        self.switchboard = switchboard

        restoreFromCacheIfNecessary()
    }

    // MARK: - Public Properties

    public let switchboard: Switchboard

    open var activeFeatures: [SwitchboardFeature] {
        return Array(switchboard.features)
    }

    open var inactiveFeatures: [SwitchboardFeature] {
        return Array(switchboard.inactiveFeatures)
    }

    open var activeExperiments: [SwitchboardExperiment] {
        return Array(switchboard.experiments)
    }

    open var inactiveExperiments: [SwitchboardExperiment] {
        return Array(switchboard.inactiveExperiments)
    }

    // MARK: - Caching

    open func cacheAll() {
        SwitchboardDebugCache.cache(experiments: Set(activeExperiments), features: Set(activeFeatures), namespace: activeKey)
        SwitchboardDebugCache.cache(experiments: Set(inactiveExperiments), features: Set(inactiveFeatures), namespace: inactiveKey)
        switchboard.isDebugging = true
    }

    open func clearCacheAndSwitchboard() {
        SwitchboardDebugCache.clear(namespace: activeKey)
        SwitchboardDebugCache.clear(namespace: inactiveKey)
        switchboard.experiments.removeAll()
        switchboard.inactiveExperiments.removeAll()
        switchboard.features.removeAll()
        switchboard.inactiveFeatures.removeAll()
        switchboard.isDebugging = false
    }

    // MARK: - Features API

    open func exists(feature: SwitchboardFeature) -> Bool {
        return switchboard.features.contains(feature) || switchboard.inactiveFeatures.contains(feature)
    }

    open func activate(feature: SwitchboardFeature) {
        switchboard.inactiveFeatures.remove(feature)
        switchboard.add(feature: feature)
    }

    open func deactivate(feature: SwitchboardFeature) {
        switchboard.inactiveFeatures.insert(feature)
        switchboard.remove(feature: feature)
    }

    open func delete(feature: SwitchboardFeature) {
        switchboard.features.remove(feature)
        switchboard.inactiveFeatures.remove(feature)
    }

    open func toggle(feature: SwitchboardFeature) {
        // Toggle inactive
        if let oldFeature = switchboard.feature(named: feature.name) {
            deactivate(feature: oldFeature)
            return
        }

        // Or toggle active
        activate(feature: feature)
    }

    open func change(values: [String: Any], for feature: SwitchboardFeature) {
        feature.values = values
    }

    // MARK: - Experiments API

    open func exists(experiment: SwitchboardExperiment) -> Bool {
        return switchboard.experiments.contains(experiment) || switchboard.inactiveExperiments.contains(experiment)
    }

    open func activate(experiment: SwitchboardExperiment) {
        switchboard.inactiveExperiments.remove(experiment)
        switchboard.add(experiment: experiment)
    }

    open func deactivate(experiment: SwitchboardExperiment) {
        switchboard.inactiveExperiments.insert(experiment)
        switchboard.remove(experiment: experiment)
    }

    open func delete(experiment: SwitchboardExperiment) {
        switchboard.experiments.remove(experiment)
        switchboard.inactiveExperiments.remove(experiment)
    }

    open func toggle(experiment: SwitchboardExperiment) {
        // Toggle inactive
        if let oldExperiment = switchboard.experiment(named: experiment.name) {
            deactivate(experiment: oldExperiment)
            return
        }

        // Or toggle active
        activate(experiment: experiment)
    }

    open func change(cohort: String, experiment: SwitchboardExperiment) {
        experiment.values[SwitchboardKeys.cohort] = cohort
    }

    open func change(values: [String: Any], for experiment: SwitchboardExperiment) {
        experiment.values = values
    }

    open func update(availableCohorts: [String], for experiment: SwitchboardExperiment) {
        experiment.availableCohorts = availableCohorts
    }

    // MARK: - Private Properties

    fileprivate let activeKey = "active"
    fileprivate let inactiveKey = "inactive"

}

// MARK: - Private API

fileprivate extension SwitchboardDebugController {

    func restoreFromCacheIfNecessary() {
        guard switchboard.isDebugging else { return }

        let (activeExperiments, activeFeatures) = SwitchboardDebugCache.restoreFromCache(namespace: activeKey)
        let (inactiveExperiments, inactiveFeatures) = SwitchboardDebugCache.restoreFromCache(namespace: inactiveKey)
        if let activeExperiments = activeExperiments {
            switchboard.experiments = activeExperiments
        }
        if let inactiveExperiments = inactiveExperiments {
            switchboard.inactiveExperiments = inactiveExperiments
        }
        if let activeFeatures = activeFeatures {
            switchboard.features = activeFeatures
        }
        if let inactiveFeatures = inactiveFeatures {
            switchboard.inactiveFeatures = inactiveFeatures
        }
    }

}
