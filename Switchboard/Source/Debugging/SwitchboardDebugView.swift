//
//  SwitchboardDebugView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import UIKit

public typealias SwitchboardDebugRefreshHandler = () -> ()

open class SwitchboardDebugView: UITableViewController {

    // MARK: - Instantiation

    public init(switchboard: Switchboard) {
        self.switchboard = switchboard

        super.init(style: .plain)

        setupView()
    }

    // MARK: - Properties

    public var refreshHandler: SwitchboardDebugRefreshHandler?

    // MARK: - API

    open func clearCacheAndSwitchboard() {
        debugController.clearCacheAndSwitchboard()
        tableView.reloadData()
    }

    open func reload() {
        tableView.reloadData()
        refresh.endRefreshing()
    }

    // MARK: - UITableViewDataSource

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
            else { fatalError("Unsupported cell type ") }
        cell.configure(title: rows[indexPath.row].title)
        return cell
    }

    // MARK: - UITableViewDelegate

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row: SwitchboardDebugRow = rows[indexPath.row]
        if row == .features {
            show(viewController: SwitchboardDebugFeatureView(debugController: debugController))
        } else if row == .experiments {
            show(viewController: SwitchboardDebugExperimentView(debugController: debugController))
        }
    }

    // MARK: - Private Properties

    fileprivate enum SwitchboardDebugRow {
        case features, experiments

        var title: String {
            switch self {
            case .features: return "Features"
            case .experiments: return "Experiments"
            }
        }
    }

    fileprivate let switchboard: Switchboard

    fileprivate lazy var debugController: SwitchboardDebugController = { [unowned self] in
        return SwitchboardDebugController(switchboard: self.switchboard)
    }()

    fileprivate lazy var refresh: UIRefreshControl = { [unowned self] in
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        return refreshControl
    }()

    fileprivate let rows: [SwitchboardDebugRow] = [.features, .experiments]

    // MARK: - Unsupported Initializers

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugView {

    // MARK: - View Setup

    func setupView() {
        title = "Switchboard Debug"
        
        setupTable()
    }

    func setupTable() {
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = 60
        tableView.register(SwitchboardDebugTapCell.self, forCellReuseIdentifier: SwitchboardDebugTapCell.reuseIdentifier)
        tableView.addSubview(refresh)
    }

    // MARK: - Helpers

    func show(viewController: UIViewController) {
        if let navigationController = navigationController {
            navigationController.pushViewController(viewController, animated: true)
        } else {
            let navigationController = UINavigationController(rootViewController: viewController)
            present(navigationController, animated: true, completion: nil)
        }
    }

    // MARK: - Actions

    @objc func refreshTable() {
        refreshHandler?()
    }

}

