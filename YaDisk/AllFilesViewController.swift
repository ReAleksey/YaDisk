//
//  AllFilesViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import Foundation
import UIKit
import CoreData

class AllFilesViewController: UITableViewController {
    
    var diskModel = DiskModel()
    var resources: [Resource] = []
    
    struct Constants {
        static let entity = "FilesCell"
        static let sortName = "name"
        static let sortSize = "size"
        static let sortDate = "created"
    }

    enum SortingType: String {
        case name, size, created
    }
        
    var currentSortingType: SortingType = .name // Значение по умолчанию

    lazy var fetchResultController: NSFetchedResultsController<NSFetchRequestResult> = {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.entity)
        let sortDescriptor = NSSortDescriptor(key: Constants.sortName, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.instance.context, sectionNameKeyPath: nil, cacheName: nil)
        return fetchedResultController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(ElementCell.self, forCellReuseIdentifier: ElementCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        if let savedSortingType = UserDefaults.standard.string(forKey: "SortingType"),
            let sortingType = SortingType(rawValue: savedSortingType) {
            currentSortingType = sortingType
        }
        updateTableSorting()
        setupViews()
        fetchResultController.delegate = self
        do {
            try fetchResultController.performFetch()
        } catch {
            print (error)
        }
        fetchData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResultController.sections?[section].numberOfObjects ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ElementCell.identifier, for: indexPath) as? ElementCell,
//              let fileCell = fetchResultController.object(at: indexPath) as? FilesCell else {
//            fatalError("Cannot dequeue ElementCell or cast NSFetchedResult object")
//        }
//        cell.name.text = fileCell.name
//        cell.size.text = formatFileSize(Int(fileCell.size))
//        return cell
//    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ElementCell.identifier, for: indexPath) as? ElementCell,
              let fileCell = fetchResultController.object(at: indexPath) as? FilesCell else {
            fatalError("Cannot dequeue ElementCell or cast NSFetchedResult object")
        }
        cell.name.text = fileCell.name
        cell.size.text = formatFileSize(Int(fileCell.size))
        cell.dateLabel.text = formatDate(from: fileCell.created) // Убедитесь, что у вас есть UILabel в вашей ячейке для этого
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedElement = fetchResultController.object(at: indexPath) as! FilesCell
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let element = fetchResultController.object(at: indexPath) as! FilesCell
            CoreDataManager.instance.context.delete(element)
            CoreDataManager.instance.saveContext()
        }
    }
    
    func updateTableSorting() {
        let sortDescriptor: NSSortDescriptor
        switch currentSortingType {
        case .name:
            sortDescriptor = NSSortDescriptor(key: Constants.sortName, ascending: true)
        case .size:
            sortDescriptor = NSSortDescriptor(key: Constants.sortSize, ascending: true)
        case .created:
            sortDescriptor = NSSortDescriptor(key: Constants.sortDate, ascending: true)
        }
        
        fetchResultController.fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            try fetchResultController.performFetch()
            tableView.reloadData()
        } catch {
            print (error)
        }
    }
    
    func updateSortingType(_ newSortingType: SortingType) {
        currentSortingType = newSortingType
        UserDefaults.standard.set(newSortingType.rawValue, forKey: "SortingType") // Сохранение в UserDefaults
        updateTableSorting()
    }
    
    func fetchData() {
        diskModel.fetchData(forPath: "resources/files") { [weak self] resources, error in 
            guard let self = self else { return }

            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            resources?.forEach { resource in
                if !CoreDataManager.instance.fileExists(name: resource.name) {
                    CoreDataManager.instance.saveResource(resource)
                }
            }
            
            DispatchQueue.main.async {
                do {
                    try self.fetchResultController.performFetch()
                    self.tableView.reloadData()
                } catch {
                    print("Fetch failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func formatFileSize(_ sizeInBits: Int) -> String {
        let units = ["bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
        var convertedSize = Double(sizeInBits)
        var unitIndex = 0

        while convertedSize >= 1024.0 && unitIndex < units.count - 1 {
            convertedSize /= 1024.0
            unitIndex += 1
        }

        return String(format: "%.2f %@", convertedSize, units[unitIndex])
    }
    
    func createCustomTitleView(contactName: String) -> UIView {
        let view = UIView()
        let nameLabel = UILabel()
        nameLabel.text = contactName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        view.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        return view
    }
    
    func createCustomButton(imageName: String, selector: Selector) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: imageName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: button)
        return menuBarItem
    }
    
    private func setupViews() {

        let addButtonItem = createCustomButton(imageName: "plus.square.fill", selector: #selector(addButtonTapped))
        
        let customTitleView = createCustomTitleView(contactName: "All files")
        
        let sortButtonItem = createCustomButton(imageName: "arrow.up.arrow.down.square", selector: #selector(sortingButtonTapped))


        navigationItem.rightBarButtonItem = addButtonItem
        navigationItem.titleView = customTitleView
        navigationItem.leftBarButtonItem = sortButtonItem
    }
    
    @objc private func addButtonTapped() {
        
    }
    
    @objc func sortingButtonTapped() {
        let alertController = UIAlertController(title: "Sort By", message: nil, preferredStyle: .actionSheet)
        
        let nameAction = UIAlertAction(title: "Name", style: .default) { (_) in
            self.updateSortingType(.name)
        }
        let sizeAction = UIAlertAction(title: "Size", style: .default) { (_) in
            self.updateSortingType(.size)
        }
//        let dateAction = UIAlertAction(title: "Date", style: .default) { (_) in
//            self.updateSortingType(.created)
//        }
        
        alertController.addAction(nameAction)
        alertController.addAction(sizeAction)
//        alertController.addAction(dateAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    func formatDate(from date: Date?) -> String {
        guard let date = date else { return "Дата неизвестна" }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy" // Или любой другой формат, который вам нужен
        return formatter.string(from: date)
    }


}

extension AllFilesViewController: NSFetchedResultsControllerDelegate {
    // Информирует о начале изменения данных
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                let element = fetchResultController.object(at: indexPath) as! FilesCell
                let cell = tableView.cellForRow(at: indexPath) as! ElementCell
                
                cell.name.text = element.name
                
//                let dateFormatter = DateFormatter()
//                dateFormatter.dateFormat = "dd MMMM yyyy"
//                
//                if let dateOfBirth = person.dateOfBirthday {
//                    cell.cellDate.text = dateFormatter.string(from: dateOfBirth)
//                } else {
//                    cell.cellDate.text = "N/A"
//                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        default:
            break
        }
    }
    
    // Информирует об окончании изменения данных
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
