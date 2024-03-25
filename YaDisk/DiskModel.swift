//
//  ViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 16.02.2024.
//

import UIKit

class ViewController: UIViewController {
    private let token = "y0_AgAAAAAkCDffAAtsZAAAAAD94C1XAAABNTw69nZOhJOhHn07EeC3rr3SAw"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    


    func getDiskInfo(completion: @escaping (DiskInfo?, Error?) -> Void) {
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(nil, error)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("y0_AgAAAAAkCDffAAtsZAAAAAD94C1XAAABNTw69nZOhJOhHn07EeC3rr3SAw", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let data = data, let diskInfo = try? JSONDecoder().decode(DiskInfo.self, from: data) {
                completion(diskInfo, nil)
            } else {
                let error = NSError(domain: "Invalid Response", code: 1)
                completion(nil, error)
            }
        }
        task.resume()
    }
}

