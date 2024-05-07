//
//  ViewController.swift
//  YaDisk
//
//  Created by Алексей Решетников on 16.02.2024.
//

import Foundation
import UIKit
import Alamofire

class DiskModel: DiskModelProtocol, ObservableObject {

    static let shared = DiskModel()
    private let tokenKey = "YaDiskAccessToken"
    var token: String?

    func setToken(_ newToken: String) {
        UserDefaults.standard.set(newToken, forKey: tokenKey)
        UserDefaults.standard.synchronize()
    }
    
    func loadTokenFromStorage() {
        token = UserDefaults.standard.string(forKey: tokenKey)
        if token == nil {
            print("Токен не загружен.")
        } else {
            print("Токен успешно загружен: \(token!)")
        }
    }

    func getDiskInfo(completion: @escaping (DiskInfo?, Error?) -> Void) {
        guard let url = URL(string: "https://cloud-api.yandex.net/v1/disk/") else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            print("Error: Invalid URL - \(error.localizedDescription)")
            completion(nil, error)
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("y0_AgAAAAAkCDffAAuG_gAAAAEAIT3BAADR8oAHnTZF4aBhf7m57hD2wqFbPQ", forHTTPHeaderField: "Authorization")
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
    
    func newFetchData(forPath path: String = "", limit: Int = 1000, offset: Int = 0, completion: @escaping (ApiResponse?, Error?) -> Void) {
        guard let token = token else {
            completion(nil, NSError(domain: "Token Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Токен не найден"]))
            return
        }
        
        guard var urlComponents = URLComponents(string: "https://cloud-api.yandex.net/v1/disk/\(path)") else {
            completion(nil, NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"]))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset)),
            URLQueryItem(name: "fields", value: "name,_embedded.items.path,created")
        ]
        
        guard let url = urlComponents.url else {
            completion(nil, NSError(domain: "URL Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Не удалось создать URL из компонентов"]))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    let responseBody = String(data: data!, encoding: .utf8) ?? "No response body"
                    print("Response Body: \(responseBody)")
                    completion(nil, NSError(domain: "HTTP Response Error", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Получен неверный HTTP ответ: \(responseBody)"]))
                    return
                }
            }
            
            
            if let data = data, let decodedResponse = try? JSONDecoder().decode(ApiResponse.self, from: data) {
                completion(decodedResponse, nil)
            } else {
                completion(nil, NSError(domain: "Data Error", code: 2, userInfo: [NSLocalizedDescriptionKey: "Не удалось декодировать данные"]))
            }
        }
        
        task.resume()
    }
}

