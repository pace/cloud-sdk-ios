//
//  ListViewController.swift
//  PACECloudSDKExample
//
//  Created by Patrick Niepel on 05.11.20.
//

import SnapKit
import UIKit

class ListViewController: UIViewController {
    private lazy var tableView: UITableView = .init()
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()

    private lazy var loadingView: LoadingView = .init()

    private let viewModel: ListViewModel
    private var listItems: [ListItem] = []

    init(with viewModel: ListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayout()
        setupTableView()
        setupObserver()
    }

    private func setupLayout() {
        view.backgroundColor = UIColor.foreground
        navigationItem.title = Strings.titleList.rawValue

        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(ListItemCell.self, forCellReuseIdentifier: ListItemCell.reuseIdentifier)
        tableView.separatorInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        tableView.refreshControl = refreshControl
    }

    @objc
    private func handleRefresh() {
        viewModel.fetchCoFuStations()
        refreshControl.endRefreshing()
    }

    private func setupObserver(completion: (() -> Void)? = nil) {
        viewModel.listItems.observe(receiver: self) { [weak self] items in
            self?.listItems = items ?? []
            self?.tableView.reloadData()
        }

        viewModel.isLoading.observe(receiver: self) { isLoading in
            if isLoading ?? false {
                guard self.loadingView.superview == nil else { return }

                self.view.addSubview(self.loadingView)
                self.loadingView.snp.makeConstraints {
                    $0.center.equalToSuperview()
                    $0.width.equalToSuperview().multipliedBy(0.75)
                    $0.height.equalToSuperview().multipliedBy(0.3)
                }
            } else {
                self.loadingView.removeFromSuperview()
            }
        }
    }
}

extension ListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        listItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ListItemCell.reuseIdentifier, for: indexPath) as? ListItemCell

        cell?.setup(with: listItems[indexPath.row])

        return cell ?? UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
}

extension ListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let listItem = listItems[indexPath.row]

        let coordinates = listItem.coordinate
        let gasStationName = listItem.name

        guard let alert = NavigationService.handleNavigationRequest(to: coordinates, name: gasStationName) else { return }

        present(alert, animated: true)
    }
}
