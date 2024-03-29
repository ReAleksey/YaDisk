//
//  LastFilesViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import UIKit

class LastFilesViewController: UITableViewController {

    var diskModel = DiskModel()
    var resources: [Resource] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        fetchData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resources.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let resource = resources[indexPath.row]
        cell.textLabel?.text = resource.name
        return cell
    }

    // MARK: - Data fetching

    func fetchData() {
        diskModel.fetchData(forPath: "") { [weak self] resources, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }

            DispatchQueue.main.async {
                self.resources = resources ?? []
                self.tableView.reloadData()
            }
        }
    }
}
