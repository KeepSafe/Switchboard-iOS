//
//  SwitchboardDebugFeatureView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugFeatureView: SwitchboardDebugListView {

    // MARK: - Properties

    override var debugTitle: String { return "Features" }

    // MARK: - Overrides

    override func setupView() {
        super.setupView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFeatureTapped))
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let features = features(forSection: section) else { return 0 }
        return features.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
            else { fatalError("Unsupported cell type ") }

        guard let features = features(forSection: indexPath.section) else { return cell }
        let section = sections[indexPath.section]
        let feature = features[indexPath.row]
        cell.configure(title: section == .enabled ? "🔵 \(feature.name)" : "🔴 \(feature.name)")
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let features = features(forSection: indexPath.section) else { return }

        let feature = features[indexPath.row]
        debugController?.delete(feature: feature)
        tableView.reloadData()

        debugController?.cacheAll()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let features = features(forSection: indexPath.section), let debugController = debugController else { return }
        let feature = features[indexPath.row]
        let vc = SwitchboardDebugFeatureEditView(feature: feature, debugController: debugController) {
            self.tableView.reloadData()
        }
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true, completion: nil)
    }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugFeatureView {

    // MARK: - Actions

    @objc func addFeatureTapped() {
        let alertController = UIAlertController(title: "Add Feature", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] alert in
            guard let strongSelf = self,
                  let textField = alertController?.textFields?.first,
                  let featureName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  featureName.isEmpty == false,
                  let feature = SwitchboardFeature(name: featureName, analytics: strongSelf.debugController?.analytics),
                  strongSelf.debugController?.exists(feature: feature) == false
            else { return }

            strongSelf.debugController?.activate(feature: feature)
            guard let featureIndex = strongSelf.debugController?.activeFeatures.index(of: feature),
                  let sectionIndex = strongSelf.sections.index(of: .enabled) else {
                strongSelf.tableView.reloadData()
                return
            }
            strongSelf.tableView.beginUpdates()
            let indexPath = IndexPath(row: featureIndex, section: sectionIndex)
            strongSelf.tableView.insertRows(at: [indexPath], with: .automatic)
            strongSelf.tableView.endUpdates()

            strongSelf.debugController?.cacheAll()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Feature name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Helpers

    func features(forSection section: Int) -> [SwitchboardFeature]? {
        let section = sections[section]
        if section == .enabled { return debugController?.activeFeatures }
        if section == .disabled { return debugController?.inactiveFeatures }
        return nil
    }

}
#endif
