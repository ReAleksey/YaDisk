//
//  TabBarController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 15.03.2024.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstVC = UINavigationController(rootViewController: ProfileViewController())
        let secondVC = TestAPIVC()// LastFilesViewController()
        let thirdVC = UINavigationController(rootViewController: AllFilesViewController())
        
        self.setViewControllers([firstVC, secondVC, thirdVC], animated: true)
        self.tabBar.backgroundColor = .white
        
        firstVC.tabBarItem.image = UIImage(systemName: "person.fill")
        secondVC.tabBarItem.image = UIImage(systemName: "doc.fill")
        thirdVC.tabBarItem.image = UIImage(systemName: "tray.full.fill")
        
    }
}
