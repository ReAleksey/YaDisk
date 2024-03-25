//
//  ViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 16.02.2024.
//

import UIKit

class DiskModel: DiskModelProtocol {
//    private let token = "OAuth y0_AgAAAAAkCDffAAtsZAAAAAD94C1XAAABNTw69nZOhJOhHn07EeC3rr3SAw"

    func getDiskInfo(completion: @escaping (DiskInfo?, Error?) -> Void) {
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            print("Error: Invalid URL - \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("y0_AgAAAAAkCDffAAtsZAAAAAD94C1XAAABNTw69nZOhJOhHn07EeC3rr3SAw", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("Sending request...")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                let error = NSError(domain: "Invalid Response", code: 1)
                print("Error: Invalid HTTP Response")
                completion(nil, error)
                return
            }
            
            print("Response status code: \(httpResponse.statusCode)")
            
            if let data = data, let diskInfo = try? JSONDecoder().decode(DiskInfo.self, from: data) {

                completion(diskInfo, nil)
            } else {
                let error = NSError(domain: "Invalid Response Data", code: 2)
                print("Error: Invalid Response Data")
                completion(nil, error)
            }
        }
        task.resume()
    }
}

