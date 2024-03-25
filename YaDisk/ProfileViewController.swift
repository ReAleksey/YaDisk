//
//  ProfileViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import UIKit
import SwiftUI

class ProfileViewController: UIViewController, Profile {
    private var diskInfoNew: DiskInfo?
    private var presenter: ProfilePresenter?

    func showInfo(_ diskInfo: DiskInfo) {
        diskInfoNew = diskInfo
        print("trash_size = \(diskInfoNew?.trash_size ?? 0)")
        print("total_space = \(diskInfoNew?.total_space ?? 0)")
        print("used_space = \(diskInfoNew?.used_space ?? 0)")
        print("system_folders_applications = \(diskInfoNew?.system_folders.applications ?? "ER")")
        print("system_folders_downloads = \(diskInfoNew?.system_folders.downloads ?? "ROR")")
        
        // Используем UIHostingController для отображения SwiftUI внутри UIViewController
        let hostingController = UIHostingController(rootView: DiagramView(chartDataObj: DiagramContainer(), diskInfo: diskInfoNew ?? DiskInfo(trash_size: 0, total_space: 0, used_space: 0, system_folders: SystemFolders(applications: "", downloads: ""))))
        print ("Переданные в хостинг контроллер данные:", hostingController.rootView.diskInfo.total_space)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    // Метод для отображения индикатора загрузки
    func showLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    // Метод для скрытия индикатора загрузки
    func hideLoading() {
        for subview in view.subviews {
            if let activityIndicator = subview as? UIActivityIndicatorView {
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }
    }
    
    // Метод для отображения ошибки
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter(view: self)
        view.backgroundColor = .white
        presenter?.getDiskInfo()
    }
    
    private func setupViews() {

    }
    
    private func setupConstrains() {
        
    }
}
