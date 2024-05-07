//
//  AllFilesViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class AllFilesViewController: UITableViewController {
    
    var diskModel = DiskModel.shared
    var response: ApiResponse?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(ElementCell.self, forCellReuseIdentifier: ElementCell.identifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        setupViews()
        fetchData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return response?.items.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ElementCell.identifier, for: indexPath) as? ElementCell,
              let fileItem = response?.items[indexPath.row] else {
            fatalError("Cannot dequeue ElementCell or cast to ElementCell")
        }
        
        cell.configure(with: fileItem)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
        guard let item = response?.items[indexPath.row] else {
            print("Item not found.")
            return
        }
        
        // Вывод информации о выбранном файле
        print("Name: \(item.name)")
        print("Size: \(item.size)")
        print("Created: \(item.created)")
        print("Resource ID: \(item.resourceID)")
        print("Modified: \(item.modified)")
        print("Mime Type: \(item.mimeType)")
        print("File URL: \(item.file)")
        print("Preview URL: \(item.preview ?? "no preview")")
        print("Path: \(item.path)")
        print("SHA256: \(item.sha256)")
        print("Type: \(item.type)")
        print("MD5: \(item.md5)")
        print("Revision: \(item.revision)")
        
        // Дополнительные поля
        print("Antivirus Status: \(item.antivirusStatus)")
        print("Private Resource ID: \(item.commentIds.privateResource)")
        print("Public Resource ID: \(item.commentIds.publicResource)")
        
        // Вывод информации о дате из данных EXIF
        print("EXIF Date Time: \(item.exif?.dateTime ?? "no date time")")
        
        // Вывод информации о доступных размерах изображения
        item.sizes?.forEach { size in
            print("Size Name: \(size.name), URL: \(size.url)")
        }
        
        // Снимаем выделение с выбранной ячейки
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func fetchData() {
        diskModel.loadTokenFromStorage()
        
        if let token = diskModel.token {
            // Выполнить запрос с токеном
            print("Using token: \(token)")
        } else {
            showError("Токен не найден. Пожалуйста, выполните вход снова.")
        }
        
        diskModel.newFetchData(forPath: "resources/files") { [weak self] resources, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                }
                return
            }
            
            if let resources = resources {
                self.response = resources
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.isViewLoaded && (self.view.window != nil) else {
                print("View controller is not in the window hierarchy.")
                return
            }
            
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    private func displayError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
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
    
    @objc private func sortingButtonTapped() {
        
    }
        
    func loadImage(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            completion(UIImage(data: data))
        }
        task.resume()
    }

}
