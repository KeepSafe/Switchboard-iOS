//
//  SwitchboardDebugExperimentView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugExperimentView: SwitchboardDebugListView {

    // MARK: - Properties

    override var debugTitle: String { return "Experiments" }

    // MARK: - Overrides

    override func setupView() {
        super.setupView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExperimentTapped))
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let experiments = experiments(forSection: section) else { return 0 }
        return experiments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
            else { fatalError("Unsupported cell type ") }

        guard let experiments = experiments(forSection: indexPath.section) else { return cell }
        let section = sections[indexPath.section]
        let experiment = experiments[indexPath.row]
        let subtitle = "status: \(statusFor(experiment: experiment)) ∙ cohort: \(experiment.cohort)"
        cell.configure(title: section == .enabled ? "🔵 \(experiment.name)" : "🔴 \(experiment.name)", subtitle: subtitle)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let experiments = experiments(forSection: indexPath.section) else { return }

        let experiment = experiments[indexPath.row]
        debugController?.delete(experiment: experiment)
        tableView.reloadData()

        debugController?.cacheAll()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let experiments = experiments(forSection: indexPath.section), let debugController = debugController else { return }
        let experiment = experiments[indexPath.row]
        let vc = SwitchboardDebugExperimentEditView(experiment: experiment, debugController: debugController) {
            self.tableView.reloadData()
        }
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true, completion: nil)
    }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugExperimentView {

    // MARK: - Actions

    @objc func addExperimentTapped() {
        let alertController = UIAlertController(title: "Add Experiment", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] alert in
            guard let strongSelf = self,
                  let nameTextField = alertController?.textFields?.first,
                  let cohortTextField = alertController?.textFields?.last,
                  let experimentName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let cohortName = cohortTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  experimentName.isEmpty == false,
                  cohortName.isEmpty == false,
                  let switchboard = strongSelf.debugController?.switchboard,
                  let experiment = SwitchboardExperiment(name: experimentName, cohort: cohortName,
                                                         switchboard: switchboard, analytics: strongSelf.debugController?.analytics),
                  strongSelf.debugController?.exists(experiment: experiment) == false
                else { return }

            strongSelf.debugController?.activate(experiment: experiment)
            guard let experimentIndex = strongSelf.debugController?.activeExperiments.index(of: experiment),
                  let sectionIndex = strongSelf.sections.index(of: .enabled) else {
                    strongSelf.tableView.reloadData()
                    return
            }
            strongSelf.tableView.beginUpdates()
            let indexPath = IndexPath(row: experimentIndex, section: sectionIndex)
            strongSelf.tableView.insertRows(at: [indexPath], with: .automatic)
            strongSelf.tableView.endUpdates()

            strongSelf.debugController?.cacheAll()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Experiment name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Cohort name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    // MARK: - Helpers

    func experiments(forSection section: Int) -> [SwitchboardExperiment]? {
        let section = sections[section]
        if section == .enabled { return debugController?.activeExperiments }
        if section == .disabled { return debugController?.inactiveExperiments }
        return nil
    }

    func statusFor(experiment: SwitchboardExperiment) -> String {
        if experiment.isEntitled {
            return "entitled to start"
        }
        if experiment.isActive {
            return "started"
        }
        if experiment.isCompleted {
            return "completed"
        }
        return "unknown"
    }

}
#endif
