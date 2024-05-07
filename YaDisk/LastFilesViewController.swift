////
////  LastFilesViewController.swift
////  YaDisk
////
////  Created by Алексей Решетников on 15.03.2024.
////
//
//import UIKit
//import Alamofire
//
//class LastFilesViewController: UITableViewController {
//
//    var diskModel = DiskModel()
//    var resources: [Resource] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        self.tableView.register(ElementCell.self, forCellReuseIdentifier: ElementCell.identifier)
//
//        fetchData()
//    }
//
//    // MARK: - Table view data source
//
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return resources.count
//    }
//
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: ElementCell.identifier, for: indexPath) as? ElementCell else {
//            fatalError("You are a loser")
//        }
//        
//        let element: Resource = resources[indexPath.row]
//        cell.name.text = element.name
//        diskModel.loadImage(adress: element.preview ?? "https://w7.pngwing.com/pngs/619/624/png-transparent-sad-pepe-feelsbadman-memes-pepe-the-frog.png") { image in
//            if let loadedImage = image {
//                // Используйте загруженное изображение
//                cell.miniImage.image = loadedImage
//                print("Image loaded successfully!")
//            } else {
//                print("Failed to load image.")
//            }
//        }
//            
////        let previewURL = URL(string: element.preview ?? "https://w7.pngwing.com/pngs/619/624/png-transparent-sad-pepe-feelsbadman-memes-pepe-the-frog.png")!
////        
////        AF.download(previewURL).responseData { response in
////            if response.error == nil {
////                cell.miniImage.image = UIImage(data: response.value ?? Data())
////            }
////        }
//
//        return cell
//    }
//
//    // MARK: - Data fetching
//
//    func fetchData() {
//        diskModel.fetchData(forPath: "resources/last-uploaded") { [weak self] resources, error in
//            guard let self = self else { return }
//
//            if let error = error {
//                print("Error fetching data: \(error.localizedDescription)")
//                return
//            }
//
//            DispatchQueue.main.async {
////                self.resources = resources ?? []
//                self.tableView.reloadData()
//            }
//        }
//    }
//}
